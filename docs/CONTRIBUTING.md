# Contributing to University Bus Tracker

Thank you for your interest in contributing to the University Bus Tracker project! This document provides guidelines for contributing to this open-source Flutter application.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Guidelines](#development-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)

## 📜 Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

### Our Standards

- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

## 🚀 Getting Started

1. **Fork the repository** to your GitHub account
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/university-bus-tracker.git
   cd university-bus-tracker
   ```
3. **Set up the development environment** following the [README setup instructions](README.md#setup-instructions)
4. **Create a new branch** for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 🛠️ How to Contribute

### Types of Contributions

- **Bug fixes** - Help us fix issues in the codebase
- **Feature development** - Add new features to improve the application
- **Documentation** - Improve or add documentation
- **Testing** - Add or improve test coverage
- **UI/UX improvements** - Enhance the user interface and experience

### Areas We Need Help With

- Real-time GPS tracking implementation
- Advanced map features and route optimization
- Push notification system
- Performance optimizations
- Accessibility improvements
- Unit and integration testing
- Documentation improvements

## 📝 Development Guidelines

### Code Style

- Follow [Dart/Flutter style guidelines](https://dart.dev/guides/language/effective-dart)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### File Structure

```
lib/
├── config/          # Configuration files
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
├── services/        # Business logic and API calls
└── widgets/         # Reusable UI components
```

### Naming Conventions

- **Files**: Use snake_case (e.g., `bus_tracker_screen.dart`)
- **Classes**: Use PascalCase (e.g., `BusTrackerProvider`)
- **Variables/Functions**: Use camelCase (e.g., `getCurrentLocation`)
- **Constants**: Use UPPER_SNAKE_CASE (e.g., `DEFAULT_ZOOM_LEVEL`)

### State Management

This project uses **Provider** for state management. Please follow these guidelines:

- Keep providers focused on specific domains (auth, buses, etc.)
- Use `Consumer` and `Selector` widgets appropriately
- Avoid unnecessary rebuilds by using specific selectors

## 🔄 Pull Request Process

1. **Ensure your code follows** the development guidelines
2. **Update documentation** if you're adding new features
3. **Add tests** if applicable
4. **Update the CHANGELOG.md** with your changes
5. **Create a pull request** with a clear title and description

### PR Title Format
```
type(scope): description

Examples:
feat(tracking): add real-time GPS tracking
fix(auth): resolve signup validation issue
docs(readme): update setup instructions
```

### PR Description Template
```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tested on Android
- [ ] Tested on iOS
- [ ] Tested on Web
- [ ] Added unit tests
- [ ] Added integration tests

## Screenshots (if applicable)
Add screenshots to help explain your changes

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code where necessary
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix/feature works
- [ ] New and existing tests pass locally
```

## 🐛 Issue Reporting

### Before Creating an Issue

1. **Search existing issues** to avoid duplicates
2. **Check the documentation** for common solutions
3. **Test with the latest version** of the app

### Bug Report Template

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment:**
- Device: [e.g., iPhone 12, Samsung Galaxy S21]
- OS: [e.g., iOS 15.1, Android 12]
- App Version: [e.g., 1.0.0]
- Flutter Version: [e.g., 3.10.0]

**Additional context**
Add any other context about the problem here.
```

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
A clear description of what the problem is.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
A clear description of any alternative solutions you've considered.

**Additional context**
Add any other context or screenshots about the feature request here.
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Writing Tests

- Write unit tests for business logic
- Write widget tests for UI components
- Write integration tests for complete user flows
- Aim for good test coverage, especially for critical features

## 📱 Platform-Specific Guidelines

### Android
- Test on multiple Android versions (API 21+)
- Ensure proper permissions are requested
- Test on different screen sizes

### iOS
- Test on multiple iOS versions (iOS 11+)
- Ensure proper Info.plist configurations
- Test on different device sizes

### Web
- Ensure responsive design works
- Test on major browsers (Chrome, Firefox, Safari)
- Handle web-specific limitations

## 🔧 Development Tools

### Recommended VS Code Extensions
- Dart
- Flutter
- Bracket Pair Colorizer
- Flutter Tree
- Pubspec Assist

### Useful Commands

```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Check for unused dependencies
flutter pub deps

# Update dependencies
flutter pub upgrade
```

## 📞 Getting Help

- **GitHub Issues**: For bug reports and feature requests
- **Discussions**: For general questions and community chat
- **Documentation**: Check the README and code comments

## 🙏 Recognition

Contributors will be recognized in the project's README file. We appreciate all contributions, no matter how small!

---

Thank you for contributing to the University Bus Tracker project! 🚌✨
