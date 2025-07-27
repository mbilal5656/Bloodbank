# Contributing to Blood Bank Management System

Thank you for your interest in contributing to the Blood Bank Management System! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Bugs
- Use the GitHub issue tracker
- Provide detailed information about the bug
- Include steps to reproduce the issue
- Mention your Flutter/Dart version and platform

### Suggesting Enhancements
- Use the GitHub issue tracker with the "enhancement" label
- Describe the feature and its benefits
- Provide mockups or examples if possible

### Code Contributions
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Ensure all tests pass
6. Submit a pull request

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK 3.32.7 or higher
- Dart SDK 3.8.1 or higher
- Git
- IDE (VS Code, Android Studio, etc.)

### Setup Steps
   ```bash
# Clone the repository
   git clone https://github.com/yourusername/bloodbank.git
   cd bloodbank

# Install dependencies
   flutter pub get

# Run tests
flutter test

# Run the application
flutter run -d web-server --web-port=8080
   ```

## 📝 Code Style Guidelines

### Dart/Flutter Conventions
- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### File Organization
- Place new files in appropriate directories
- Use consistent naming conventions
- Group related functionality together

### Widget Structure
```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

## 🧪 Testing Guidelines

### Writing Tests
- Write tests for new features
- Ensure good test coverage
- Use descriptive test names
- Test both success and failure cases

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

## 🔧 Pull Request Process

### Before Submitting
1. Ensure all tests pass
2. Run `flutter analyze` and fix any issues
3. Update documentation if needed
4. Test on multiple platforms if possible

### Pull Request Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Code refactoring

## Testing
- [ ] All tests pass
- [ ] Tested on web
- [ ] Tested on Android (if applicable)
- [ ] Tested on iOS (if applicable)

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes
```

## 🏷️ Issue Labels

- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements to documentation
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention is needed
- `question` - Further information is requested

## 📚 Documentation

### Code Documentation
- Add comments for complex logic
- Document public APIs
- Use clear and concise language

### README Updates
- Update README.md for new features
- Add screenshots for UI changes
- Update installation instructions if needed

## 🚀 Release Process

### Versioning
We use [Semantic Versioning](https://semver.org/):
- MAJOR version for incompatible API changes
- MINOR version for backwards-compatible functionality
- PATCH version for backwards-compatible bug fixes

### Release Checklist
- [ ] All tests pass
- [ ] Documentation updated
- [ ] Version number updated
- [ ] Changelog updated
- [ ] Release notes prepared

## 🆘 Getting Help

### Questions and Support
- Use GitHub Discussions for questions
- Check existing issues for similar problems
- Join our community chat (if available)

### Contact Information
- Email: mbilalpk56@gmail.com
- GitHub Issues: [Create an issue](https://github.com/yourusername/bloodbank/issues)

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

## 🙏 Acknowledgments

Thank you to all contributors who have helped make this project better!

---

**Happy Contributing! 🎉** 