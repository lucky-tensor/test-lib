
<a name="0x1_ProofOfFee"></a>

# Module `0x1::ProofOfFee`



-  [Resource `ProofOfFeeAuction`](#0x1_ProofOfFee_ProofOfFeeAuction)
-  [Function `current_bid`](#0x1_ProofOfFee_current_bid)
-  [Function `set_bid`](#0x1_ProofOfFee_set_bid)
-  [Function `init`](#0x1_ProofOfFee_init)
-  [Function `top_n_accounts`](#0x1_ProofOfFee_top_n_accounts)
-  [Function `get_sorted_vals`](#0x1_ProofOfFee_get_sorted_vals)
-  [Function `init_bidding`](#0x1_ProofOfFee_init_bidding)
-  [Function `update_pof_bid`](#0x1_ProofOfFee_update_pof_bid)


<pre><code><b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_ProofOfFee_ProofOfFeeAuction"></a>

## Resource `ProofOfFeeAuction`



<pre><code><b>struct</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>bid: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>epoch: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_ProofOfFee_current_bid"></a>

## Function `current_bid`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_current_bid">current_bid</a>(node_addr: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_current_bid">current_bid</a>(node_addr: <b>address</b>): u64 <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>&gt;(node_addr)) {
    <b>let</b> pof = <b>borrow_global</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>&gt;(node_addr);
    <b>let</b> e = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
    <b>if</b> (pof.epoch == e) {
      <b>return</b> pof.bid
    };
  };
  <b>return</b> 0
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_set_bid"></a>

## Function `set_bid`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_set_bid">set_bid</a>(account_sig: &signer, bid: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_set_bid">set_bid</a>(account_sig: &signer, bid: u64) <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {
  <b>let</b> acc = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account_sig);
  <b>assert</b>!(<b>exists</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>&gt;(acc), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(190001));
  <b>let</b> pof = <b>borrow_global_mut</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>&gt;(acc);
  pof.epoch = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
  pof.bid = bid;
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_init"></a>

## Function `init`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_init">init</a>(account_sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_init">init</a>(account_sig: &signer) {
  // TODO: check <b>if</b> this is a validator.

  <b>let</b> acc = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account_sig);
  <b>assert</b>!(<a href="DiemSystem.md#0x1_DiemSystem_is_validator">DiemSystem::is_validator</a>(acc), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(190001));

  <b>if</b> (!<b>exists</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>&gt;(acc)) {
    <b>move_to</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>&gt;(
    account_sig,
      <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {
        bid: 0,
        epoch: 0
      }
    );
  }
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_top_n_accounts"></a>

## Function `top_n_accounts`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_top_n_accounts">top_n_accounts</a>(account: &signer, n: u64): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_top_n_accounts">top_n_accounts</a>(account: &signer, n: u64): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {
    <b>assert</b>!(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account) == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(140101));

    <b>let</b> eligible_validators = <a href="ProofOfFee.md#0x1_ProofOfFee_get_sorted_vals">get_sorted_vals</a>();
    <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(&eligible_validators);
    <b>if</b>(len &lt;= n) <b>return</b> eligible_validators;

    <b>let</b> diff = len - n;
    <b>while</b>(diff &gt; 0){
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_pop_back">Vector::pop_back</a>(&<b>mut</b> eligible_validators);
      diff = diff - 1;
    };

    eligible_validators
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_get_sorted_vals"></a>

## Function `get_sorted_vals`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_get_sorted_vals">get_sorted_vals</a>(): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_get_sorted_vals">get_sorted_vals</a>(): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {
  <b>let</b> eligible_validators = <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">ValidatorUniverse::get_eligible_validators</a>();
  <b>let</b> length = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(&eligible_validators);
  // <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">Vector</a> <b>to</b> store each <b>address</b>'s node_weight
  <b>let</b> weights = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;();
  <b>let</b> k = 0;
  <b>while</b> (k &lt; length) {

    <b>let</b> cur_address = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<b>address</b>&gt;(&eligible_validators, k);
    // Ensure that this <b>address</b> is an active validator
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;u64&gt;(&<b>mut</b> weights, <a href="ProofOfFee.md#0x1_ProofOfFee_current_bid">current_bid</a>(cur_address));
    k = k + 1;
  };

  // Sorting the accounts vector based on value (weights).
  // Bubble sort algorithm
  <b>let</b> i = 0;
  <b>while</b> (i &lt; length){
    <b>let</b> j = 0;
    <b>while</b>(j &lt; length-i-1){

      <b>let</b> value_j = *(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&weights, j));
      <b>let</b> value_jp1 = *(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&weights, j+1));
      <b>if</b>(value_j &gt; value_jp1){
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_swap">Vector::swap</a>&lt;u64&gt;(&<b>mut</b> weights, j, j+1);
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_swap">Vector::swap</a>&lt;<b>address</b>&gt;(&<b>mut</b> eligible_validators, j, j+1);
      };
      j = j + 1;
    };
    i = i + 1;
  };

  // Reverse <b>to</b> have sorted order - high <b>to</b> low.
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_reverse">Vector::reverse</a>&lt;<b>address</b>&gt;(&<b>mut</b> eligible_validators);

  <b>return</b> eligible_validators
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_init_bidding"></a>

## Function `init_bidding`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_init_bidding">init_bidding</a>(sender: signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_init_bidding">init_bidding</a>(sender: signer) {
  <a href="ProofOfFee.md#0x1_ProofOfFee_init">init</a>(&sender);
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_update_pof_bid"></a>

## Function `update_pof_bid`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_update_pof_bid">update_pof_bid</a>(sender: signer, bid: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_update_pof_bid">update_pof_bid</a>(sender: signer, bid: u64) <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {
  // init just for safety
  <a href="ProofOfFee.md#0x1_ProofOfFee_init">init</a>(&sender);
  // <b>update</b> the bid
  <a href="ProofOfFee.md#0x1_ProofOfFee_set_bid">set_bid</a>(&sender, bid);
}
</code></pre>



</details>