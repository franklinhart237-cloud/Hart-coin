import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const wallet1 = accounts.get("wallet_1")!;
const wallet2 = accounts.get("wallet_2")!;

describe("Hart-coin liquidity", () => {
  it("mints tokens, deposits liquidity and issues LP shares", () => {
    // mint 1000 to wallet1
    const r1 = simnet.mineBlock([`(contract-call? \"Hart-coin\" \"mint\" ${wallet1} u1000)`]);
    expect(r1.receipts[0].result).toBeOk();

    // wallet1 deposit 400 into liquidity
    const r2 = simnet.mineBlock([`(contract-call? \"Hart-coin\" \"deposit-liquidity\" ${wallet1} u400)`]);
    expect(r2.receipts[0].result).toBeOk();

    // pool balance should be 400
    const pool = simnet.callReadOnlyFn("Hart-coin", "get-pool-balance", [], wallet1);
    expect(pool.result).toBeUint(400);

    // lp shares for wallet1 should equal 400 (first provider)
    const lp = simnet.callReadOnlyFn("Hart-coin", "get-lp-balance", [wallet1], wallet1);
    expect(lp.result).toBeUint(400);
  });

  it("allows withdrawal of liquidity proportional to shares", () => {
    // mint to wallet2 and deposit
    simnet.mineBlock([`(contract-call? \"Hart-coin\" \"mint\" ${wallet2} u600)`]);
    simnet.mineBlock([`(contract-call? \"Hart-coin\" \"deposit-liquidity\" ${wallet2} u300)`]);

    // total pool should now be 700
    const pool2 = simnet.callReadOnlyFn("Hart-coin", "get-pool-balance", [], wallet1);
    expect(pool2.result).toBeUint(700);

    // wallet2 LP shares expected: proportionally minted -> shares = amount * total-shares / pool_before
    const lp2 = simnet.callReadOnlyFn("Hart-coin", "get-lp-balance", [wallet2], wallet2);
    expect(lp2.result).toBeUint(300);

    // wallet2 withdraw 150 shares -> should receive ~150 * 700 / 700 = 150 HART
    const w = simnet.mineBlock([`(contract-call? \"Hart-coin\" \"withdraw-liquidity\" ${wallet2} u150)`]);
    expect(w.receipts[0].result).toBeOk();

    // pool should decrease
    const pool3 = simnet.callReadOnlyFn("Hart-coin", "get-pool-balance", [], wallet1);
    expect(pool3.result).toBeUint(550);
  });
});
