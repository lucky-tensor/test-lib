
<a name="0x1_TransactionFee"></a>

# Module `0x1::TransactionFee`



-  [Resource `TransactionFee`](#0x1_TransactionFee_TransactionFee)
-  [Constants](#@Constants_0)
-  [Function `initialize`](#0x1_TransactionFee_initialize)
-  [Function `is_coin_initialized`](#0x1_TransactionFee_is_coin_initialized)
-  [Function `is_initialized`](#0x1_TransactionFee_is_initialized)
-  [Function `add_txn_fee_currency`](#0x1_TransactionFee_add_txn_fee_currency)
-  [Function `pay_fee`](#0x1_TransactionFee_pay_fee)
-  [Function `burn_fees`](#0x1_TransactionFee_burn_fees)
-  [Function `ol_burn_fees`](#0x1_TransactionFee_ol_burn_fees)
-  [Function `get_amount_to_distribute`](#0x1_TransactionFee_get_amount_to_distribute)
-  [Function `get_transaction_fees_coins`](#0x1_TransactionFee_get_transaction_fees_coins)
-  [Function `get_transaction_fees_coins_amount`](#0x1_TransactionFee_get_transaction_fees_coins_amount)
-  [Module Specification](#@Module_Specification_1)
    -  [Initialization](#@Initialization_2)
    -  [Helper Function](#@Helper_Function_3)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp">0x1::DiemTimestamp</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="Roles.md#0x1_Roles">0x1::Roles</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="XDX.md#0x1_XDX">0x1::XDX</a>;
</code></pre>



<a name="0x1_TransactionFee_TransactionFee"></a>

## Resource `TransactionFee`

The <code><a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a></code> resource holds a preburn resource for each
fiat <code>CoinType</code> that can be collected as a transaction fee.


<pre><code><b>struct</b> <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;CoinType&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>balance: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;CoinType&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>preburn: <a href="Diem.md#0x1_Diem_Preburn">Diem::Preburn</a>&lt;CoinType&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_TransactionFee_ETRANSACTION_FEE"></a>

A <code><a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a></code> resource is not in the required state


<pre><code><b>const</b> <a href="TransactionFee.md#0x1_TransactionFee_ETRANSACTION_FEE">ETRANSACTION_FEE</a>: u64 = 20000;
</code></pre>



<a name="0x1_TransactionFee_initialize"></a>

## Function `initialize`

Called in genesis. Sets up the needed resources to collect transaction fees from the
<code><a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a></code> resource with the TreasuryCompliance account.


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_initialize">initialize</a>(dr_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_initialize">initialize</a>(
    dr_account: &signer, /////// 0L /////////
) {
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_assert_genesis">DiemTimestamp::assert_genesis</a>();
    <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(dr_account); /////// 0L /////////
    // accept fees in all the currencies
    <a href="TransactionFee.md#0x1_TransactionFee_add_txn_fee_currency">add_txn_fee_currency</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(dr_account); /////// 0L /////////
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>include</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_AbortsIfNotGenesis">DiemTimestamp::AbortsIfNotGenesis</a>;
<b>include</b> <a href="Roles.md#0x1_Roles_AbortsIfNotTreasuryCompliance">Roles::AbortsIfNotTreasuryCompliance</a>{account: dr_account};
<b>include</b> <a href="TransactionFee.md#0x1_TransactionFee_AddTxnFeeCurrencyAbortsIf">AddTxnFeeCurrencyAbortsIf</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;;
<b>ensures</b> <a href="TransactionFee.md#0x1_TransactionFee_is_initialized">is_initialized</a>();
<b>ensures</b> <a href="TransactionFee.md#0x1_TransactionFee_spec_transaction_fee">spec_transaction_fee</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;().balance.value == 0;
</code></pre>




<a name="0x1_TransactionFee_AddTxnFeeCurrencyAbortsIf"></a>


<pre><code><b>schema</b> <a href="TransactionFee.md#0x1_TransactionFee_AddTxnFeeCurrencyAbortsIf">AddTxnFeeCurrencyAbortsIf</a>&lt;CoinType&gt; {
    <b>include</b> <a href="Diem.md#0x1_Diem_AbortsIfNoCurrency">Diem::AbortsIfNoCurrency</a>&lt;CoinType&gt;;
    <b>aborts_if</b> <b>exists</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;CoinType&gt;&gt;(@TreasuryCompliance)
        <b>with</b> Errors::ALREADY_PUBLISHED;
}
</code></pre>



</details>

<a name="0x1_TransactionFee_is_coin_initialized"></a>

## Function `is_coin_initialized`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">is_coin_initialized</a>&lt;CoinType&gt;(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">is_coin_initialized</a>&lt;CoinType&gt;(): bool {
    <b>exists</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;CoinType&gt;&gt;(@TreasuryCompliance)
}
</code></pre>



</details>

<a name="0x1_TransactionFee_is_initialized"></a>

## Function `is_initialized`



<pre><code><b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_is_initialized">is_initialized</a>(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_is_initialized">is_initialized</a>(): bool {
    <a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">is_coin_initialized</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;() //////// 0L ////////
}
</code></pre>



</details>

<a name="0x1_TransactionFee_add_txn_fee_currency"></a>

## Function `add_txn_fee_currency`

Sets up the needed transaction fee state for a given <code>CoinType</code> currency by
(1) configuring <code>dr_account</code> to accept <code>CoinType</code>
(2) publishing a wrapper of the <code>Preburn&lt;CoinType&gt;</code> resource under <code>dr_account</code>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_add_txn_fee_currency">add_txn_fee_currency</a>&lt;CoinType&gt;(dr_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_add_txn_fee_currency">add_txn_fee_currency</a>&lt;CoinType&gt;(dr_account: &signer) {
    <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(dr_account); /////// 0L /////////
    <a href="Diem.md#0x1_Diem_assert_is_currency">Diem::assert_is_currency</a>&lt;CoinType&gt;();
    <b>assert</b>!(
        !<a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">is_coin_initialized</a>&lt;CoinType&gt;(),
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_already_published">Errors::already_published</a>(<a href="TransactionFee.md#0x1_TransactionFee_ETRANSACTION_FEE">ETRANSACTION_FEE</a>)
    );
    <b>move_to</b>(
        dr_account,
        <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;CoinType&gt; {
            balance: <a href="Diem.md#0x1_Diem_zero">Diem::zero</a>(),
            preburn: <a href="Diem.md#0x1_Diem_create_preburn">Diem::create_preburn</a>(dr_account)
        }
    )
}
</code></pre>



</details>

<a name="0x1_TransactionFee_pay_fee"></a>

## Function `pay_fee`

Deposit <code>coin</code> into the transaction fees bucket


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_pay_fee">pay_fee</a>&lt;CoinType&gt;(coin: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;CoinType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_pay_fee">pay_fee</a>&lt;CoinType&gt;(coin: <a href="Diem.md#0x1_Diem">Diem</a>&lt;CoinType&gt;) <b>acquires</b> <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a> {
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_assert_operating">DiemTimestamp::assert_operating</a>();
    <b>assert</b>!(<a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">is_coin_initialized</a>&lt;CoinType&gt;(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="TransactionFee.md#0x1_TransactionFee_ETRANSACTION_FEE">ETRANSACTION_FEE</a>));
    <b>let</b> fees = <b>borrow_global_mut</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;CoinType&gt;&gt;(@TreasuryCompliance); // TODO: this is just the VM root actually
    <a href="Diem.md#0x1_Diem_deposit">Diem::deposit</a>(&<b>mut</b> fees.balance, coin)
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>include</b> <a href="TransactionFee.md#0x1_TransactionFee_PayFeeAbortsIf">PayFeeAbortsIf</a>&lt;CoinType&gt;;
<b>include</b> <a href="TransactionFee.md#0x1_TransactionFee_PayFeeEnsures">PayFeeEnsures</a>&lt;CoinType&gt;;
</code></pre>




<a name="0x1_TransactionFee_PayFeeAbortsIf"></a>


<pre><code><b>schema</b> <a href="TransactionFee.md#0x1_TransactionFee_PayFeeAbortsIf">PayFeeAbortsIf</a>&lt;CoinType&gt; {
    coin: <a href="Diem.md#0x1_Diem">Diem</a>&lt;CoinType&gt;;
    <b>let</b> fees = <a href="TransactionFee.md#0x1_TransactionFee_spec_transaction_fee">spec_transaction_fee</a>&lt;CoinType&gt;().balance;
    <b>include</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_AbortsIfNotOperating">DiemTimestamp::AbortsIfNotOperating</a>;
    <b>aborts_if</b> !<a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">is_coin_initialized</a>&lt;CoinType&gt;() <b>with</b> Errors::NOT_PUBLISHED;
    <b>include</b> <a href="Diem.md#0x1_Diem_DepositAbortsIf">Diem::DepositAbortsIf</a>&lt;CoinType&gt;{coin: fees, check: coin};
}
</code></pre>




<a name="0x1_TransactionFee_PayFeeEnsures"></a>


<pre><code><b>schema</b> <a href="TransactionFee.md#0x1_TransactionFee_PayFeeEnsures">PayFeeEnsures</a>&lt;CoinType&gt; {
    coin: <a href="Diem.md#0x1_Diem">Diem</a>&lt;CoinType&gt;;
    <b>let</b> fees = <a href="TransactionFee.md#0x1_TransactionFee_spec_transaction_fee">spec_transaction_fee</a>&lt;CoinType&gt;().balance;
    <b>let</b> <b>post</b> post_fees = <a href="TransactionFee.md#0x1_TransactionFee_spec_transaction_fee">spec_transaction_fee</a>&lt;CoinType&gt;().balance;
    <b>ensures</b> post_fees.value == fees.value + coin.value;
}
</code></pre>



</details>

<a name="0x1_TransactionFee_burn_fees"></a>

## Function `burn_fees`

Preburns the transaction fees collected in the <code>CoinType</code> currency.
If the <code>CoinType</code> is XDX, it unpacks the coin and preburns the
underlying fiat.


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_burn_fees">burn_fees</a>&lt;CoinType&gt;(dr_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_burn_fees">burn_fees</a>&lt;CoinType&gt;(
    dr_account: &signer,
) <b>acquires</b> <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a> {
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_assert_operating">DiemTimestamp::assert_operating</a>();
    <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(dr_account); /////// 0L /////////
    <b>assert</b>!(<a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">is_coin_initialized</a>&lt;CoinType&gt;(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="TransactionFee.md#0x1_TransactionFee_ETRANSACTION_FEE">ETRANSACTION_FEE</a>));
    <b>if</b> (<a href="XDX.md#0x1_XDX_is_xdx">XDX::is_xdx</a>&lt;CoinType&gt;()) {
        // TODO: Once the composition of <a href="XDX.md#0x1_XDX">XDX</a> is determined fill this in <b>to</b>
        // unpack and burn the backing coins of the <a href="XDX.md#0x1_XDX">XDX</a> coin.
        <b>abort</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="TransactionFee.md#0x1_TransactionFee_ETRANSACTION_FEE">ETRANSACTION_FEE</a>)
    } <b>else</b> {
        // extract fees
        <b>let</b> fees = <b>borrow_global_mut</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;CoinType&gt;&gt;(@TreasuryCompliance);
        <b>let</b> coin = <a href="Diem.md#0x1_Diem_withdraw_all">Diem::withdraw_all</a>(&<b>mut</b> fees.balance);
        <b>let</b> burn_cap = <a href="Diem.md#0x1_Diem_remove_burn_capability">Diem::remove_burn_capability</a>&lt;CoinType&gt;(dr_account);
        // burn
        <a href="Diem.md#0x1_Diem_burn_now">Diem::burn_now</a>(
            coin,
            &<b>mut</b> fees.preburn,
            @TreasuryCompliance,
            &burn_cap
        );
        <a href="Diem.md#0x1_Diem_publish_burn_capability">Diem::publish_burn_capability</a>(dr_account, burn_cap);
    }
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>pragma</b> disable_invariants_in_body;
</code></pre>


Must abort if the account does not have the TreasuryCompliance role [[H3]][PERMISSION].


<pre><code><b>include</b> <a href="Roles.md#0x1_Roles_AbortsIfNotTreasuryCompliance">Roles::AbortsIfNotTreasuryCompliance</a>{account: dr_account};
<b>include</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_AbortsIfNotOperating">DiemTimestamp::AbortsIfNotOperating</a>;
<b>aborts_if</b> !<a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">is_coin_initialized</a>&lt;CoinType&gt;() <b>with</b> Errors::NOT_PUBLISHED;
<b>include</b> <b>if</b> (<a href="XDX.md#0x1_XDX_spec_is_xdx">XDX::spec_is_xdx</a>&lt;CoinType&gt;()) <a href="TransactionFee.md#0x1_TransactionFee_BurnFeesXDX">BurnFeesXDX</a> <b>else</b> <a href="TransactionFee.md#0x1_TransactionFee_BurnFeesNotXDX">BurnFeesNotXDX</a>&lt;CoinType&gt;;
</code></pre>


The correct amount of fees is burnt and subtracted from market cap.


<pre><code><b>ensures</b> <a href="Diem.md#0x1_Diem_spec_market_cap">Diem::spec_market_cap</a>&lt;CoinType&gt;()
    == <b>old</b>(<a href="Diem.md#0x1_Diem_spec_market_cap">Diem::spec_market_cap</a>&lt;CoinType&gt;()) - <b>old</b>(<a href="TransactionFee.md#0x1_TransactionFee_spec_transaction_fee">spec_transaction_fee</a>&lt;CoinType&gt;().balance.value);
</code></pre>


All the fees is burnt so the balance becomes 0.


<pre><code><b>ensures</b> <a href="TransactionFee.md#0x1_TransactionFee_spec_transaction_fee">spec_transaction_fee</a>&lt;CoinType&gt;().balance.value == 0;
</code></pre>



</details>

<a name="0x1_TransactionFee_ol_burn_fees"></a>

## Function `ol_burn_fees`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_ol_burn_fees">ol_burn_fees</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_ol_burn_fees">ol_burn_fees</a>(
    vm: &signer,
) <b>acquires</b> <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a> {
    <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) != @VMReserved) {
        <b>return</b>
    };
    // extract fees
    <b>let</b> fees = <b>borrow_global_mut</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;&gt;(@TreasuryCompliance); // TODO: this is same <b>as</b> VM <b>address</b>
    <b>let</b> coin = <a href="Diem.md#0x1_Diem_withdraw_all">Diem::withdraw_all</a>(&<b>mut</b> fees.balance);
    <a href="Diem.md#0x1_Diem_vm_burn_this_coin">Diem::vm_burn_this_coin</a>(vm, coin);
}
</code></pre>



</details>

<a name="0x1_TransactionFee_get_amount_to_distribute"></a>

## Function `get_amount_to_distribute`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_get_amount_to_distribute">get_amount_to_distribute</a>(dr_account: &signer): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_get_amount_to_distribute">get_amount_to_distribute</a>(dr_account: &signer): u64 <b>acquires</b> <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a> {
    // Can only be invoked by DiemVM privilege.
    // Allowed association <b>to</b> invoke for testing purposes.
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(dr_account);
    // TODO: Return <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a> gracefully <b>if</b> there ino 0xFEE balance
    // <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;Token&gt;(0xFEE);
    <b>let</b> fees = <b>borrow_global</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;&gt;(
        @DiemRoot
    );

    <b>let</b> amount_collected = <a href="Diem.md#0x1_Diem_value">Diem::value</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&fees.balance);
    amount_collected
}
</code></pre>



</details>

<a name="0x1_TransactionFee_get_transaction_fees_coins"></a>

## Function `get_transaction_fees_coins`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_get_transaction_fees_coins">get_transaction_fees_coins</a>&lt;Token: store&gt;(dr_account: &signer): <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;Token&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_get_transaction_fees_coins">get_transaction_fees_coins</a>&lt;Token: store&gt;(
    dr_account: &signer
): <a href="Diem.md#0x1_Diem">Diem</a>&lt;Token&gt; <b>acquires</b> <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a> {
    // Can only be invoked by DiemVM privilege.
    // Allowed association <b>to</b> invoke for testing purposes.
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(dr_account);
    // TODO: Return <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a> gracefully <b>if</b> there ino 0xFEE balance
    // <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;Token&gt;(0xFEE);
    <b>let</b> fees = <b>borrow_global_mut</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;Token&gt;&gt;(
        @DiemRoot
    );

    <a href="Diem.md#0x1_Diem_withdraw_all">Diem::withdraw_all</a>(&<b>mut</b> fees.balance)
}
</code></pre>



</details>

<a name="0x1_TransactionFee_get_transaction_fees_coins_amount"></a>

## Function `get_transaction_fees_coins_amount`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_get_transaction_fees_coins_amount">get_transaction_fees_coins_amount</a>&lt;Token: store&gt;(dr_account: &signer, amount: u64): <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;Token&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_get_transaction_fees_coins_amount">get_transaction_fees_coins_amount</a>&lt;Token: store&gt;(
    dr_account: &signer, amount: u64
): <a href="Diem.md#0x1_Diem">Diem</a>&lt;Token&gt;  <b>acquires</b> <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a> {
    // Can only be invoked by DiemVM privilege.
    // Allowed association <b>to</b> invoke for testing purposes.
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(dr_account);
    // TODO: Return <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a> gracefully <b>if</b> there ino 0xFEE balance
    // <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;Token&gt;(0xFEE);
    <b>let</b> fees = <b>borrow_global_mut</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;Token&gt;&gt;(
        @DiemRoot
    );

    <a href="Diem.md#0x1_Diem_withdraw">Diem::withdraw</a>(&<b>mut</b> fees.balance, amount)
}
</code></pre>



</details>

<a name="@Module_Specification_1"></a>

## Module Specification



<a name="@Initialization_2"></a>

### Initialization


If time has started ticking, then <code><a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a></code> resources have been initialized.


<pre><code><b>invariant</b> [suspendable] <a href="DiemTimestamp.md#0x1_DiemTimestamp_is_operating">DiemTimestamp::is_operating</a>() ==&gt; <a href="TransactionFee.md#0x1_TransactionFee_is_initialized">is_initialized</a>();
</code></pre>



<a name="@Helper_Function_3"></a>

### Helper Function



<a name="0x1_TransactionFee_spec_transaction_fee"></a>


<pre><code><b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_spec_transaction_fee">spec_transaction_fee</a>&lt;CoinType&gt;(): <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;CoinType&gt; {
   <b>borrow_global</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;CoinType&gt;&gt;(@TreasuryCompliance)
}
</code></pre>
