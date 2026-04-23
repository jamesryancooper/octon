// Proposal-local illustrative API shape. This is not promoted runtime code.

pub struct AuthorizedEffect<T> {
    token_id: String,
    effect_kind: &'static str,
    request_id: String,
    grant_id: String,
    run_id: String,
    scope_ref: String,
    token_digest: String,
    _marker: std::marker::PhantomData<T>,
}

pub struct VerifiedEffect<T> {
    token_id: String,
    effect_kind: &'static str,
    run_id: String,
    _marker: std::marker::PhantomData<T>,
}

pub trait EffectKind {
    const KIND: &'static str;
}

pub trait EffectTokenVerifier {
    fn verify<T: EffectKind>(&self, token: AuthorizedEffect<T>, target_ref: &str) -> Result<VerifiedEffect<T>, String>;
}

// Material APIs accept a token at their public boundary and immediately verify it.
pub fn repo_mutation<TVerifier: EffectTokenVerifier>(
    verifier: &TVerifier,
    token: AuthorizedEffect<RepoMutation>,
    target_ref: &str,
) -> Result<(), String> {
    let _guard = verifier.verify(token, target_ref)?;
    // perform mutation only while guard is in scope
    Ok(())
}

pub struct RepoMutation;
impl EffectKind for RepoMutation {
    const KIND: &'static str = "repo-mutation";
}
