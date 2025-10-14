# Contributing to k2_connect_flutter

🎉 Thank you for considering contributing to **k2_connect_flutter**!  
Your contributions help improve the official Kopo Kopo K2 Connect SDK for Flutter.  

---

## How to Contribute

### 1. Fork & Clone
- Fork the repository on GitHub
- Clone your fork locally:
```bash
git clone https://github.com/kopo-kopo/k2-connect-flutter.git
cd k2-connect-flutter
```
2. Create a Branch
- Use a descriptive branch name:
```bash
git checkout -b feature/your-feature-name
```
3. Make Changes
- Write clear, well-structured code
- Follow Effective Dart guidelines
- Run formatters and linters before committing:
```bash
dart format .
flutter analyze
```
4. Write & Run Tests
- Add tests for new features in test/
- Run all tests:
```bash
flutter test
```
- If using mockito:
```bash
flutter pub run build_runner build
```

### Commit Guidelines
Use clear commit messages:
- `feat: add STK Push payment initiation`
- `fix: handle network timeout gracefully`
- `docs: update usage example in README`

### Pull Requests
1. Push your branch to your fork:

```bash
git push origin feature/your-feature-name
```
2. Open a Pull Request (PR) against the `development` branch of this repo

3. Ensure your PR description:
- Explains why the change is needed
- Shows what was changed
- Includes screenshots/logs if relevant

### Code of Conduct
By participating in this project, you agree to uphold the Contributor Covenant.
Be respectful, inclusive, and constructive.