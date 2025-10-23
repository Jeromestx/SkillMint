# SkillMint 🎓

A decentralized digital skill certification platform built on Stacks blockchain that enables educational institutions to issue verifiable certificates and allows learners to own their credentials permanently. Now featuring an advanced institution reputation system and standardized certificate templates.

## Overview

SkillMint revolutionizes educational credentialing by providing a tamper-proof, blockchain-based system for issuing and verifying skill certificates. Institutions can register, get verified, and issue certificates individually, in batches, or from standardized templates that recipients truly own and can verify independently. The platform includes a comprehensive reputation system that scores institutions based on certificate quality feedback, verification rates, and student reviews.

## Features

### Core Features
- **Institution Registration**: Educational institutions can register and get verified on the platform
- **Certificate Issuance**: Verified institutions can issue digital certificates for various skills
- **Batch Certificate Issuance**: Issue multiple certificates in a single transaction for graduation ceremonies or course completions
- **Skill Registry**: Centralized registry of recognized skills and categories
- **Certificate Verification**: Public verification of certificate authenticity
- **User Portfolio**: Each user maintains a permanent portfolio of their certificates
- **Expiration Management**: Optional certificate expiration dates for time-sensitive certifications
- **Revocation System**: Institutions can revoke certificates if needed

### Reputation System
- **Dynamic Institution Scoring**: Based on certificate quality ratings from students
- **Verification Rate Tracking**: Monitors ratio of active vs revoked certificates
- **Comprehensive Review System**: Students can provide feedback with quality and relevance scores
- **Historical Reputation Tracking**: Track institution performance over time

### 🆕 Certificate Templates (v2.1)
- **Standardized Templates**: Create reusable certificate templates for different credential types
- **Template Types**: Support for degrees, courses, workshops, certifications, training programs, and bootcamps
- **Automated Certificate Generation**: Issue certificates quickly using pre-configured templates
- **Template Management**: Institutions can create, manage, and deactivate their templates
- **Usage Analytics**: Track how many times each template has been used
- **Flexible Configuration**: Set default skill levels, expiration durations, and detailed descriptions
- **Template Overrides**: Customize skill levels when issuing from templates

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
- `get-template(template-id)` - 🆕 Retrieve certificate template details
- `get-template-counter()` - 🆕 Get the current template counter
- `is-institution-template(institution, template-id)` - 🆕 Check if template belongs to institution

### Public Functions

#### Institution & Skill Management
- `register-institution(name)` - Register as an educational institution
- `verify-institution(institution)` - Verify an institution (admin only)
- `register-skill(skill-name, category)` - Register a new skill (admin only)

#### Certificate Issuance
- `issue-certificate(recipient, skill-name, skill-level, expiry-date)` - Issue a single certificate
- `issue-batch-certificates(certificates-data)` - Issue multiple certificates in one transaction
- `issue-certificate-from-template(recipient, template-id, skill-level-override)` - 🆕 Issue certificate from template

#### Template Management
- `create-certificate-template(name, template-type, skill-name, default-skill-level, duration-blocks, description)` - 🆕 Create a new certificate template
- `deactivate-template(template-id)` - 🆕 Deactivate a template

#### Reviews & Revocation
- `review-certificate(certificate-id, quality-score, relevance-score, comment)` - Review a received certificate
- `revoke-certificate(certificate-id)` - Revoke a certificate

## Installation

1. Install Clarinet
2. Clone this repository
3. Run `clarinet check` to verify the contract
4. Deploy to testnet with `clarinet deploy`

## Usage

### For Institutions

#### 1. Registration & Setup
1. Register your institution using `register-institution`
2. Wait for admin verification
3. Create certificate templates for your common credentials

#### 2. Create Certificate Templates
```clarity
(create-certificate-template 
  "Bachelor of Science in Computer Science"
  "degree"
  "Computer Science"
  "expert"
  (some u52560)  ;; ~1 year in blocks
  "Four-year undergraduate degree program covering fundamentals of computer science, algorithms, data structures, and software engineering."
)
```

**Supported Template Types:**
- `degree` - Academic degrees (Bachelor's, Master's, PhD)
- `course` - Individual courses or classes
- `workshop` - Short-term workshops and seminars
- `certification` - Professional certifications
- `training` - Training programs
- `bootcamp` - Intensive bootcamp programs

#### 3. Issue Certificates

**From Template:**
```clarity
;; Use default skill level
(issue-certificate-from-template 'SP123... u1 none)

;; Override skill level
(issue-certificate-from-template 'SP123... u1 (some "advanced"))
```

**Individual Certificate:**
```clarity
(issue-certificate 'SP123... "Web Development" "intermediate" (some u1000000))
```

**Batch Issuance:**
```clarity
(issue-batch-certificates (list 
  {recipient: 'SP..., skill-name: "Web Development", skill-level: "intermediate", expiry-date: (some u1000000)}
  {recipient: 'SP..., skill-name: "Data Science", skill-level: "advanced", expiry-date: none}
))
```

#### 4. Manage Your Reputation
- Monitor your reputation score through feedback and verification rates
- Maintain high standards to improve reputation over time
- Respond to student feedback by improving certificate quality

### For Students

#### 1. Receive & Manage Certificates
1. Receive certificates from verified institutions
2. View your certificates using `get-user-certificates`
3. Share certificate IDs for verification
4. Check if certificates were issued from official templates

#### 2. Review Certificates
Provide feedback to help build institution reputation:
```clarity
(review-certificate 
  u123                    ;; certificate-id
  u85                     ;; quality-score (0-100)
  u90                     ;; relevance-score (0-100)
  "Excellent course content and practical exercises"
)
```

