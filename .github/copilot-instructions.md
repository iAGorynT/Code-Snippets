# Code Snippets Repository
Personal collection of macOS utilities, scripts, and educational code samples for learning, experimentation, and personal projects.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively
This repository contains standalone utilities and scripts rather than a traditional application. Components can be tested and run independently.

### Quick Start - Repository Overview:
- `ls -la` -- View repository structure
- Repository contains 8 main directories with different types of code samples
- No central build system - each component works independently
- Repository size: ~50MB excluding dependencies

### Component Testing and Validation:
#### Python Code (PythonCode/)
- Install dependencies: `cd PythonCode && pip3 install -r requirements.txt` -- takes 30 seconds
- Test OTP generator: `python3 otp_generator.py` -- FAILS on non-macOS systems (requires macOS Keychain)
- **PLATFORM REQUIREMENT**: Python code is macOS-specific due to `security` command dependency

#### Node.js MCP Server (mcp-servers/date-generator/)
- Install dependencies: `cd mcp-servers/date-generator && npm install` -- takes 30 seconds
- Test server: `npm start` -- starts immediately, runs on stdio (use Ctrl+C to stop)
- **VALIDATION**: Server outputs "Date Generator MCP server running on stdio" when working correctly
- Works cross-platform (Linux, macOS, Windows)

#### HTML Files (Html/)
- Serve locally: `cd Html && python3 -m http.server 8000` -- starts immediately
- Test in browser: `curl http://localhost:8000/` 
- **VALIDATION**: Should return HTML directory listing
- Contains interactive date generator with light/dark mode toggle

#### Shell Scripts (ShellScripts/)
- **PLATFORM REQUIREMENT**: Most scripts are macOS/zsh-specific
- Test cross-platform script: `zsh Colortest.sh` -- runs immediately, displays terminal color test
- Main menu script: `Mm.sh` -- interactive menu system for other utilities
- **NOTE**: Scripts expect to be in `/usr/local/bin` or `$HOME/bin` for full functionality

### Build Times and Timeouts:
- Python dependencies: ~1 second (already cached) / ~30 seconds (fresh install) - Set timeout to 60 seconds
- Node.js dependencies: ~1 second (already cached) / ~30 seconds (fresh install) - Set timeout to 60 seconds  
- HTTP server startup: Immediate (less than 1 second)
- Script execution: Immediate (less than 1 second for most scripts)
- HTML application functionality: Interactive, real-time response
- **NEVER CANCEL**: Allow dependency installation to complete even if it seems slow
- **MEASURED BUILD TIMES**: All timings validated on Linux environment

## Validation Scenarios
Always run these validation steps after making changes to ensure functionality:

### End-to-End Testing:
1. **MCP Server Validation**:
   - `cd mcp-servers/date-generator && npm install && npm start` 
   - Verify "Date Generator MCP server running on stdio" appears
   - Press Ctrl+C to stop

2. **HTML Application Testing**:
   - `cd Html && python3 -m http.server 8000 &`
   - `curl -s http://localhost:8000/DOW_Inline.html | head -5`
   - Verify HTML content returned
   - `pkill -f "python3 -m http.server"`

3. **Shell Script Testing**:
   - `cd ShellScripts && zsh Colortest.sh`
   - Verify color output appears (ANSI escape sequences) - should show ~75 lines of color patterns

4. **HTML Application Full Workflow**:
   - Open browser to `http://localhost:8000/DOW_Inline.html`
   - Select different month/year/day combinations
   - Click "Generate Dates" - verify dates appear correctly
   - Toggle dark mode checkbox - verify UI switches themes
   - **VALIDATION**: Date generation works and dark/light mode toggle functions

5. **Cross-Platform Compatibility Check**:
   - Test on non-macOS: Python OTP generator will fail (expected - FileNotFoundError: 'security' command)
   - Test on any platform: Node.js MCP server should work
   - Test on any platform: HTML files should serve correctly
   - Test shell scripts: Colortest.sh works cross-platform, others may be macOS-specific

## Platform-Specific Requirements

### macOS:
- All components work as intended
- Python OTP generator requires Keychain access
- Shell scripts designed for zsh/macOS environment

### Linux/Windows:
- Node.js MCP server: ✅ Works
- HTML files: ✅ Work  
- Python OTP generator: ❌ Fails (macOS Keychain dependency)
- Shell scripts: ⚠️ Limited compatibility (some work, others are macOS-specific)

