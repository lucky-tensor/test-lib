#![forbid(unsafe_code)]
use self::ffi::Mpz;
use super::ffi;

#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord, Debug)]
pub struct CongruenceContext {
    g: Mpz,
    d: Mpz,
    e: Mpz,
    q: Mpz,
    r: Mpz,
}

impl Default for CongruenceContext {
    fn default() -> Self {
        Self {
            g: Mpz::new(),
            d: Mpz::new(),
            e: Mpz::new(),
            q: Mpz::new(),
            r: Mpz::new(),
        }
    }
}
impl CongruenceContext {
    pub fn solve_linear_congruence(
        &mut self,
        mu: &mut Mpz,
        v: Option<&mut Mpz>,
        a: &Mpz,
        b: &Mpz,
        m: &Mpz,
    ) -> bool {
        ffi::mpz_gcdext(&mut self.g, &mut self.d, &mut self.e, &a, &m);
        if cfg!(test) {
            println!(
                "g = {}, d = {}, e = {}, a = {}, m = {}",
                self.g, self.d, self.e, a, m
            );
        }
        ffi::mpz_fdiv_qr(&mut self.q, &mut self.r, &b, &self.g);
        if !self.r.is_zero() {
            return false;
        }
        ffi::mpz_mul(mu, &self.q, &self.d);
        *mu = mu.modulus(m);
        if let Some(v) = v {
            ffi::mpz_fdiv_q(v, &m, &self.g)
        }
        true
    }
}

#[cfg(test)]
mod test {
    use super::*;
    #[test]
    fn solve_linear_congruence_test() {
        let (a, b, c) = (11220.into(), (-2519).into(), 83384.into());
        let mut ctx: CongruenceContext = Default::default();
        let mut mu = Mpz::new();
        assert!(!ctx.solve_linear_congruence(&mut mu, None, &b, &c, &a))
    }
}
