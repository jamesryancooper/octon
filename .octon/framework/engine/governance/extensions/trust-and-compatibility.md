# Extension Trust And Compatibility

## Compatibility

Compatibility is evaluated in this order:

1. root manifest sanity
2. framework and instance companion manifest compatibility
3. pack manifest schema compatibility
4. pack compatibility against `octon.yml.versioning.harness.release_version`
5. pack compatibility against `octon.yml.versioning.extensions.api_version`
6. pack `compatibility.required_contracts` against the supported Packet 13
   contract set
7. pack `compatibility.profile_path` shape against the extension compatibility
   profile contract
8. host compatibility evaluation against the declared compatibility profile plus
   derived prompt-anchor requirements

- Extension compatibility is checked against
  `octon.yml.versioning.harness.release_version`.
- Extension API compatibility is checked against
  `octon.yml.versioning.extensions.api_version`.
- `pack.yml` is `octon-extension-pack-v4` and must carry
  `compatibility.required_contracts` plus
  `compatibility.profile_path: "validation/compatibility.yml"`.
- `validation/compatibility.yml` is `octon-extension-compatibility-profile-v1`
  and is mandatory for every v4 pack.

Supported `required_contracts.contract_id` values in this cutover are:

- `root-manifest`
- `framework-manifest`
- `instance-manifest`
- `instance-extensions`
- `extension-active-state`
- `extension-quarantine-state`
- `extension-effective-catalog`
- `extension-artifact-map`
- `extension-generation-lock`

## Trust

- Pack provenance travels with `pack.yml`.
- Repo trust decisions remain in `instance/extensions.yml`.
- `pack.yml` provenance must carry `source_id`, `imported_from`, `origin_uri`,
  `digest_sha256`, and `attestation_refs`.
- `first_party_external` and `third_party` packs must declare at least one
  external provenance locator or digest.
- `first_party_bundled` defaults to `allow`.
- `first_party_external` defaults to `require_acknowledgement`.
- `third_party` defaults to `deny`.

## Publication

- Invalid or denied packs quarantine locally under
  `state/control/extensions/quarantine.yml`.
- Compatibility proof is retained separately under
  `state/evidence/validation/compatibility/extensions/**`.
- A coherent surviving set may publish with quarantine recorded.
- If no coherent surviving set remains, extension contributions are withdrawn.
- `pack_bundle` remains trust-agnostic raw additive transfer; repo trust policy
  gates activation and publication only.
