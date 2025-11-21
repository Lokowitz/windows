# Pangolin

## Prerequisites

- Go 1.25 or later
- Windows operating system (for running the application)
- Note: You can build on macOS/Linux using cross-compilation (see below)
- WiX Toolset installed on Windows (for building MSI installer) - Download from https://wixtoolset.org/

## Building the Application

`make rsrc` - Generates Windows resources (icons, version info)
`make build` - Builds the Windows executable `Pangolin.exe` in the `build/` directory

## Building the MSI Installer

The MSI installer will:

- Install `Pangolin.exe` to `C:\Program Files\Pangolin\`
- Install all necessary dependencies
- Create an uninstaller entry in Windows Add/Remove Programs

### Prerequisites for MSI Building

1. **WiX Toolset** must be installed on Windows:
   - Download from https://wixtoolset.org/
   - Install the WiX Toolset build tools
   - **WiX v4**: Ensure `wix.exe` is in your PATH

### Building the MSI

**On Windows:**

Simply run the batch script from the project root directory:

```cmd
build-msi.bat
```

This script will:

1. Compile the manifest and resources
2. Build the Windows executable
3. Generate GUIDs for the installer (if needed)
4. Create the MSI installer

The MSI file will be created at `build/Pangolin.msi`
