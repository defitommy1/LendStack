(define-fungible-token stable-token)

(define-public (mint (amount uint))
  (begin
    (ft-mint? stable-token amount tx-sender)
    (ok "Mint successful")))

(define-public (transfer (recipient principal) (amount uint))
  (begin
    (ft-transfer? stable-token amount tx-sender recipient)
    (ok "Transfer successful")))
