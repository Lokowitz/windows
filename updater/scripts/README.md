# Updater Test Scripts

These scripts help you set up and test the updater in development mode.

## Prerequisites

Install the required tools:

- **signify**: For Ed25519 key generation and signing
  - macOS: `brew install signify-osx`
  - Linux: Install from your distribution's package manager
  - Windows: Use WSL or download from OpenBSD

- **b2sum**: For BLAKE2b hash generation
  - macOS: `brew install coreutils` (provides `b2sum`)
  - Linux: Usually pre-installed
  - Windows: Use WSL or download from a coreutils package

- **Python 3**: For the test HTTP server (usually pre-installed)

## Quick Start

Run the master setup script from **anywhere** (scripts auto-detect their location):

### From project root (recommended):
```bash
chmod +x updater/scripts/*.sh
./updater/scripts/setup-test-env.sh
```

### From scripts directory:
```bash
cd updater/scripts
chmod +x *.sh
./setup-test-env.sh
```

**Note**: All scripts work from any directory - they calculate paths relative to the project structure automatically.

This will:
1. Generate Ed25519 keys
2. Extract the public key for `constants.go`
3. Generate a file list manifest from your MSI files
4. Sign the manifest
5. Copy MSI files to the test server directory

## Individual Scripts

### 1. `generate-keys.sh`
Generate a new Ed25519 key pair for signing manifests.

```bash
./generate-keys.sh
```

Creates:
- `test-keys/release.pub` - Public key
- `test-keys/release.sec` - Secret key (keep this secure!)

### 2. `extract-public-key.sh`
Extract the base64 public key from the generated key file for use in `constants.go`.

```bash
./extract-public-key.sh
```

### 3. `generate-manifest.sh`
Generate a file list with BLAKE2b-256 hashes for MSI files.

```bash
# Auto-detect MSI files in build/ directory
./generate-manifest.sh

# Or specify files manually
./generate-manifest.sh /path/to/file1.msi /path/to/file2.msi
```

Creates: `test-server/filelist.txt`

### 4. `sign-manifest.sh`
Sign the file list manifest with your private key.

```bash
./sign-manifest.sh
```

Creates: `test-server/latest.sig` (the signed manifest)

### 5. `start-test-server.sh`
Start a simple HTTP server to serve the test files.

```bash
# Default port 8000
./start-test-server.sh

# Custom port
./start-test-server.sh 8080
```

## Testing Workflow

1. **Initial Setup** (one time):
   ```bash
   ./setup-test-env.sh
   ```

2. **Update constants.go**:
   - Set `releasePublicKeyBase64` to the value from `extract-public-key.sh`
   - Set `updateServerHost = "localhost"`
   - Set `updateServerPort = 8000` (or your chosen port)
   - Set `updateServerUseHttps = false`

3. **Build your application**:
   ```bash
   cd ../..
   make build
   ```

4. **Create a test update**:
   - Update `version/version.go` to a higher version (e.g., "1.0.1")
   - Build a new MSI
   - Run `./generate-manifest.sh` again
   - Run `./sign-manifest.sh` again
   - Copy the new MSI to `test-server/`

5. **Start the test server**:
   ```bash
   ./start-test-server.sh
   ```

6. **Test the updater**:
   - Set environment variable: `export PANGOLIN_ALLOW_DEV_UPDATES=1` (Linux/macOS) or `set PANGOLIN_ALLOW_DEV_UPDATES=1` (Windows)
   - Run your application
   - Trigger the update check

## Directory Structure

After running the scripts, you'll have:

```
updater/
├── scripts/
│   ├── generate-keys.sh
│   ├── extract-public-key.sh
│   ├── generate-manifest.sh
│   ├── sign-manifest.sh
│   ├── start-test-server.sh
│   └── setup-test-env.sh
├── test-keys/
│   ├── release.pub      (public key)
│   └── release.sec     (secret key - keep secure!)
└── test-server/
    ├── latest.sig       (signed manifest)
    ├── filelist.txt     (unsigned manifest)
    └── *.msi            (MSI files to serve)
```

## Windows Testing

On Windows, you can:

1. Use WSL (Windows Subsystem for Linux) to run these scripts
2. Use Git Bash
3. Use the PowerShell equivalents (see below)

## PowerShell Equivalents

For Windows users who prefer PowerShell, here are equivalent commands:

### Generate Keys (PowerShell)
```powershell
# Install signify first, then:
signify -G -n -p release.pub -s release.sec
```

### Generate Manifest (PowerShell)
```powershell
# If you have b2sum available:
Get-ChildItem -Path "build\*.msi" | ForEach-Object {
    $hash = b2sum -l 256 $_.FullName
    "$hash  $($_.Name)"
} | Out-File -FilePath "test-server\filelist.txt" -Encoding ASCII
```

### Start Test Server (PowerShell)
```powershell
cd test-server
python -m http.server 8000
```

## Troubleshooting

**"signify: command not found"**
- Install signify (see Prerequisites above)

**"b2sum: command not found"**
- Install coreutils (macOS) or use WSL (Windows)

**"No MSI files found"**
- Make sure you've built your MSI installer first
- Or manually specify MSI files: `./generate-manifest.sh /path/to/file.msi`

**"Signature is invalid"**
- Make sure you've updated `constants.go` with the correct public key
- Regenerate keys and update the public key in constants.go

**"No update was found"**
- Check that the MSI filename matches the pattern: `pangolin-<arch>-<version>.msi`
- Ensure the version number is higher than in `version/version.go`
- Verify the manifest file is correctly formatted

## Security Notes

⚠️ **Important**: 
- Never commit `release.sec` (secret key) to version control
- The test keys are for development only
- For production, use properly secured signing keys
- The `PANGOLIN_ALLOW_DEV_UPDATES` environment variable should never be set in production

