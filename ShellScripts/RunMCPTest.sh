#!/usr/bin/env zsh

# Simple script to run the date generator test suite
# Usage: ./run-tests.sh

# Set MCP Directory
cd $HOME/mcp-servers/date-generator

echo "🧪 Running Date Generator Test Suite..."
echo "========================================"

# Check if tsx is available
if ! command -v tsx &> /dev/null; then
    echo "❌ Error: tsx is not installed. Please run 'npm install' first."
    exit 1
fi

# Check if test.ts exists
if [ ! -f "test.ts" ]; then
    echo "❌ Error: test.ts not found in current directory."
    exit 1
fi

# Run the tests
npm test

# Check exit code
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Tests completed successfully!"
else
    echo ""
    echo "❌ Tests failed with exit code $?"
    exit 1
fi
