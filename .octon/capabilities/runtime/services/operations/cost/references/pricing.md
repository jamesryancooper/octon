# Cost Pricing Reference

Pricing tiers are maintained inside the harness runtime and mapped by model family.

## Maintained Families

- `openai`
- `anthropic`
- `google`
- `mistral`
- `local`

## Notes

- All rates are interpreted as cost-per-1M-token unit prices.
- Unknown models fall back to the default low-cost profile.
- Local/offline models are treated as zero external provider cost.
