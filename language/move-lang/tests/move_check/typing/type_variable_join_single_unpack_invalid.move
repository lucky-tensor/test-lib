module M {
    struct Box<T> { f1: T, f2: T }

    new<T>(): Box<T> {
        abort 0
    }

    t0() {
        let Box { f1, f2 } = new();
        (f1: u64);
        (f2: bool);
        let Box { f1, f2 } = new();
        (f1: Box<u64>);
        (f2: Box<bool>);
    }
}
