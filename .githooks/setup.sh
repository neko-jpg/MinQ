#!/bin/sh

# Setup git hooks
echo "Setting up git hooks..."

# Get the git directory
GIT_DIR=$(git rev-parse --git-dir)

# Create hooks directory if it doesn't exist
mkdir -p "$GIT_DIR/hooks"

# Copy pre-commit hook
cp .githooks/pre-commit "$GIT_DIR/hooks/pre-commit"
chmod +x "$GIT_DIR/hooks/pre-commit"

echo "✅ Git hooks installed successfully!"
echo "To skip hooks temporarily, use: git commit --no-verify"
