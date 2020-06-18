// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

#![forbid(unsafe_code)]

use anyhow::{bail, format_err, Result};
use libra_logger::info;
use rusoto_autoscaling::{
    AutoScalingGroupNamesType, Autoscaling, AutoscalingClient, SetDesiredCapacityType,
};
use rusoto_core::Region;
use rusoto_sts::WebIdentityProvider;

/// set_asg_size sets the size of the given autoscaling group
#[allow(clippy::collapsible_if)]
pub async fn set_asg_size(
    min_desired_capacity: i64,
    buffer_percent: f64,
    asg_name: &str,
    wait_for_completion: bool,
    scaling_down: bool,
) -> Result<()> {
    let buffer = if scaling_down {
        0
    } else {
        ((min_desired_capacity as f64 * buffer_percent) / 100_f64).ceil() as i64
    };
    info!(
        "Scaling to min_desired_capacity : {}, buffer: {}, asg_name: {}",
        min_desired_capacity, buffer, asg_name
    );
    let set_desired_capacity_type = SetDesiredCapacityType {
        auto_scaling_group_name: asg_name.to_string(),
        desired_capacity: min_desired_capacity + buffer,
        honor_cooldown: Some(false),
    };
    let credentials_provider = WebIdentityProvider::from_k8s_env();

    let dispatcher = rusoto_core::HttpClient::new().expect("failed to create request dispatcher");
    let asc = AutoscalingClient::new_with(dispatcher, credentials_provider, Region::UsWest2);
    asc.set_desired_capacity(set_desired_capacity_type)
        .await
        .map_err(|e| format_err!("set_desired_capacity failed: {:?}", e))?;
    if !wait_for_completion {
        return Ok(());
    }
    libra_retrier::retry_async(libra_retrier::fixed_retry_strategy(10_000, 60), || {
        let asc_clone = asc.clone();
        Box::pin(async move {
            let mut total = 0;
            let mut current_token = None;
            loop {
                let current_token_clone = current_token.clone();
                let auto_scaling_group_names_type = AutoScalingGroupNamesType {
                    auto_scaling_group_names: Some(vec![asg_name.to_string()]),
                    // https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_DescribeAutoScalingGroups.html
                    // max value is 100
                    max_records: Some(100),
                    next_token: current_token_clone,
                };
                let asgs = asc_clone
                    .describe_auto_scaling_groups(auto_scaling_group_names_type)
                    .await?;
                if asgs.auto_scaling_groups.is_empty() {
                    bail!("asgs.auto_scaling_groups.is_empty()");
                }
                let asg = &asgs.auto_scaling_groups[0];
                if scaling_down {
                    total += asg
                        .instances
                        .clone()
                        .ok_or_else(|| format_err!("instances not found for auto_scaling_group"))?
                        .len() as i64;
                } else {
                    total += asg
                        .instances
                        .clone()
                        .ok_or_else(|| format_err!("instances not found for auto_scaling_group"))?
                        .iter()
                        .filter(|instance| instance.lifecycle_state == "InService")
                        .count() as i64;
                }
                if asgs.next_token.is_none() {
                    break;
                }
                current_token = asgs.next_token;
            }
            info!(
                "Waiting for scaling to complete. Current size: {}, Min Desired Size: {}",
                total, min_desired_capacity
            );
            if scaling_down {
                if total > min_desired_capacity {
                    bail!(
                    "Waiting for scale-down to complete. Current size: {}, Min Desired Size: {}",
                    total,
                    min_desired_capacity
                );
                } else {
                    info!("Scale down completed");
                    Ok(())
                }
            } else {
                if total < min_desired_capacity {
                    bail!(
                        "Waiting for scale-up to complete. Current size: {}, Min Desired Size: {}",
                        total,
                        min_desired_capacity
                    );
                } else {
                    info!("Scale up completed");
                    Ok(())
                }
            }
        })
    })
    .await
}
