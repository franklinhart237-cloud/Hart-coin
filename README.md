# Hart-coin
Hart-coin is a teaching/demo Clarity token that includes simple liquidity pool mechanics.
What this repo contains:
- `contracts/Hart-coin.clar` — a Clarity contract implementing HART token and liquidity deposit/withdraw with LP shares bookkeeping.
- `tests/` — Clarinet-style tests (Vitest + Clarinet) including `liquidity.test.ts` testing deposits and withdrawals.
- `ui/` — a tiny static demo UI (non-functional placeholder) showing where wallet integration would be wired.

Contract functions (high level):
- `mint(recipient, amount)` — mint HART to an address (for tests; not restricted)
- `transfer(to, amount)` — transfer HART tokens
- `deposit-liquidity(amount)` — lock HART in the pool and receive LP shares
- `withdraw-liquidity(shares)` — burn LP shares and receive proportional HART back
- Read-only getters: `get-pool-balance`, `get-total-lp-shares`, `get-lp-balance`, `get-balance-of`

Running tests (locally)

This project uses Clarinet + Vitest. In your environment:

1. Install dependencies:

	npm install

2. Run tests:

	npm test

Note: the current environment running tasks may not have `vitest` installed globally. Installing project dependencies with `npm install` should provide the local binary.

UI demo

There is a minimal static demo in `ui/` which is a placeholder for wallet integration. To serve it, use any static server (e.g. `npx serve ui` or `python3 -m http.server` from the `ui` folder).

Notes & next steps
- Restrict `mint` to a minter/owner role for production.
- Add more robust LP math to avoid rounding edge cases.
- Add an express backend or browser wallet integration to call contract functions from the UI.

 
