# Chrome Browser Automation

Control and automate Google Chrome browser using agent-browser with Chrome DevTools Protocol (CDP). This project provides scripts and documentation for connecting to and controlling your existing Chrome browser instance with real-time visual feedback.

## Features

- **Real-time browser control**: See automation actions live in your Chrome window
- **Persistent profiles**: Preserve login states, cookies, and settings across sessions
- **Cross-platform**: Support for macOS and Windows
- **Automatic dependency installation**: One-click setup scripts handle all requirements
- **Element interaction**: Click, fill, scroll, and interact with page elements
- **Visual feedback**: Screenshots and state reporting after each action

## Prerequisites

- **Google Chrome** installed on your system
- **Node.js** (for agent-browser dependencies)
- **Git** (for cloning repositories)
- **Internet connection** (for downloading dependencies)

## Quick Start

### 1. Clone this repository
```bash
git clone <repository-url>
cd chrome-automation
```

### 2. Run the auto-installation script for your platform

**macOS:**
```bash
bash scripts/auto-install-mac.sh
```

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File scripts/auto-install-windows.ps1
```

The installation script will:
- Check for existing agent-browser installation
- Clone the agent-browser repository if needed
- Install Node.js dependencies (pnpm)
- Install and configure Rust toolchain (if needed)
- Build the native binary
- Verify installation success

### 3. Start Chrome with persistent profile

**macOS:**
```bash
bash scripts/start-chrome-mac.sh
```

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File scripts/start-chrome-windows.ps1
```

This creates a dedicated automation profile that preserves your login states, cookies, and settings. You only need to log in once!

### 4. Test the connection
```bash
cd ~/Documents/agent-browser
AGENT_BROWSER_HOME=~/Documents/agent-browser ./bin/agent-browser --cdp 9222 get url
```

## Project Structure

```
chrome-automation/
├── README.md                   # This file
├── SKILL.md                    # Detailed skill documentation
├── scripts/                    # Automation scripts
│   ├── auto-install-mac.sh     # macOS auto-installation
│   ├── auto-install-windows.ps1 # Windows auto-installation
│   ├── start-chrome-mac.sh     # Start Chrome with persistent profile (macOS)
│   ├── start-chrome-windows.ps1 # Start Chrome with persistent profile (Windows)
│   ├── connect_chrome.sh       # Connect to existing Chrome instance
│   ├── setup.sh                # Setup helper script
│   └── README.md               # Script-specific documentation
├── references/                 # Detailed reference guides
│   ├── setup-mac.md           # macOS setup guide
│   ├── setup-windows.md       # Windows setup guide
│   ├── commands.md            # agent-browser command reference
│   └── troubleshooting.md     # Troubleshooting guide
└── install-scripts.md         # Installation script documentation
```

## Scripts Overview

### Installation Scripts
- **`auto-install-mac.sh`**: Complete macOS setup - checks/installs agent-browser, dependencies, and Rust toolchain
- **`auto-install-windows.ps1`**: Windows PowerShell equivalent with Rust installation

### Chrome Management Scripts
- **`start-chrome-mac.sh`**: Start Chrome with dedicated automation profile (preserves login states)
- **`start-chrome-windows.ps1`**: Windows equivalent with profile management
- **`connect_chrome.sh`**: Connect to existing Chrome instance or start new one

### Helper Scripts
- **`setup.sh`**: Additional setup and verification utilities

## Usage Examples

### Basic Navigation
```bash
cd ~/Documents/agent-browser
export AB_HOME=~/Documents/agent-browser

# Open a website
AGENT_BROWSER_HOME=$AB_HOME ./bin/agent-browser --cdp 9222 open https://example.com
sleep 2

# Get interactive elements
AGENT_BROWSER_HOME=$AB_HOME ./bin/agent-browser --cdp 9222 snapshot -i

# Take screenshot
AGENT_BROWSER_HOME=$AB_HOME ./bin/agent-browser --cdp 9222 screenshot ~/Desktop/state.png
```

### Form Automation
```bash
# Navigate to form
AGENT_BROWSER_HOME=$AB_HOME ./bin/agent-browser --cdp 9222 open https://example.com/form

# Get form fields
AGENT_BROWSER_HOME=$AB_HOME ./bin/agent-browser --cdp 9222 snapshot -i

# Fill and submit
AGENT_BROWSER_HOME=$AB_HOME ./bin/agent-browser --cdp 9222 fill @e1 "John Doe"
AGENT_BROWSER_HOME=$AB_HOME ./bin/agent-browser --cdp 9222 fill @e2 "john@example.com"
AGENT_BROWSER_HOME=$AB_HOME ./bin/agent-browser --cdp 9222 click @e3

# Capture result
sleep 2
AGENT_BROWSER_HOME=$AB_HOME ./bin/agent-browser --cdp 9222 screenshot ~/Desktop/submitted.png
```

