# SkillMint 🎓

A decentralized digital skill certification platform built on Stacks blockchain that enables educational institutions to issue verifiable certificates and allows learners to own their credentials permanently.

## Overview

SkillMint revolutionizes educational credentialing by providing a tamper-proof, blockchain-based system for issuing and verifying skill certificates. Institutions can register, get verified, and issue certificates that recipients truly own and can verify independently.

## Features

- **Institution Registration**: Educational institutions can register and get verified on the platform
- **Certificate Issuance**: Verified institutions can issue digital certificates for various skills
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

### Public Functions
- `register-institution(name)` - Register as an educational institution
- `verify-institution(institution)` - Verify an institution (admin only)
- `register-skill(skill-name, category)` - Register a new skill (admin only)
- `issue-certificate(recipient, skill-name, skill-level, expiry-date)` - Issue a certificate
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
3. Issue certificates to students using `issue-certificate`

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

## Security Features

- Only verified institutions can issue certificates
- Institution verification requires admin approval
- Certificates are immutable once issued
- Revocation system for emergency situations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with clear description
