# Commerce: paywalls

## When to use

The `commerce` feature library: a paywall screen's interactions (buy, restore, select a product, close, open a
legal link).

## Minimal example

{{example:pages/commerce}}

## Reference

{{reference}}

## Patterns

### A paywall screen

The products and offers come from the project's paywall placement; the screen is an ordinary canvas whose buttons
run `paywall` operations (`selectProduct`, then `purchase`; `restore`; `closePaywall`; `openLegalLink`).

## Pitfalls

- Not in the agent trust profile at run time.
- Prices shown must come from the store's products, not from text you write.

## See also

[Navigation](@page-navigation) (presenting the paywall) · [forms](@page-forms) (buttons).
