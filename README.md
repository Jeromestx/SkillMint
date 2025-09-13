# SkillMint 🎓

A decentralized digital skill certification platform built on Stacks blockchain that enables educational institutions to issue verifiable certificates and allows learners to own their credentials permanently. Now featuring an advanced institution reputation system based on certificate quality, student feedback, and verification rates.

## Overview

SkillMint revolutionizes educational credentialing by providing a tamper-proof, blockchain-based system for issuing and verifying skill certificates. Institutions can register, get verified, and issue certificates individually or in batches that recipients truly own and can verify independently. The platform now includes a comprehensive reputation system that scores institutions based on certificate quality feedback, verification rates, and student reviews.

## Features

- **Institution Registration**: Educational institutions can register and get verified on the platform
- **Certificate Issuance**: Verified institutions can issue digital certificates for various skills
- **Batch Certificate Issuance**: Issue multiple certificates in a single transaction for graduation ceremonies or course completions
- **Skill Registry**: Centralized registry of recognized skills and categories
- **Certificate Verification**: Public verification of certificate authenticity
- **User Portfolio**: Each user maintains a permanent portfolio of their certificates
- **Expiration Management**: Optional certificate expiration dates for time-sensitive certifications
- **Revocation System**: Institutions can revoke certificates if needed
- **🆕 Institution Reputation System**: Dynamic scoring based on:
  - Certificate quality ratings from students
  - Relevance scores for issued certificates
  - Verification rates (ratio of active vs revoked certificates)
  - Comprehensive review system with feedback comments
  - Historical reputation tracking

## Smart Contract Functions

### Read-Only Functions
- `get-certificate(certificate-id)` - Retrieve certificate details
- `get-institution-info(institution)` - Get institution information including reputation score
- `get-user-certificates(user)` - Get all certificates for a user
- `get-skill-info(skill-name)` - Get skill category and statistics
- `verify-certificate(certificate-id)` - Check if certificate is valid
- `get-certificate-counter()` - Get the current certificate counter
- `get-certificate-review(certificate-id, reviewer)` - Get specific certificate review
- `get-institution-reputation-score(institution)` - Get institution's current reputation score
- `has-user-reviewed-institution(user, institution)` - Check if user has reviewed an institution
- `get-institution-verification-rate(institution)` - Get institution's certificate verification rate

### Public Functions
- `register-institution(name)` - Register as an educational institution
- `verify-institution(institution)` - Verify an institution (admin only)
- `register-skill(skill-name, category)` - Register a new skill (admin only)
- `issue-certificate(recipient, skill-name, skill-level, expiry-date)` - Issue a single certificate
- `issue-batch-certificates(certificates-data)` - Issue multiple certificates in one transaction
- `review-certificate(certificate-id, quality-score, relevance-score, comment)` - Review a received certificate
- `revoke-certificate(certificate-id)` - Revoke a certificate

## Installation

1. Install Clarinet
2. Clone this repository
3. Run `clarinet check` to verify the contract
4. Deploy to testnet with `clarinet deploy`

## Usage

### For Institutions
1. Register your institution using `register-institution`
2. Wait for admin verification
3. Issue individual certificates using `issue-certificate`
4. Issue multiple certificates for graduation ceremonies using `issue-batch-certificates`
5. Monitor your reputation score through feedback and verification rates
6. Maintain high standards to improve reputation over time

### Batch Certificate Issuance
The `issue-batch-certificates` function allows institutions to issue up to 20 certificates in a single transaction, perfect for:
- Graduation ceremonies
- Course completion batches
- Training program certifications
- Workshop completions

**Example batch data format:**
```clarity
(list 
  {recipient: 'SP..., skill-name: "Web Development", skill-level: "intermediate", expiry-date: (some u1000000)}
  {recipient: 'SP..., skill-name: "Data Science", skill-level: "advanced", expiry-date: none}
)
```

### For Students
1. Receive certificates from verified institutions
2. View your certificates using `get-user-certificates`
3. Share certificate IDs for verification
4. Review certificates you've received to help build institution reputation
5. Provide quality and relevance scores along with comments

### Certificate Review System
Students can review certificates they've received by providing:
- **Quality Score** (0-100): Rate the overall quality of the certification process
- **Relevance Score** (0-100): Rate how relevant the certificate is to the stated skill
- **Comment**: Optional feedback (up to 200 characters)

Reviews directly impact the institution's reputation score and help other users make informed decisions.

### For Verifiers
1. Use `verify-certificate` to check certificate validity
2. Use `get-certificate` to view full certificate details
3. Check institution reputation scores when evaluating certificates
4. Review institution verification rates for additional confidence

## Reputation System

### How It Works
- **Initial Score**: New institutions start with a reputation score of 50/100
- **Review Impact**: Student reviews (quality + relevance scores) influence reputation
- **Verification Rate Bonus**: Higher ratios of active vs revoked certificates improve reputation
- **Dynamic Scoring**: Reputation updates in real-time based on new feedback
- **Historical Tracking**: Reputation changes are tracked over time

### Reputation Factors
1. **Student Feedback (Weight: 10)**: Average of quality and relevance scores from certificate reviews
2. **Verification Rate (Weight: 5)**: Percentage of issued certificates that remain verified
3. **Review Volume**: Total number of reviews received affects score stability

## Data Structure

### Certificate
- Recipient principal
- Issuing institution
- Skill name and level
- Issue and expiry dates
- Verification status

### Institution (Enhanced)
- Name
- Verification status
- Total certificates issued
- **Reputation score** (0-100)
- **Total reviews received**
- **Verification rate** (percentage)

### Certificate Review
- Quality score (0-100)
- Relevance score (0-100)
- Review date
- Comment (up to 200 characters)

### Batch Certificate Data
- List of certificate objects (max 20 per batch)
- Each containing recipient, skill-name, skill-level, and optional expiry-date

## Security Features

- Only verified institutions can issue certificates
- Institution verification requires admin approval
- Certificates are immutable once issued
- Revocation system for emergency situations
- Comprehensive input validation for all functions
- Batch size limits to prevent resource exhaustion
- Overflow protection for certificate counters
- **Review authentication**: Only certificate recipients can review
- **Anti-gaming measures**: Users cannot review their own institutions
- **Score validation**: All reputation scores are bounded between 0-100

## Error Codes

- `u100` - Unauthorized operation
- `u101` - Certificate not found
- `u102` - Already certified
- `u103` - Invalid institution
- `u104` - Invalid skill
- `u105` - List overflow
- `u106` - Invalid recipient
- `u107` - Invalid expiry date
- `u108` - Invalid parameters
- `u109` - Empty batch
- `u110` - Batch too large
- `u111` - Already reviewed (cannot review same certificate twice)
- `u112` - Invalid score (scores must be 0-100)
- `u113` - Cannot review own institution

## API Examples

### Check Institution Reputation
```clarity
(get-institution-reputation-score 'SP1234567890ABCDEF)
;; Returns: u75 (reputation score out of 100)
```

### Review a Certificate
```clarity
(review-certificate u123 u85 u90 "Excellent course content and practical exercises")
;; Quality: 85, Relevance: 90, Comment provided
```

### Get Institution Verification Rate
```clarity
(get-institution-verification-rate 'SP1234567890ABCDEF)
;; Returns: u95 (95% of certificates still verified)
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with clear description

## Recent Updates

### v2.0 - Institution Reputation System
- Added comprehensive reputation scoring for institutions
- Implemented certificate review system for students
- Added verification rate tracking
- Enhanced institution profiles with reputation metrics
- Added anti-gaming measures for review system
- Improved security with additional validation checks