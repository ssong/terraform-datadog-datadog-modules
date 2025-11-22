# Contributing Guide

## Commit Message Format

This project uses [Conventional Commits](https://www.conventionalcommits.org/) for automated versioning and changelog generation.

### Commit Message Structure

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- **feat**: A new feature (triggers MINOR version bump)
- **fix**: A bug fix (triggers PATCH version bump)
- **docs**: Documentation only changes (triggers PATCH version bump)
- **style**: Changes that don't affect code meaning (formatting, etc.)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Performance improvement (triggers PATCH version bump)
- **test**: Adding or updating tests
- **build**: Changes to build system or dependencies
- **ci**: Changes to CI configuration
- **chore**: Other changes that don't modify src or test files
- **revert**: Reverts a previous commit

### Breaking Changes

Add `!` after the type or include `BREAKING CHANGE:` in the footer to trigger a MAJOR version bump:

```
feat!: remove deprecated monitor configuration

BREAKING CHANGE: The `legacy_config` variable has been removed.
Use `modern_config` instead.
```

### Examples

```bash
# Feature (bumps 1.0.0 -> 1.1.0)
git commit -m "feat: add 5xx error monitor to API Gateway module"

# Bug fix (bumps 1.0.0 -> 1.0.1)
git commit -m "fix: correct SQS monitor query aggregation"

# Documentation (bumps 1.0.0 -> 1.0.1)
git commit -m "docs: update README with new monitor examples"

# Breaking change (bumps 1.0.0 -> 2.0.0)
git commit -m "feat!: change default criticality to high"

# With scope
git commit -m "feat(lambda): add cold start duration monitor"

# With body
git commit -m "fix(rds): resolve replica lag widget rendering

The replica lag widget was using an invalid 'visible' attribute.
Changed to use dynamic block for conditional rendering."
```

## Pull Request Process

1. **Create a feature branch**:
   ```bash
   git checkout -b feat/add-new-monitor
   ```

2. **Make your changes** and commit using conventional commits

3. **Push and create PR**:
   ```bash
   git push origin feat/add-new-monitor
   ```

4. **PR validation**:
   - Terraform validation runs automatically
   - Commit messages are validated
   - All checks must pass before merge

5. **Merge to main**:
   - Use "Squash and merge" to keep history clean
   - Ensure the squashed commit message follows conventional commits
   - Release workflow will automatically:
     - Determine version bump
     - Generate changelog
     - Create GitHub release
     - Update CHANGELOG.md

## Release Process

Releases are **fully automated**:

1. Merge PR to `main` with conventional commit message
2. GitHub Actions runs semantic-release
3. Version is bumped based on commit types
4. CHANGELOG.md is updated
5. GitHub release is created with release notes
6. Git tag is created (e.g., `v1.2.0`)

**No manual intervention needed!**

## Version Bumping Rules

| Commit Type | Version Bump | Example |
|-------------|--------------|---------|
| `feat:` | MINOR (1.0.0 → 1.1.0) | New monitor added |
| `fix:` | PATCH (1.0.0 → 1.0.1) | Bug fix |
| `perf:` | PATCH (1.0.0 → 1.0.1) | Performance improvement |
| `docs:` | PATCH (1.0.0 → 1.0.1) | Documentation update |
| `BREAKING CHANGE:` | MAJOR (1.0.0 → 2.0.0) | Breaking change |
| `chore:`, `ci:`, `test:` | No release | Internal changes |

## Tips

- **Use descriptive commit messages**: They become your changelog
- **One logical change per commit**: Makes history clearer
- **Reference issues**: Use `fixes #123` in commit body
- **Test before committing**: Run `terraform validate` locally
- **Keep commits atomic**: Each commit should be a complete, working change
