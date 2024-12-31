(define-map borrowings
  { user: principal, asset: (string-ascii 10) }
  { amount: uint, collateral: uint, last-updated: uint })

(define-constant COLLATERAL_RATIO 150) ;; 150% collateral required

(define-public (borrow (asset (string-ascii 10)) (amount uint) (collateral uint))
  (begin
    (asserts! (>= (* amount COLLATERAL_RATIO) (* collateral 100)) (err "Insufficient collateral"))
    (let ((existing (map-get? borrowings { user: tx-sender, asset: asset })))
      (if (is-some existing)
          (let ((data (unwrap! existing (err "Error retrieving data"))))
            (map-set borrowings { user: tx-sender, asset: asset }
                     { amount: (+ (get amount data) amount),
                       collateral: (+ (get collateral data) collateral),
                       last-updated: block-height }))
          (map-set borrowings { user: tx-sender, asset: asset }
                   { amount: amount, collateral: collateral, last-updated: block-height }))))
    (ok "Borrow successful")))

(define-public (repay (asset (string-ascii 10)) (amount uint))
  (let ((data (map-get? borrowings { user: tx-sender, asset: asset })))
    (match data
      borrowing-data
      (begin
        (asserts! (<= amount (get amount borrowing-data)) (err "Repayment exceeds borrowing"))
        (map-set borrowings { user: tx-sender, asset: asset }
                 { amount: (- (get amount borrowing-data) amount),
                   collateral: (get collateral borrowing-data),
                   last-updated: block-height })
        (ok "Repayment successful")))
      (err "No borrowing found"))))
