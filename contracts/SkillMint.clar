;; SkillMint - Digital Skill Certification Platform with Institution Reputation System
;; A decentralized platform for issuing and verifying educational certificates

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_CERTIFICATE_NOT_FOUND (err u101))
(define-constant ERR_ALREADY_CERTIFIED (err u102))
(define-constant ERR_INVALID_INSTITUTION (err u103))
(define-constant ERR_INVALID_SKILL (err u104))
(define-constant ERR_LIST_OVERFLOW (err u105))
(define-constant ERR_INVALID_RECIPIENT (err u106))
(define-constant ERR_INVALID_EXPIRY_DATE (err u107))
(define-constant ERR_INVALID_PARAMETERS (err u108))
(define-constant ERR_EMPTY_BATCH (err u109))
(define-constant ERR_BATCH_TOO_LARGE (err u110))
(define-constant ERR_ALREADY_REVIEWED (err u111))
(define-constant ERR_INVALID_SCORE (err u112))
(define-constant ERR_CANNOT_REVIEW_OWN (err u113))

;; Reputation constants
(define-constant MIN_REPUTATION_SCORE u0)
(define-constant MAX_REPUTATION_SCORE u100)
(define-constant INITIAL_REPUTATION_SCORE u50)
(define-constant FEEDBACK_WEIGHT u10)
(define-constant VERIFICATION_WEIGHT u5)

;; Data Variables
(define-data-var certificate-counter uint u0)

;; Data Maps
(define-map certificates
    uint
    {
        recipient: principal,
        institution: principal,
        skill-name: (string-ascii 100),
        skill-level: (string-ascii 20),
        issue-date: uint,
        expiry-date: (optional uint),
        verified: bool
    }
)

(define-map institution-registry
    principal
    {
        name: (string-ascii 100),
        verified: bool,
        certificates-issued: uint,
        reputation-score: uint,
        total-reviews: uint,
        verification-rate: uint
    }
)

(define-map user-certificates
    principal
    (list 50 uint)
)

(define-map skill-registry
    (string-ascii 100)
    {
        category: (string-ascii 50),
        total-certified: uint
    }
)

(define-map certificate-reviews
    {certificate-id: uint, reviewer: principal}
    {
        quality-score: uint,
        relevance-score: uint,
        review-date: uint,
        comment: (string-ascii 200)
    }
)

(define-map user-institution-reviews
    {user: principal, institution: principal}
    bool
)

(define-map institution-reputation-history
    {institution: principal, date: uint}
    uint
)

