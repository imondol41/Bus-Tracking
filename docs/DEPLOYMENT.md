# 🚀 Deployment Guide

This guide covers deploying the University Bus Tracker application to various platforms and environments.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Configuration](#environment-configuration)
3. [Web Deployment](#web-deployment)
4. [Android Deployment](#android-deployment)
5. [iOS Deployment](#ios-deployment)
6. [Backend Deployment](#backend-deployment)
7. [CI/CD Pipeline](#cicd-pipeline)
8. [Monitoring & Maintenance](#monitoring--maintenance)

## Prerequisites

### Required Accounts
- [Supabase](https://supabase.com) - Backend services
- [Mapbox](https://mapbox.com) - Map services (optional)
- [Google Play Console](https://play.google.com/console) - Android distribution
- [Apple Developer](https://developer.apple.com) - iOS distribution
- [GitHub](https://github.com) - Source control and CI/CD

### Development Environment
- Flutter SDK 3.10+
- Git version control
- Platform-specific development tools

## Environment Configuration

### 1. Production Configuration

Create production environment configuration:

```dart
// lib/config/supabase_config.dart
class SupabaseConfig {
  static const String url = 'YOUR_PRODUCTION_SUPABASE_URL';
  static const String anonKey = 'YOUR_PRODUCTION_SUPABASE_ANON_KEY';
}
```

### 2. Environment Variables

For CI/CD and secure deployment:

```bash
# .env.production
SUPABASE_URL=your_production_url
SUPABASE_ANON_KEY=your_production_key
MAPBOX_API_KEY=your_mapbox_key
```

## Web Deployment

### Option 1: GitHub Pages (Free)

1. **Build for production:**
   ```bash
   flutter build web --release
   ```

2. **Deploy with GitHub Actions:**
   - Push to `main` branch
   - GitHub Actions automatically deploys to GitHub Pages
   - Access at: `https://username.github.io/university-bus-tracker`

### Option 2: Vercel (Recommended)

1. **Install Vercel CLI:**
   ```bash
   npm i -g vercel
   ```

2. **Deploy:**
   ```bash
   flutter build web --release
   vercel --prod build/web
   ```

3. **Configure Custom Domain:**
   - Add domain in Vercel dashboard
   - Update DNS records

### Option 3: Firebase Hosting

1. **Install Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

2. **Initialize Firebase:**
   ```bash
   firebase init hosting
   ```

3. **Deploy:**
   ```bash
   flutter build web --release
   firebase deploy
   ```

## Android Deployment

### 1. Prepare for Release

#### Generate Keystore
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

#### Configure Signing
Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

### 2. Build Release APK

```bash
# APK for direct distribution
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```

### 3. Google Play Store Deployment

#### Manual Upload
1. Go to [Google Play Console](https://play.google.com/console)
2. Create new application
3. Upload AAB file from `build/app/outputs/bundle/release/`
4. Fill in store listing details
5. Submit for review

#### Automated Deployment
Use Fastlane or GitHub Actions for automated Play Store deployment.

## iOS Deployment

### 1. Xcode Configuration

```bash
# Open iOS project
open ios/Runner.xcworkspace
```

In Xcode:
- Update Bundle Identifier
- Configure signing certificates
- Set deployment target (iOS 11.0+)

### 2. Build for Release

```bash
flutter build ios --release
```

### 3. App Store Deployment

#### Using Xcode
1. Open `ios/Runner.xcworkspace`
2. Select "Any iOS Device" as target
3. Product → Archive
4. Upload to App Store Connect

#### Using Fastlane
```bash
cd ios
fastlane deliver
```

## Backend Deployment

### Supabase Production Setup

#### 1. Database Migration
```sql
-- Run production schema
-- Copy from docs/supabase_schema.sql
-- Execute in Supabase SQL Editor
```

#### 2. Authentication Configuration
- Configure email templates
- Set up custom domain
- Configure OAuth providers (if needed)

#### 3. Security Settings
- Enable RLS on all tables
- Configure CORS for web domain
- Set up API rate limiting

#### 4. Environment Variables
```bash
# Supabase Dashboard → Settings → Environment Variables
UNIVERSITY_NAME=Your University Name
DEFAULT_LOCATION_LAT=23.7489
DEFAULT_LOCATION_LNG=90.3708
ADMIN_VERIFICATION_CODE=CSE BATCH 28
```

## CI/CD Pipeline

### GitHub Actions Setup

The project includes automated CI/CD pipeline in `.github/workflows/ci-cd.yml`:

#### Features
- ✅ Automated testing on push/PR
- ✅ Code quality checks
- ✅ Multi-platform builds
- ✅ Automated deployment to GitHub Pages
- ✅ Release artifact generation

#### Secrets Configuration
Add these secrets in GitHub repository settings:

```bash
# Repository Settings → Secrets and Variables → Actions
SUPABASE_URL=your_production_url
SUPABASE_ANON_KEY=your_production_key
MAPBOX_API_KEY=your_mapbox_key
```

### Manual Deployment Commands

```bash
# Test and build
flutter test
flutter analyze
flutter build web --release
flutter build apk --release
flutter build appbundle --release

# Deploy to staging
# Deploy to production
```

## Monitoring & Maintenance

### 1. Application Monitoring

#### Supabase Dashboard
- Monitor database performance
- Check API usage and quotas
- Review authentication metrics
- Monitor real-time connections

#### Flutter Crashlytics (Optional)
```yaml
# Add to pubspec.yaml
dependencies:
  firebase_crashlytics: ^3.4.9
```

### 2. Performance Monitoring

#### Key Metrics to Track
- App startup time
- API response times
- Database query performance
- Real-time subscription health
- User engagement metrics

### 3. Update Strategy

#### Regular Updates
- **Security Updates**: Monthly security patches
- **Feature Updates**: Quarterly feature releases
- **Bug Fixes**: As needed hot fixes

#### Update Process
1. Test in development environment
2. Deploy to staging
3. User acceptance testing
4. Production deployment
5. Monitor for issues

### 4. Backup & Recovery

#### Database Backups
- Supabase automatic daily backups
- Manual backups before major updates
- Export user data regularly

#### Recovery Plan
1. Identify issue severity
2. Rollback if necessary
3. Fix and redeploy
4. Communicate with users

## Domain & SSL

### Custom Domain Setup

#### 1. DNS Configuration
```bash
# Add CNAME record
CNAME bus-tracker your-deployment-url
```

#### 2. SSL Certificate
- Automatic with most platforms (Vercel, Firebase)
- Manual setup for custom hosting

## Environment-Specific Configurations

### Development
- Local Supabase instance (optional)
- Debug logging enabled
- Hot reload enabled
- Mock data for testing

### Staging
- Staging Supabase instance
- Limited logging
- Production-like data
- User acceptance testing

### Production
- Production Supabase instance
- Error reporting only
- Real user data
- Performance monitoring

## Security Checklist

### Pre-Deployment Security Review
- [ ] No hardcoded secrets in code
- [ ] Environment variables properly configured
- [ ] Database RLS policies tested
- [ ] API endpoints secured
- [ ] Input validation implemented
- [ ] HTTPS enforced
- [ ] CORS properly configured
- [ ] Authentication flows tested

### Post-Deployment Security
- [ ] Monitor for vulnerabilities
- [ ] Regular dependency updates
- [ ] Security audit logs reviewed
- [ ] User access patterns monitored

## Troubleshooting

### Common Deployment Issues

#### Web Deployment
- **CORS errors**: Configure Supabase CORS settings
- **Build failures**: Check Flutter web compatibility
- **Performance issues**: Optimize for web platform

#### Mobile Deployment
- **Signing issues**: Verify certificates and profiles
- **Store rejection**: Review store guidelines
- **Performance**: Test on low-end devices

#### Backend Issues
- **Database connection**: Check Supabase status
- **Rate limiting**: Monitor API usage
- **RLS policies**: Test permissions thoroughly

### Getting Help

1. **Documentation**: Check platform-specific docs
2. **Community**: Flutter, Supabase communities
3. **Support**: Platform-specific support channels
4. **Issues**: Create issues in this repository

---

**Success Checklist:**

- [ ] All environments configured
- [ ] CI/CD pipeline working
- [ ] Security measures in place
- [ ] Monitoring enabled
- [ ] Backup strategy implemented
- [ ] Documentation updated
- [ ] Team trained on deployment process

🎉 **Congratulations!** Your University Bus Tracker is now successfully deployed and ready for users!