### Web Search
```bash
# Open search site
AGENT_BROWSER_HOME=$AB_HOME ./bin/agent-browser --cdp 9222 open https://www.google.com
sleep 2

# Get search box
AGENT_BROWSER_HOME=$AB_HOME ./bin/agent-browser --cdp 9222 snapshot -i

# Search and capture
AGENT_BROWSER_HOME=$AB_HOME ./bin/agent-browser --cdp 9222 fill @e1 "search query"
AGENT_BROWSER_HOME=$AB_HOME ./bin/agent-browser --cdp 9222 press Enter
sleep 2
AGENT_BROWSER_HOME=$AB_HOME ./bin/agent-browser --cdp 9222 screenshot ~/Desktop/results.png
```

## Command Reference

### Essential Commands
- **Navigation**: `open <url>`, `back`, `reload`, `get url`
- **Page Analysis**: `snapshot -i`, `get title`
- **Interaction**: `click @e1`, `fill @e1 "text"`, `press Enter`, `scroll down 500`
- **Capture**: `screenshot path.png`, `get text @e1`
- **JavaScript**: `eval "code"`

### Full Command Reference
See `references/commands.md` for complete agent-browser command documentation.

## Troubleshooting

### Common Installation Issues

**"No binary found for darwin-arm64/win32-x64"**
- Rust is not installed or not in PATH
- Run the auto-install script: it handles Rust installation
- Or manually install Rust and run `npm run build:native`

**"cargo: command not found"**
- Rust toolchain not in PATH
- macOS: `export PATH="$HOME/.cargo/bin:$PATH"`
- Windows: `$env:PATH = "$HOME\.cargo\bin;$env:PATH"`
- Then rebuild: `npm run build:native`

**"rustup could not choose a version"**
- Default toolchain not set
- Run: `rustup default stable`
- Then rebuild: `npm run build:native`

### Runtime Issues

**"Daemon not found" error**
- Must set AGENT_BROWSER_HOME and run from project directory
```bash
cd ~/Documents/agent-browser
AGENT_BROWSER_HOME=~/Documents/agent-browser ./bin/agent-browser --cdp 9222 <command>
```

**"No page found" error**
- Chrome needs at least one page open
```bash
osascript -e 'tell application "Google Chrome" to open location "https://google.com"'
sleep 2
# Then retry
```

**Connection refused**
- Chrome not running with debug port
- Check if Chrome is running: `ps aux | grep "remote-debugging-port=9222"`
- Start Chrome with the start-chrome script

## Best Practices

1. **Always run auto-install script first** - Ensures all dependencies are installed
2. **Use start-chrome scripts** - Preserves login states across sessions
3. **Check dependencies** - Scripts automatically verify required tools
4. **Provide visual feedback** - Take screenshots after significant actions
5. **Wait after navigation** - Use `sleep 2` after page loads for stability
6. **Verify navigation success** - Check URL after page loads
7. **Handle security verification** - Inform user and wait for manual completion when needed
8. **Re-snapshot after DOM changes** - Get fresh element references after page updates

## Profile Management

### Profile Locations
- **macOS**: `$HOME/Library/Application Support/Google/Chrome-Automation`
- **Windows**: `%USERPROFILE%\AppData\Local\Google\Chrome-Automation`

### Reset Automation Profile
To reset the profile and re-import from your main Chrome:

**macOS:**
```bash
rm -rf $HOME/Library/Application Support/Google/Chrome-Automation
bash scripts/start-chrome-mac.sh
```

**Windows (PowerShell):**
```powershell
Remove-Item -Recurse -Force "$HOME\AppData\Local\Google\Chrome-Automation"
powershell -ExecutionPolicy Bypass -File scripts/start-chrome-windows.ps1
```

## References

- **Setup Guides**: `references/setup-mac.md`, `references/setup-windows.md`
- **Command Reference**: `references/commands.md`
- **Troubleshooting**: `references/troubleshooting.md`
- **Script Documentation**: `scripts/README.md`, `install-scripts.md`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [agent-browser](https://github.com/vercel-labs/agent-browser) - The underlying browser automation tool
- [Chrome DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/) - Protocol for controlling Chrome

---

**Note**: This project is designed for automation and testing purposes. Always respect websites' terms of service and robots.txt files when automating browser interactions.