## Repository Structure and Key Locations

### Primary Directories:
```
PythonCode/          -- OTP generator with macOS Keychain integration
├── otp_generator.py
└── requirements.txt

mcp-servers/         -- Model Context Protocol servers
└── date-generator/  -- Node.js MCP server for date generation
    ├── package.json
    ├── index.js
    └── README.md

ShellScripts/        -- macOS utility scripts (50+ scripts)
├── Mm.sh           -- Main menu system
├── Colortest.sh    -- Cross-platform terminal color test
└── *.sh            -- Various macOS utilities

Html/               -- Web applications and utilities
├── DOW_Inline.html -- Date generator with light/dark mode
├── script.js
└── styles.css

JavaApps/           -- Java applications (archived as .zip files)
Templates/          -- Configuration file templates
TerminalCommands/   -- macOS Terminal .command files
Assets/             -- Images and resources
DotFiles/           -- Configuration files
HomeBrew/           -- Homebrew-related utilities
Icons/              -- Icon files
Launchd/            -- macOS Launch Daemon configurations
```

### Important Files:
- `README.md` -- Repository overview and usage warnings
- `.github/SECURITY.md` -- Security reporting guidelines  
- `_config.yml` -- Jekyll GitHub Pages configuration
- `ShellScripts/README.md` -- Shell script installation instructions

## Common Tasks and Reference Information

### Frequently Used Command Outputs
The following are outputs from frequently run commands. Reference them instead of viewing, searching, or running bash commands to save time.

#### Repository Root Structure
```
ls -la /
.git                 # Git repository metadata
.gitattributes       # Git line ending configuration
.github/             # GitHub configuration (includes these instructions)
.gitignore          # Git ignore patterns
Assets/             # Image assets and resources
DotFiles/           # Configuration file templates
HomeBrew/           # Homebrew package management utilities
Html/               # Web applications and HTML utilities
Icons/              # Icon files for applications
JavaApps/           # Java applications (archived)
LICENSE             # MIT License
Launchd/            # macOS Launch Daemon configurations
PythonCode/         # Python utilities (OTP generator)
README.md           # Repository overview
ShellScripts/       # macOS shell utilities (50+ scripts)
Templates/          # Configuration templates
TerminalCommands/   # macOS .command files
_config.yml         # Jekyll GitHub Pages configuration
mcp-servers/        # Model Context Protocol servers
```

#### Python Dependencies
```
cat PythonCode/requirements.txt
pyotp>=2.8.0        # Time-based OTP generation
cryptography>=38.0.4 # Encryption for keychain integration
```

#### Node.js MCP Server Package
```
cat mcp-servers/date-generator/package.json
{
  "name": "date-generator-mcp",
  "version": "1.0.4", 
  "description": "MCP server for generating dates by month, year, and day of week",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "node --watch index.js"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.17.2"
  }
}
```

### Component-Specific Tasks:

#### Adding New Components:
- Python scripts: Add to `PythonCode/`, update `requirements.txt` if needed
- Node.js projects: Add to `mcp-servers/` with proper `package.json`
- Shell scripts: Add to `ShellScripts/` with zsh shebang (`#!/bin/zsh`) and appropriate permissions (`chmod +x`)
- Web apps: Add to `Html/` directory with supporting CSS/JS files

#### Testing Changes:
- Always test each component type independently
- Verify cross-platform compatibility for Node.js and HTML components
- Document any macOS-specific dependencies
- Test shell scripts on target platform (macOS preferred)

### Repository Maintenance:
- Do not commit `node_modules/` or `__pycache__/` directories
- Use `.gitignore` to exclude build artifacts and dependencies
- Each component should be self-contained with its own dependencies
- Maintain README files for complex components

## Dependencies and Environment Setup

### Required Software:
- Python 3.x: `python3 --version` -- verify installation
- Node.js: `node --version` -- verify installation  
- Git: `git --version` -- verify installation

### Development Environment:
- No IDE requirements - components are simple scripts
- Terminal/command line sufficient for all operations
- Web browser for testing HTML components
- Text editor for modifications

### Notes:
- This is a personal utility collection, not production software
- Components may have undocumented macOS-specific behaviors
- Use at your own risk as stated in repository README
- Some shell scripts may require additional macOS-specific tools (Homebrew, etc.)