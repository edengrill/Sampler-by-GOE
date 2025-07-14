#!/bin/bash

# Quick save script for Simple Audio Sampler
# Usage: ./save.sh "Your commit message"

if [ -z "$1" ]; then
    echo "❌ Please provide a commit message"
    echo "Usage: ./save.sh \"Your commit message\""
    exit 1
fi

echo "📁 Checking for changes..."
git status

echo "➕ Adding all changes..."
git add .

echo "💾 Committing with message: $1"
git commit -m "$1"

echo "🚀 Pushing to GitHub..."
git push

echo "✅ Done! Changes saved to GitHub"