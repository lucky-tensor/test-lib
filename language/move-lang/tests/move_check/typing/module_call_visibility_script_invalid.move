address 0x2 {

module X {
    fun f_private() {}
    public(script) fun f_script() {}
}

module M {
    use 0x2::X;

    public(script) fun f_script_call_script() { X::f_script() }

    // a public(script) fun in another module can only be called
    // by a public(script) fun from this module
    fun f_private_call_script() { X::f_script() }
    public fun f_public_call_script() { X::f_script() }

    // a public(script) fun in this module can only be called
    // by a public(script) fun from this module
    fun f_private_call_self_script() { f_script_call_script() }
    public fun f_public_call_self_script() { f_script_call_script() }

    // a public(script) fun cannot call private funs in other modules
    public(script) fun f_script_call_private() { X::f_private() }
}

}
