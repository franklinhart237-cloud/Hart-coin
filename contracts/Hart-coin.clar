;; Hart-coin: minimal, clean Clarity contract
;; Implements a simple fungible token (HART) and a minimal liquidity pool with LP shares.
;; Compatible with Clarinet v3 (Clarity 2).

(define-constant CONTRACT-OWNER tx-sender) ;; Restrict minting to contract owner
(define-constant ERR-INSUFFICIENT-BALANCE u100)
(define-constant ERR-ZERO-AMOUNT u101)
(define-constant ERR-INSUFFICIENT-LP-SHARES u102)
(define-constant ERR-ZERO-POOL u103)
(define-constant ERR-UNAUTHORIZED u104)

;; Storage
(define-data-var total-supply uint u0)
(define-map balances
  { owner: principal }
  { balance: uint }
)

;; Liquidity pool state
(define-data-var pool-balance uint u0)
(define-data-var total-lp-shares uint u0)
(define-map lp-shares
  { owner: principal }
  { shares: uint }
)

;; Helpers
(define-private (get-balance (who principal))
  (default-to u0 (get balance (map-get? balances { owner: who })))
)

(define-private (get-lp (who principal))
  (default-to u0 (get shares (map-get? lp-shares { owner: who })))
)

;; Read-only accessors
(define-read-only (get-total-supply)
  (var-get total-supply)
)

(define-read-only (get-balance-of (who principal))
  (get-balance who)
)

(define-read-only (get-pool-balance)
  (var-get pool-balance)
)

(define-read-only (get-total-lp-shares)
  (var-get total-lp-shares)
)

(define-read-only (get-lp-balance (who principal))
  (get-lp who)
)

;; Mint (restricted to contract owner)
(define-public (mint
    (recipient principal)
    (amount uint)
  )
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-UNAUTHORIZED))
    (asserts! (> amount u0) (err ERR-ZERO-AMOUNT))
    (let (
        (old (get-balance recipient))
        (ts (var-get total-supply))
      )
      (map-set balances { owner: recipient } { balance: (+ old amount) })
      (var-set total-supply (+ ts amount))
      (print {
        event: "mint",
        to: recipient,
        amount: amount,
      })
      (ok amount)
    )
  )
)

;; Transfer
(define-public (transfer
    (to principal)
    (amount uint)
  )
  (let (
      (sender tx-sender)
      (bal (get-balance tx-sender))
    )
    (begin
      (asserts! (> amount u0) (err ERR-ZERO-AMOUNT))
      (asserts! (>= bal amount) (err ERR-INSUFFICIENT-BALANCE))
      (map-set balances { owner: sender } { balance: (- bal amount) })
      (map-set balances { owner: to } { balance: (+ (get-balance to) amount) })
      (print {
        event: "transfer",
        from: sender,
        to: to,
        amount: amount,
      })
      (ok amount)
    )
  )
)

;; Deposit liquidity
(define-public (deposit-liquidity (amount uint))
  (let (
      (who tx-sender)
      (bal (get-balance tx-sender))
    )
    (begin
      (asserts! (> amount u0) (err ERR-ZERO-AMOUNT))
      (asserts! (>= bal amount) (err ERR-INSUFFICIENT-BALANCE))
      (let (
          (pool (var-get pool-balance))
          (total-shares (var-get total-lp-shares))
        )
        (let ((shares-to-mint (if (is-eq total-shares u0)
            amount ;; Initial deposit: 1:1 shares
            (/ (* amount total-shares) pool)
          )))
          (map-set balances { owner: who } { balance: (- bal amount) })
          (var-set pool-balance (+ pool amount))
          (var-set total-lp-shares (+ total-shares shares-to-mint))
          (map-set lp-shares { owner: who } { shares: (+ (get-lp who) shares-to-mint) })
          (print {
            event: "deposit-liquidity",
            who: who,
            amount: amount,
            shares: shares-to-mint,
          })
          (ok shares-to-mint)
        )
      )
    )
  )
)

;; Withdraw liquidity
(define-public (withdraw-liquidity (shares uint))
  (let (
      (who tx-sender)
      (user-shares (get-lp tx-sender))
    )
    (begin
      (asserts! (> shares u0) (err ERR-ZERO-AMOUNT))
      (asserts! (>= user-shares shares) (err ERR-INSUFFICIENT-LP-SHARES))
      (asserts! (> (var-get pool-balance) u0) (err ERR-ZERO-POOL))
      (let (
          (pool (var-get pool-balance))
          (total-shares (var-get total-lp-shares))
        )
        (let ((amount-to-return (/ (* shares pool) total-shares)))
          (map-set lp-shares { owner: who } { shares: (- user-shares shares) })
          (var-set total-lp-shares (- total-shares shares))
          (var-set pool-balance (- pool amount-to-return))
          (map-set balances { owner: who } { balance: (+ (get-balance who) amount-to-return) })
          (print {
            event: "withdraw-liquidity",
            who: who,
            amount: amount-to-return,
            shares: shares,
          })
          (ok amount-to-return)
        )
      )
    )
  )
)