**Review Criteria:**
- **Quality Score** (0-100): Rate the overall quality of the certification process
- **Relevance Score** (0-100): Rate how relevant the certificate is to the stated skill
- **Comment**: Optional feedback (up to 200 characters)

### For Verifiers
1. Use `verify-certificate` to check certificate validity
2. Use `get-certificate` to view full certificate details
3. Check if certificate was issued from an official template
4. Review institution reputation scores when evaluating certificates
5. Check institution verification rates for additional confidence
6. View template details to understand certification standards

## Data Structures

### Certificate (Enhanced)
- Recipient principal
- Issuing institution
- Skill name and level
- Issue and expiry dates
- Verification status
- **Template ID** (optional - links to template used)

### Certificate Template 🆕
- Name (e.g., "Bachelor of Science in Computer Science")
- Template type (degree, course, workshop, etc.)
- Skill name
- Default skill level
- Duration in blocks (optional)
- Description (up to 500 characters)
- Creator (institution principal)
- Active status
- Times used (usage counter)

### Institution
- Name
- Verification status
- Total certificates issued
- Reputation score (0-100)
- Total reviews received
- Verification rate (percentage)

### Certificate Review
- Quality score (0-100)
- Relevance score (0-100)
- Review date
- Comment (up to 200 characters)

## Certificate Template Benefits

### For Institutions
- **Consistency**: Ensure all certificates for the same program follow the same standards
- **Efficiency**: Issue certificates quickly without re-entering common data
- **Professionalism**: Maintain standardized credentials across all graduates
- **Tracking**: Monitor which templates are most used
- **Flexibility**: Override defaults when needed for special cases

### For Students
- **Trust**: Know that your certificate follows institutional standards
- **Verification**: Easier verification of credential authenticity
- **Context**: Templates provide additional information about the certification

### For Verifiers
- **Transparency**: Understand what the certificate represents
- **Standards**: Verify certificates against institutional templates
- **Confidence**: Know the certificate follows established patterns

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

## Security Features

- Only verified institutions can issue certificates
- Institution verification requires admin approval
- Certificates are immutable once issued
- Revocation system for emergency situations
- Comprehensive input validation for all functions
- Batch size limits to prevent resource exhaustion
- Overflow protection for certificate and template counters
- **Review authentication**: Only certificate recipients can review
- **Anti-gaming measures**: Users cannot review their own institutions
- **Score validation**: All reputation scores are bounded between 0-100
- **Template ownership**: Only template creators can manage their templates
- **Template validation**: Ensures all template data is valid before creation

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
- `u114` - 🆕 Template not found
- `u115` - 🆕 Template already exists
- `u116` - 🆕 Invalid template parameters

## API Examples

### Certificate Template Operations

#### Create a Degree Template
```clarity
(create-certificate-template 
  "Master of Business Administration"
  "degree"
  "Business Management"
  "expert"
  (some u78840)  ;; ~1.5 years in blocks
  "Graduate-level business degree focusing on leadership, strategy, finance, and operations management."
)
```

#### Create a Course Template
```clarity
(create-certificate-template 
  "Introduction to Python Programming"
  "course"
  "Python Programming"
  "beginner"
  (some u2160)  ;; ~2 weeks in blocks
  "Beginner-friendly course covering Python basics, data types, control structures, and functions."
)
```

#### Create a Workshop Template
```clarity
(create-certificate-template 
  "Advanced React Patterns Workshop"
  "workshop"
  "React Development"
  "advanced"
  (some u360)  ;; ~2.5 days in blocks
  "Intensive workshop on advanced React patterns including hooks, context, and performance optimization."
)
```

#### Issue from Template
```clarity
;; Issue with default settings
(issue-certificate-from-template 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKQ9H6DPR u5 none)

;; Issue with custom skill level
(issue-certificate-from-template 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKQ9H6DPR u5 (some "intermediate"))
```

#### Deactivate Template
```clarity
(deactivate-template u5)
```

### Reputation & Review Operations

#### Check Institution Reputation
```clarity
(get-institution-reputation-score 'SP1234567890ABCDEF)
;; Returns: u75 (reputation score out of 100)
```

#### Get Verification Rate
```clarity
(get-institution-verification-rate 'SP1234567890ABCDEF)
;; Returns: u95 (95% of certificates still verified)
```

#### Get Template Details
```clarity
(get-template u5)
;; Returns template information including usage statistics
```

## Use Cases

### University Degrees
Create templates for each degree program (BS, MS, PhD) with appropriate durations and skill levels.

### Online Course Platforms
Create templates for each course with standardized descriptions and beginner/intermediate/advanced levels.

### Professional Certifications
Create templates for professional credentials with specific expiration periods.

### Corporate Training
Create templates for internal training programs with company-specific standards.

### Bootcamps & Workshops
Create templates for intensive programs with short durations and practical focus.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with clear description

## Recent Updates

### v2.1 - Certificate Templates
- Added certificate template system for standardized credentials
- Support for 6 template types: degree, course, workshop, certification, training, bootcamp
- Template creation and management functions
- Ability to issue certificates from templates with optional overrides
- Template usage tracking and analytics
- Enhanced certificate data structure to link to templates
- Additional validation for template parameters

### v2.0 - Institution Reputation System
- Added comprehensive reputation scoring for institutions
- Implemented certificate review system for students
- Added verification rate tracking
- Enhanced institution profiles with reputation metrics
- Added anti-gaming measures for review system
- Improved security with additional validation checks
