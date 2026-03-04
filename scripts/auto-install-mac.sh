#!/bin/bash
# Auto-install script for agent-browser on macOS
# This script checks and installs all required dependencies automatically

set -e

echo "🔍 Checking agent-browser installation..."

# Define paths
AB_HOME="$HOME/Documents/agent-browser"
AB_BIN="$AB_HOME/bin/agent-browser"
NEED_BUILD=0

# Check if agent-browser binary exists
if [ -f "$AB_BIN" ]; then
    echo "✓ agent-browser binary found"
    
    # Test if it works
    # Try to get local version
    if AGENT_BROWSER_HOME="$AB_HOME" "$AB_BIN" --version >/dev/null 2>&1; then
        local_version=$(AGENT_BROWSER_HOME="$AB_HOME" "$AB_BIN" --version 2>/dev/null | tr -d '\r\n')
        echo "✓ agent-browser is working (version: $local_version)"

        # If repository exists, check if remote has newer commits
        if [ -d "$AB_HOME" ]; then
            cd "$AB_HOME"
            if command -v git >/dev/null 2>&1; then
                echo "🔍 Checking remote repository for updates..."
                git fetch origin --quiet || true

                # determine remote ref to compare
                remote_ref=""
                if git rev-parse --verify origin/HEAD >/dev/null 2>&1; then
                    remote_ref="origin/HEAD"
                elif git rev-parse --verify origin/main >/dev/null 2>&1; then
                    remote_ref="origin/main"
                elif git rev-parse --verify origin/master >/dev/null 2>&1; then
                    remote_ref="origin/master"
                fi

                if [ -n "$remote_ref" ]; then
                    local_commit=$(git rev-parse HEAD)
                    remote_commit=$(git rev-parse "$remote_ref")
                    if [ "$local_commit" != "$remote_commit" ]; then
                        echo "⚠️  Local repository is behind remote. Pulling latest changes..."
                        git pull --ff-only || git pull
                        NEED_BUILD=1
                        echo "🔁 Pulled latest code; will rebuild later."
                    else
                        echo "✓ agent-browser repository is up-to-date"
                    fi
                else
                    echo "⚠️  Unable to determine remote branch to compare"
                fi
            else
                echo "⚠️  git not available; cannot check remote version"
            fi
        fi

        # If we reached here, binary works (maybe updated) — exit and continue to build step if needed
        # do not exit immediately; let script continue to ensure dependencies and rebuild if NEED_BUILD=1
    else
        echo "⚠️  agent-browser binary exists but not working, rebuilding..."
    fi
fi

# Check if repository exists
if [ ! -d "$AB_HOME" ]; then
    echo "📦 Cloning agent-browser repository..."
    cd "$HOME/Documents"
    git clone https://github.com/vercel-labs/agent-browser.git
    cd agent-browser
else
    echo "✓ Repository found"
    cd "$AB_HOME"
fi

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js first."
    exit 1
fi
echo "✓ Node.js found: $(node --version)"

# Check pnpm
if ! command -v pnpm &> /dev/null; then
    echo "📦 Installing pnpm..."
    npm install -g pnpm
fi
echo "✓ pnpm found: $(pnpm --version)"

# Install dependencies
echo "📦 Installing dependencies..."
pnpm install

# Check Rust/Cargo
if ! command -v cargo &> /dev/null; then
    # Check if cargo exists in default location
    if [ -f "$HOME/.cargo/bin/cargo" ]; then
        echo "✓ Cargo found in ~/.cargo/bin, adding to PATH"
        export PATH="$HOME/.cargo/bin:$PATH"
    else
        echo "❌ Rust/Cargo not found. Installing rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
fi

# Ensure cargo is in PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Check if default toolchain is set
if ! rustup default 2>/dev/null | grep -q "stable"; then
    echo "📦 Setting up Rust stable toolchain..."
    rustup default stable
fi
echo "✓ Rust found: $(rustc --version)"

# Build agent-browser
echo "🔨 Building agent-browser (if needed)..."
# Only build if binary missing or an update/pull indicated a rebuild
if [ "$NEED_BUILD" = "1" ] || [ ! -f "$AB_BIN" ]; then
    npm run build:native
    ln -sf ~/Documents/agent-browser/bin/agent-browser-darwin-x64 ~/Documents/agent-browser/bin/agent-browser
    chmod +x ~/Documents/agent-browser/bin/agent-browser
    ln -sf ~/Documents/agent-browser/bin/agent-browser /usr/local/bin/agent-browser
    echo "✅ Build completed and binary updated"
else
    echo "✓ Build not required"
fi

# Verify installation
if [ -f "$AB_BIN" ]; then
    echo "✅ agent-browser installed successfully!"
    echo "Binary location: $AB_BIN"
else
    echo "❌ Installation failed - binary not found"
    exit 1
fi
