(define-map deposits
  { user: principal, asset: (string-ascii 10) }
  { amount: uint, last-updated: uint })

(define-constant INTEREST_RATE 5) ;; 5% annual interest (for simplicity)

(define-private (calculate-interest (principal uint) (blocks uint))
  (/ (* principal blocks INTEREST_RATE) (* 52560 100)))

(define-public (deposit (asset (string-ascii 10)) (amount uint))
  (begin
    (asserts! (> amount u0) (err "Amount must be greater than zero"))
    (let ((existing (map-get? deposits { user: tx-sender, asset: asset })))
      (if (is-some existing)
          (let ((data (unwrap! existing (err "Error retrieving data"))))
            (let ((updated-amount (+ (get amount data) amount))
                  (interest (calculate-interest (get amount data) (- block-height (get last-updated data)))))
              (map-set deposits { user: tx-sender, asset: asset }
                       { amount: (+ updated-amount interest),
                         last-updated: block-height })))
          (map-set deposits { user: tx-sender, asset: asset }
                   { amount: amount, last-updated: block-height }))))
    (ok "Deposit successful")))

(define-public (withdraw (asset (string-ascii 10)) (amount uint))
  (let ((data (map-get? deposits { user: tx-sender, asset: asset })))
    (match data
      deposit-data
      (begin
        (let ((interest (calculate-interest (get amount deposit-data) (- block-height (get last-updated deposit-data)))))
          (asserts! (>= (+ (get amount deposit-data) interest) amount) (err "Insufficient funds"))
          (map-set deposits { user: tx-sender, asset: asset }
                   { amount: (- (+ (get amount deposit-data) interest) amount),
                     last-updated: block-height }))
        (ok "Withdrawal successful")))
      (err "No deposit found"))))
