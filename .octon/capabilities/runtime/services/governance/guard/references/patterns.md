# Guard Patterns

## Injection Pattern IDs

- `ignore_instructions`
- `system_prompt_leak`
- `role_override`
- `jailbreak_attempt`
- `instruction_injection`
- `base64_obfuscation`
- `prompt_delimiter_escape`
- `unicode_smuggling`

## Secret Pattern IDs

- `aws_key`
- `aws_secret`
- `github_token`
- `api_key_generic`
- `jwt_token`
- `private_key`
- `password_assignment`
- `connection_string`

## PII Pattern IDs

- `email`
- `phone_us`
- `ssn`
- `credit_card`
- `ip_address`

## Code Safety Pattern IDs

- `eval_usage`
- `exec_usage`
- `inner_html`
- `document_write`
- `sql_concatenation`
- `path_traversal`
- `hardcoded_localhost`
- `disable_ssl`

## Hallucination Pattern IDs

- `fake_npm_package`
- `helper_util_pattern`
- `non_standard_api`
- `confident_wrong_syntax`
- `imaginary_config`
- `todo_placeholder`
- `generic_error_handling`