;; Helper functions for validation
(define-private (is-valid-principal (p principal))
    (and 
        (not (is-eq p 'SP000000000000000000002Q6VF78))  ;; Not burn address
        (not (is-eq p 'SZ2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKQ9H6DPR))  ;; Not another known invalid address
    )
)

(define-private (is-valid-expiry-date (expiry (optional uint)) (issue-date uint))
    (match expiry
        exp-date (> exp-date issue-date)  ;; Expiry must be after issue date
        true  ;; No expiry date is valid
    )
)

(define-private (is-valid-skill-level (level (string-ascii 20)))
    (or 
        (is-eq level "beginner")
        (is-eq level "intermediate") 
        (is-eq level "advanced")
        (is-eq level "expert")
    )
)

(define-private (is-valid-score (score uint))
    (and (>= score MIN_REPUTATION_SCORE) (<= score MAX_REPUTATION_SCORE))
)

;; Helper function to validate batch certificate data
(define-private (validate-batch-cert-data 
    (recipient principal)
    (skill-name (string-ascii 100))
    (skill-level (string-ascii 20))
    (expiry-date (optional uint))
    (current-block-height uint)
    (institution principal)
)
    (and
        (is-valid-principal recipient)
        (not (is-eq recipient institution))
        (> (len skill-name) u0)
        (<= (len skill-name) u100)
        (> (len skill-level) u0)
        (<= (len skill-level) u20)
        (is-valid-skill-level skill-level)
        (is-valid-expiry-date expiry-date current-block-height)
        (is-some (map-get? skill-registry skill-name))
    )
)

;; Helper function to calculate new reputation score
(define-private (calculate-reputation-score 
    (current-score uint)
    (current-reviews uint)
    (quality-score uint)
    (relevance-score uint)
)
    (let (
        (average-feedback (/ (+ quality-score relevance-score) u2))
        (weighted-feedback (* average-feedback FEEDBACK_WEIGHT))
        (total-weight (* (+ current-reviews u1) u100))
        (current-weighted (* current-score (* current-reviews u100)))
        (new-total (+ current-weighted weighted-feedback))
        (new-score (/ new-total total-weight))
    )
        (if (> new-score MAX_REPUTATION_SCORE)
            MAX_REPUTATION_SCORE
            new-score
        )
    )
)

;; Helper function to update verification rate
(define-private (update-verification-rate (institution principal))
    (match (map-get? institution-registry institution)
        inst-info (let (
            (total-certs (get certificates-issued inst-info))
            (current-reputation (get reputation-score inst-info))
        )
            (if (> total-certs u0)
                (let (
                    (verified-count-result (get-verified-certificates-count institution))
                    (verified-count (get verified-count verified-count-result))
                    (verification-rate (/ (* verified-count u100) total-certs))
                    (verification-bonus (/ (* verification-rate VERIFICATION_WEIGHT) u100))
                    (new-reputation (+ current-reputation verification-bonus))
                    (final-reputation (if (> new-reputation MAX_REPUTATION_SCORE) 
                                        MAX_REPUTATION_SCORE 
                                        new-reputation))
                )
                    (map-set institution-registry institution {
                        name: (get name inst-info),
                        verified: (get verified inst-info),
                        certificates-issued: total-certs,
                        reputation-score: final-reputation,
                        total-reviews: (get total-reviews inst-info),
                        verification-rate: verification-rate
                    })
                    (ok verification-rate)
                )
                (ok u0)
            )
        )
        (err u404)
    )
)

;; Helper function to count verified certificates for an institution
(define-private (get-verified-certificates-count (institution principal))
    (let ((cert-counter (var-get certificate-counter)))
        (fold count-verified-certs 
            (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20)
            {verified-count: u0, institution: institution, max-cert-id: cert-counter}
        )
    )
)

(define-private (count-verified-certs 
    (batch-start uint)
    (acc {verified-count: uint, institution: principal, max-cert-id: uint})
)
    (let (
        (current-count (get verified-count acc))
        (target-institution (get institution acc))
        (max-id (get max-cert-id acc))
        (batch-size u100)
        (start-id (* (- batch-start u1) batch-size))
        (end-id (+ start-id batch-size))
    )
        (if (<= start-id max-id)
            (let ((batch-count (count-batch-verified start-id end-id target-institution max-id)))
                {
                    verified-count: (+ current-count batch-count),
                    institution: target-institution,
                    max-cert-id: max-id
                }
            )
            acc
        )
    )
)

(define-private (count-batch-verified (start uint) (end uint) (institution principal) (max-id uint))
    (if (> start max-id)
        u0
        (let ((actual-end (if (> end max-id) max-id end)))
            (get count (fold count-single-cert
                (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20)
                {count: u0, start: start, end: actual-end, institution: institution}
            ))
        )
    )
)

(define-private (count-single-cert 
    (offset uint)
    (acc {count: uint, start: uint, end: uint, institution: principal})
)
    (let (
        (cert-id (+ (get start acc) (- offset u1)))
        (end-id (get end acc))
        (target-institution (get institution acc))
        (current-count (get count acc))
    )
        (if (<= cert-id end-id)
            (match (map-get? certificates cert-id)
                cert-data (if (and 
                                (is-eq (get institution cert-data) target-institution)
                                (get verified cert-data))
                            {
                                count: (+ current-count u1),
                                start: (get start acc),
                                end: end-id,
                                institution: target-institution
                            }
                            acc
                        )
                acc
            )
            acc
        )
    )
)

;; Read-only functions
(define-read-only (get-certificate (certificate-id uint))
    (map-get? certificates certificate-id)
)

(define-read-only (get-institution-info (institution principal))
    (map-get? institution-registry institution)
)

(define-read-only (get-user-certificates (user principal))
    (default-to (list) (map-get? user-certificates user))
)

(define-read-only (get-skill-info (skill-name (string-ascii 100)))
    (map-get? skill-registry skill-name)
)

(define-read-only (get-certificate-counter)
    (var-get certificate-counter)
)

(define-read-only (verify-certificate (certificate-id uint))
    (match (map-get? certificates certificate-id)
        certificate (get verified certificate)
        false
    )
)

(define-read-only (get-certificate-review (certificate-id uint) (reviewer principal))
    (map-get? certificate-reviews {certificate-id: certificate-id, reviewer: reviewer})
)

(define-read-only (get-institution-reputation-score (institution principal))
    (match (map-get? institution-registry institution)
        inst-info (get reputation-score inst-info)
        u0
    )
)

(define-read-only (has-user-reviewed-institution (user principal) (institution principal))
    (default-to false (map-get? user-institution-reviews {user: user, institution: institution}))
)

(define-read-only (get-institution-verification-rate (institution principal))
    (match (map-get? institution-registry institution)
        inst-info (get verification-rate inst-info)
        u0
    )
)

;; Public functions
(define-public (register-institution (name (string-ascii 100)))
    (let ((institution tx-sender))
        ;; Validate institution principal
        (asserts! (is-valid-principal institution) ERR_INVALID_INSTITUTION)
        (asserts! (is-none (map-get? institution-registry institution)) ERR_INVALID_INSTITUTION)
        (asserts! (> (len name) u0) ERR_INVALID_INSTITUTION)
        (asserts! (<= (len name) u100) ERR_INVALID_INSTITUTION)
        
        (map-set institution-registry institution {
            name: name,
            verified: false,
            certificates-issued: u0,
            reputation-score: INITIAL_REPUTATION_SCORE,
            total-reviews: u0,
            verification-rate: u0
        })
        (ok true)
    )
)

(define-public (verify-institution (institution principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (is-valid-principal institution) ERR_INVALID_INSTITUTION)
        
        (let ((current-info (unwrap! (map-get? institution-registry institution) ERR_INVALID_INSTITUTION)))
            (let ((institution-name (get name current-info))
                  (certificates-issued (get certificates-issued current-info))
                  (reputation-score (get reputation-score current-info))
                  (total-reviews (get total-reviews current-info))
                  (verification-rate (get verification-rate current-info)))
                (asserts! (> (len institution-name) u0) ERR_INVALID_INSTITUTION)
                (map-set institution-registry institution {
                    name: institution-name,
                    verified: true,
                    certificates-issued: certificates-issued,
                    reputation-score: reputation-score,
                    total-reviews: total-reviews,
                    verification-rate: verification-rate
                })
                (ok true)
            )
        )
    )
)

(define-public (register-skill (skill-name (string-ascii 100)) (category (string-ascii 50)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (> (len skill-name) u0) ERR_INVALID_SKILL)
        (asserts! (<= (len skill-name) u100) ERR_INVALID_SKILL)
        (asserts! (> (len category) u0) ERR_INVALID_SKILL)
        (asserts! (<= (len category) u50) ERR_INVALID_SKILL)
        
        (map-set skill-registry skill-name {
            category: category,
            total-certified: u0
        })
        (ok true)
    )
)

(define-public (issue-certificate 
    (recipient principal) 
    (skill-name (string-ascii 100)) 
    (skill-level (string-ascii 20))
    (expiry-date (optional uint))
)
    (let (
        (certificate-id (+ (var-get certificate-counter) u1))
        (institution tx-sender)
        (current-block-height stacks-block-height)
    )
        ;; Validate all input parameters
        (asserts! (is-valid-principal recipient) ERR_INVALID_RECIPIENT)
        (asserts! (not (is-eq recipient institution)) ERR_INVALID_RECIPIENT)  ;; Institution can't certify itself
        (asserts! (> (len skill-name) u0) ERR_INVALID_SKILL)
        (asserts! (<= (len skill-name) u100) ERR_INVALID_SKILL)
        (asserts! (> (len skill-level) u0) ERR_INVALID_SKILL)
        (asserts! (<= (len skill-level) u20) ERR_INVALID_SKILL)
        (asserts! (is-valid-skill-level skill-level) ERR_INVALID_SKILL)
        (asserts! (is-valid-expiry-date expiry-date current-block-height) ERR_INVALID_EXPIRY_DATE)
        
        ;; Check if institution is registered and verified
        (let ((institution-info (unwrap! (map-get? institution-registry institution) ERR_INVALID_INSTITUTION)))
            (let ((inst-verified (get verified institution-info)))
                (asserts! inst-verified ERR_UNAUTHORIZED)
                
                ;; Check if skill is registered
                (asserts! (is-some (map-get? skill-registry skill-name)) ERR_INVALID_SKILL)
                
                ;; Validate certificate counter won't overflow
                (asserts! (< certificate-id u340282366920938463463374607431768211455) ERR_INVALID_PARAMETERS)
                
                ;; Create certificate with validated data
                (map-set certificates certificate-id {
                    recipient: recipient,
                    institution: institution,
                    skill-name: skill-name,
                    skill-level: skill-level,
                    issue-date: current-block-height,
                    expiry-date: expiry-date,
                    verified: true
                })
                
                ;; Update certificate counter
                (var-set certificate-counter certificate-id)
                
                ;; Add to user's certificate list with proper error handling
                (let ((current-certs (default-to (list) (map-get? user-certificates recipient))))
                    (let ((new-certs (unwrap! (as-max-len? (append current-certs certificate-id) u50) ERR_LIST_OVERFLOW)))
                        (map-set user-certificates recipient new-certs)
                    )
                )
                
                ;; Update institution stats - safely handle arithmetic
                (let ((current-issued (get certificates-issued institution-info))
                      (reputation-score (get reputation-score institution-info))
                      (total-reviews (get total-reviews institution-info))
                      (verification-rate (get verification-rate institution-info)))
                    (let ((new-issued (+ current-issued u1)))
                        (let ((inst-name (get name institution-info)))
                            (map-set institution-registry institution {
                                name: inst-name,
                                verified: true,
                                certificates-issued: new-issued,
                                reputation-score: reputation-score,
                                total-reviews: total-reviews,
                                verification-rate: verification-rate
                            })
                        )
                    )
                )
                
                ;; Update skill stats - safely handle skill data
                (let ((current-skill (unwrap! (map-get? skill-registry skill-name) ERR_INVALID_SKILL)))
                    (let ((current-total (get total-certified current-skill)))
                        (let ((new-total (+ current-total u1)))
                            (let ((skill-category (get category current-skill)))
                                (map-set skill-registry skill-name {
                                    category: skill-category,
                                    total-certified: new-total
                                })
                            )
                        )
                    )
                )
                
                ;; Update verification rate
                (try! (update-verification-rate institution))
                
                (ok certificate-id)
            )
        )
    )
)

(define-public (issue-batch-certificates 
    (certificates-data (list 20 {recipient: principal, skill-name: (string-ascii 100), skill-level: (string-ascii 20), expiry-date: (optional uint)}))
)
    (let (
        (institution tx-sender)
        (current-block-height stacks-block-height)
        (batch-size (len certificates-data))
        (starting-cert-id (+ (var-get certificate-counter) u1))
    )
        ;; Validate batch parameters
        (asserts! (> batch-size u0) ERR_EMPTY_BATCH)
        (asserts! (<= batch-size u20) ERR_BATCH_TOO_LARGE)
        
        ;; Check if institution is registered and verified
        (let ((institution-info (unwrap! (map-get? institution-registry institution) ERR_INVALID_INSTITUTION)))
            (let ((inst-verified (get verified institution-info)))
                (asserts! inst-verified ERR_UNAUTHORIZED)
                
                ;; Validate certificate counter won't overflow for the entire batch
                (asserts! (< (+ starting-cert-id batch-size) u340282366920938463463374607431768211455) ERR_INVALID_PARAMETERS)
                
                ;; Process batch using fold
                (let ((result (fold process-batch-cert certificates-data 
                    {
                        success: true,
                        institution: institution,
                        current-block-height: current-block-height,
                        next-cert-id: starting-cert-id,
                        issued-count: u0,
                        cert-ids: (list)
                    })))
                    (let ((success (get success result))
                          (issued-count (get issued-count result))
                          (cert-ids (get cert-ids result)))
                        
                        (asserts! success ERR_INVALID_PARAMETERS)
                        
                        ;; Update certificate counter
                        (var-set certificate-counter (+ starting-cert-id issued-count (- u1)))
                        
                        ;; Update institution stats
                        (let ((current-issued (get certificates-issued institution-info))
                              (reputation-score (get reputation-score institution-info))
                              (total-reviews (get total-reviews institution-info))
                              (verification-rate (get verification-rate institution-info)))
                            (let ((new-issued (+ current-issued issued-count)))
                                (let ((inst-name (get name institution-info)))
                                    (map-set institution-registry institution {
                                        name: inst-name,
                                        verified: true,
                                        certificates-issued: new-issued,
                                        reputation-score: reputation-score,
                                        total-reviews: total-reviews,
                                        verification-rate: verification-rate
                                    })
                                )
                            )
                        )
                        
                        ;; Update verification rate
                        (try! (update-verification-rate institution))
                        
                        (ok cert-ids)
                    )
                )
            )
        )
    )
)

;; Helper function for batch processing
(define-private (process-batch-cert 
    (cert-data {recipient: principal, skill-name: (string-ascii 100), skill-level: (string-ascii 20), expiry-date: (optional uint)})
    (acc {success: bool, institution: principal, current-block-height: uint, next-cert-id: uint, issued-count: uint, cert-ids: (list 20 uint)})
)
    (if (get success acc)
        (let (
            (recipient (get recipient cert-data))
            (skill-name (get skill-name cert-data))
            (skill-level (get skill-level cert-data))
            (expiry-date (get expiry-date cert-data))
            (institution (get institution acc))
            (current-block-height (get current-block-height acc))
            (certificate-id (get next-cert-id acc))
            (issued-count (get issued-count acc))
            (cert-ids (get cert-ids acc))
        )
            ;; Validate certificate data
            (if (validate-batch-cert-data recipient skill-name skill-level expiry-date current-block-height institution)
                (begin
                    ;; Create certificate
                    (map-set certificates certificate-id {
                        recipient: recipient,
                        institution: institution,
                        skill-name: skill-name,
                        skill-level: skill-level,
                        issue-date: current-block-height,
                        expiry-date: expiry-date,
                        verified: true
                    })
                    
                    ;; Add to user's certificate list
                    (let ((current-certs (default-to (list) (map-get? user-certificates recipient))))
                        (match (as-max-len? (append current-certs certificate-id) u50)
                            new-certs (map-set user-certificates recipient new-certs)
                            false ;; List overflow - continue processing but note the issue
                        )
                    )
                    
                    ;; Update skill stats
                    (match (map-get? skill-registry skill-name)
                        current-skill (let ((current-total (get total-certified current-skill)))
                            (let ((new-total (+ current-total u1)))
                                (let ((skill-category (get category current-skill)))
                                    (map-set skill-registry skill-name {
                                        category: skill-category,
                                        total-certified: new-total
                                    })
                                )
                            )
                        )
                        false ;; Skill not found - this shouldn't happen due to validation
                    )
                    
                    ;; Update accumulator
                    (match (as-max-len? (append cert-ids certificate-id) u20)
                        new-cert-ids {
                            success: true,
                            institution: institution,
                            current-block-height: current-block-height,
                            next-cert-id: (+ certificate-id u1),
                            issued-count: (+ issued-count u1),
                            cert-ids: new-cert-ids
                        }
                        ;; If we can't append to cert-ids list, mark as failed
                        {
                            success: false,
                            institution: institution,
                            current-block-height: current-block-height,
                            next-cert-id: certificate-id,
                            issued-count: issued-count,
                            cert-ids: cert-ids
                        }
                    )
                )
                ;; Validation failed
                {
                    success: false,
                    institution: institution,
                    current-block-height: current-block-height,
                    next-cert-id: certificate-id,
                    issued-count: issued-count,
                    cert-ids: cert-ids
                }
            )
        )
        ;; Previous failure, pass through
        acc
    )
)

(define-public (review-certificate 
    (certificate-id uint)
    (quality-score uint)
    (relevance-score uint)
    (comment (string-ascii 200))
)
    (let (
        (reviewer tx-sender)
        (current-block-height stacks-block-height)
    )
        ;; Validate parameters
        (asserts! (> certificate-id u0) ERR_CERTIFICATE_NOT_FOUND)
        (asserts! (<= certificate-id (var-get certificate-counter)) ERR_CERTIFICATE_NOT_FOUND)
        (asserts! (is-valid-score quality-score) ERR_INVALID_SCORE)
        (asserts! (is-valid-score relevance-score) ERR_INVALID_SCORE)
        (asserts! (<= (len comment) u200) ERR_INVALID_PARAMETERS)
        
        ;; Check if certificate exists
        (let ((certificate (unwrap! (map-get? certificates certificate-id) ERR_CERTIFICATE_NOT_FOUND)))
            (let ((cert-institution (get institution certificate))
                  (cert-recipient (get recipient certificate)))
                
                ;; Validate reviewer
                (asserts! (not (is-eq reviewer cert-institution)) ERR_CANNOT_REVIEW_OWN)
                (asserts! (is-eq reviewer cert-recipient) ERR_UNAUTHORIZED) ;; Only recipient can review
                
                ;; Check if already reviewed
                (asserts! (is-none (map-get? certificate-reviews {certificate-id: certificate-id, reviewer: reviewer})) ERR_ALREADY_REVIEWED)
                
                ;; Create review
                (map-set certificate-reviews 
                    {certificate-id: certificate-id, reviewer: reviewer}
                    {
                        quality-score: quality-score,
                        relevance-score: relevance-score,
                        review-date: current-block-height,
                        comment: comment
                    }
                )
                
                ;; Update institution reputation
                (let ((institution-info (unwrap! (map-get? institution-registry cert-institution) ERR_INVALID_INSTITUTION)))
                    (let ((current-reputation (get reputation-score institution-info))
                          (current-reviews (get total-reviews institution-info)))
                        (let ((new-reputation (calculate-reputation-score current-reputation current-reviews quality-score relevance-score))
                              (new-review-count (+ current-reviews u1)))
                            (map-set institution-registry cert-institution {
                                name: (get name institution-info),
                                verified: (get verified institution-info),
                                certificates-issued: (get certificates-issued institution-info),
                                reputation-score: new-reputation,
                                total-reviews: new-review-count,
                                verification-rate: (get verification-rate institution-info)
                            })
                            
                            ;; Mark user as having reviewed this institution
                            (map-set user-institution-reviews {user: reviewer, institution: cert-institution} true)
                        )
                    )
                )
                
                (ok true)
            )
        )
    )
)

(define-public (revoke-certificate (certificate-id uint))
    (begin
        ;; Validate certificate ID
        (asserts! (> certificate-id u0) ERR_CERTIFICATE_NOT_FOUND)
        (asserts! (<= certificate-id (var-get certificate-counter)) ERR_CERTIFICATE_NOT_FOUND)
        
        (match (map-get? certificates certificate-id)
            certificate (begin
                (let ((cert-institution (get institution certificate))
                      (cert-verified (get verified certificate))
                      (cert-recipient (get recipient certificate))
                      (cert-skill-name (get skill-name certificate))
                      (cert-skill-level (get skill-level certificate))
                      (cert-issue-date (get issue-date certificate))
                      (cert-expiry-date (get expiry-date certificate)))
                    
                    ;; Validate caller is the issuing institution
                    (asserts! (is-eq tx-sender cert-institution) ERR_UNAUTHORIZED)
                    ;; Ensure certificate is currently verified
                    (asserts! cert-verified ERR_CERTIFICATE_NOT_FOUND)
                    
                    (map-set certificates certificate-id {
                        recipient: cert-recipient,
                        institution: cert-institution,
                        skill-name: cert-skill-name,
                        skill-level: cert-skill-level,
                        issue-date: cert-issue-date,
                        expiry-date: cert-expiry-date,
                        verified: false
                    })
                    
                    ;; Update verification rate after revocation
                    (try! (update-verification-rate cert-institution))
                    
                    (ok true)
                )
            )
            ERR_CERTIFICATE_NOT_FOUND
        )
    )
)