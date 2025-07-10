;; SkillMint - Digital Skill Certification Platform
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
        certificates-issued: uint
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
            certificates-issued: u0
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
                  (institution-verified (get verified current-info))
                  (certificates-issued (get certificates-issued current-info)))
                (asserts! (> (len institution-name) u0) ERR_INVALID_INSTITUTION)
                (map-set institution-registry institution {
                    name: institution-name,
                    verified: true,
                    certificates-issued: certificates-issued
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
                (let ((current-issued (get certificates-issued institution-info)))
                    (let ((new-issued (+ current-issued u1)))
                        (let ((inst-name (get name institution-info)))
                            (map-set institution-registry institution {
                                name: inst-name,
                                verified: true,
                                certificates-issued: new-issued
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
                
                (ok certificate-id)
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
                    (ok true)
                )
            )
            ERR_CERTIFICATE_NOT_FOUND
        )
    )
)