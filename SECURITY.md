# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Which versions are eligible for receiving such patches depends on the CVSS v3.0 Rating:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

The University Bus Tracker team and community take security bugs seriously. We appreciate your efforts to responsibly disclose your findings, and will make every effort to acknowledge your contributions.

### Where to Report

Please report security vulnerabilities by:

1. **Email**: Send an email to the project maintainers
2. **GitHub Security Advisory**: Use GitHub's security advisory feature (preferred)
3. **Private Issue**: Create a private issue in the repository

### What to Include

Please include the following information in your report:

- **Description**: A clear description of the vulnerability
- **Impact**: The potential impact of the vulnerability
- **Steps to Reproduce**: Detailed steps to reproduce the issue
- **Proof of Concept**: If possible, provide a minimal proof of concept
- **Suggested Fix**: If you have ideas for fixing the issue

### Response Timeline

- **Acknowledgment**: We aim to acknowledge reports within 48 hours
- **Initial Assessment**: Initial assessment within 5 business days
- **Status Updates**: Regular updates every 5 business days
- **Resolution**: We aim to resolve critical issues within 30 days

### Security Measures

The University Bus Tracker implements several security measures:

#### Authentication & Authorization
- Email verification required for all accounts
- Role-based access control (RBAC)
- Secure password requirements
- Admin verification process

#### Data Protection
- All data encrypted in transit (HTTPS)
- Database access through secure APIs only
- Row Level Security (RLS) in Supabase
- Input validation and sanitization

#### API Security
- API keys stored securely in environment variables
- Rate limiting on API endpoints
- CORS properly configured
- No sensitive data in client-side code

#### Mobile App Security
- Secure storage for tokens
- Certificate pinning (planned)
- Obfuscation for release builds
- No hardcoded secrets

### Known Security Considerations

#### Current Limitations
- Web deployment may expose some configuration
- Real-time features require careful permission management
- Location data handling requires privacy consideration

#### Planned Improvements
- Enhanced encryption for sensitive data
- Audit logging for admin actions
- Two-factor authentication (2FA)
- Advanced threat detection

### Security Best Practices for Contributors

When contributing to this project, please follow these security guidelines:

1. **Never commit sensitive data** (API keys, passwords, tokens)
2. **Use environment variables** for configuration
3. **Validate all user inputs** on both client and server
4. **Follow secure coding practices** for Dart/Flutter
5. **Test security features** thoroughly
6. **Review dependencies** for known vulnerabilities

### Security Tools

We recommend using these tools during development:

- **Flutter Security**: `flutter analyze` for static analysis
- **Dependency Scanning**: Regular `flutter pub deps` checks
- **Code Review**: All changes require review
- **Automated Testing**: Security-focused unit tests

### Disclosure Policy

- **Responsible Disclosure**: We follow responsible disclosure practices
- **Credit**: Security researchers will be credited in our acknowledgments
- **Coordination**: We coordinate with researchers on disclosure timing
- **Public Advisory**: Security advisories published after fixes

## Contact

For security-related questions or concerns, please contact the project maintainers through the appropriate channels mentioned above.

Thank you for helping keep University Bus Tracker and our users safe!
