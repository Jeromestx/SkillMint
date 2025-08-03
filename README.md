# SkillMint 🎓

A decentralized digital skill certification platform built on Stacks blockchain that enables educational institutions to issue verifiable certificates and allows learners to own their credentials permanently.

## Overview

SkillMint revolutionizes educational credentialing by providing a tamper-proof, blockchain-based system for issuing and verifying skill certificates. Institutions can register, get verified, and issue certificates individually or in batches that recipients truly own and can verify independently.

## Features

- **Institution Registration**: Educational institutions can register and get verified on the platform
- **Certificate Issuance**: Verified institutions can issue digital certificates for various skills
- **Batch Certificate Issuance**: Issue multiple certificates in a single transaction for graduation ceremonies or course completions
- **Skill Registry**: Centralized registry of recognized skills and categories
- **Certificate Verification**: Public verification of certificate authenticity
- **User Portfolio**: Each user maintains a permanent portfolio of their certificates
- **Expiration Management**: Optional certificate expiration dates for time-sensitive certifications
- **Revocation System**: Institutions can revoke certificates if needed

## Smart Contract Functions

### Read-Only Functions
- `get-certificate(certificate-id)` - Retrieve certificate details
- `get-institution-info(institution)` - Get institution information
- `get-user-certificates(user)` - Get all certificates for a user
- `get-skill-info(skill-name)` - Get skill category and statistics
- `verify-certificate(certificate-id)` - Check if certificate is valid
- `get-certificate-counter()` - Get the current certificate counter

### Public Functions
- `register-institution(name)` - Register as an educational institution
- `verify-institution(institution)` - Verify an institution (admin only)
- `register-skill(skill-name, category)` - Register a new skill (admin only)
- `issue-certificate(recipient, skill-name, skill-level, expiry-date)` - Issue a single certificate
- `issue-batch-certificates(certificates-data)` - Issue multiple certificates in one transaction
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

### For Verifiers
1. Use `verify-certificate` to check certificate validity
2. Use `get-certificate` to view full certificate details

## Data Structure

### Certificate
- Recipient principal
- Issuing institution
- Skill name and level
- Issue and expiry dates
- Verification status

### Institution
- Name
- Verification status
- Total certificates issued

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

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with clear description

