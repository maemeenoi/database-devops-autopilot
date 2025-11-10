#!/bin/bash

# ===========================
# Script Name: Flyway_DownloadAndInstallCLI_macOS.sh
# Version: 1.0.0
# Author: Adapted for macOS compatibility
# Last Updated: 2025-11-11
# Description: Automated Flyway CLI Installation Script for macOS
# ===========================

SCRIPT_VERSION="1.0.0"

echo "Running Flyway Installer Script for macOS - Version $SCRIPT_VERSION"

# Check if FLYWAY_VERSION is set as an environment variable
if [ -z "$FLYWAY_VERSION" ]; then
  # If not set, assign a default value to a local variable
  FLYWAY_VERSION="Latest"
  echo "FLYWAY_VERSION is not set. Using default local variable value of '$FLYWAY_VERSION'."
else
  # If set, echo the environment variable and its value
  echo "FLYWAY_VERSION is set. Current value is: $FLYWAY_VERSION"
fi

# Function to get the currently installed Flyway version
get_installed_version() {
  if command -v flyway >/dev/null 2>&1; then
    flyway --version | grep -o 'Flyway .* Edition [0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*' | awk '{print $4}'
  else
    echo "none" # Indicate no version is installed
  fi
}

# Function to get the latest version from the website
get_latest_version_from_website() {
  # Fetch the webpage content
  content=$(curl -s https://documentation.red-gate.com/flyway/reference/usage/command-line)

  # Extract version number using BSD grep compatible approach
  # Look for flyway-commandline-X.X.X-macosx-x64.tar.gz pattern first (more reliable)
  latest_version=$(echo "$content" | grep -o 'flyway-commandline-[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*-macosx-x64\.tar\.gz' | sed 's/flyway-commandline-\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)-macosx-x64\.tar\.gz/\1/' | head -n 1)

  # If macOS version not found, try to get version from Windows download and assume it's the same
  if [ -z "$latest_version" ]; then
    latest_version=$(echo "$content" | grep -o 'flyway-commandline-[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*-windows-x64\.zip' | sed 's/flyway-commandline-\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)-windows-x64\.zip/\1/' | head -n 1)
  fi

  echo "$latest_version"
}

# Get the currently installed Flyway version
CURRENT_VERSION=$(get_installed_version)
echo "Current Flyway Version Is: $CURRENT_VERSION"

# Check if FLYWAY_VERSION required is 'Latest'
if [ "$FLYWAY_VERSION" = "latest" ] || [ "$FLYWAY_VERSION" = "Latest" ]; then
  LATEST_VERSION=$(get_latest_version_from_website)
  if [ -z "$LATEST_VERSION" ]; then
    echo "Could not retrieve the latest version from the website. Exiting."
    exit 1
  fi
  echo "Latest Flyway Version Is: $LATEST_VERSION"
  echo "Setting Flyway Version to be installed to: $LATEST_VERSION"
  FLYWAY_VERSION=$LATEST_VERSION
fi

# Check if the current version matches the required version
if [ "$CURRENT_VERSION" = "$FLYWAY_VERSION" ]; then
  echo "Flyway $CURRENT_VERSION is already installed and up-to-date. No action needed."
  exit 0
else
  echo "Current version ($CURRENT_VERSION) does not match the required version ($FLYWAY_VERSION). Installing the required version."
fi

# Proceed with the installation of the required version
INSTALL_DIR="$HOME/flyway-$FLYWAY_VERSION" # Install directory in the user's home folder

# Download and install Flyway
echo "Downloading and installing Flyway version $FLYWAY_VERSION for macOS..."

# Check if Java is available on the system
if ! command -v java >/dev/null 2>&1; then
  echo "Warning: Java is not installed or not in PATH."
  
  # Check common Java installation paths on macOS
  JAVA_PATHS=(
    "/Library/Java/JavaVirtualMachines/*/Contents/Home/bin/java"
    "/opt/homebrew/opt/openjdk@*/bin/java"
    "/usr/local/opt/openjdk@*/bin/java"
    "/System/Library/Java/JavaVirtualMachines/*/Contents/Home/bin/java"
  )
  
  JAVA_FOUND=false
  for java_path in "${JAVA_PATHS[@]}"; do
    # Use glob expansion to find Java installations
    for java_bin in $java_path; do
      if [ -x "$java_bin" ]; then
        export JAVA_HOME="$(dirname "$(dirname "$java_bin")")"
        export PATH="$(dirname "$java_bin"):$PATH"
        echo "Found Java at: $java_bin"
        echo "Set JAVA_HOME to: $JAVA_HOME"
        JAVA_FOUND=true
        break 2
      fi
    done
  done
  
  if [ "$JAVA_FOUND" = false ]; then
    echo "Installing Java using available package manager..."
    if command -v brew >/dev/null 2>&1; then
      brew install openjdk@17
      export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
      export PATH="$JAVA_HOME/bin:$PATH"
    else
      echo "Error: No Java found and Homebrew not available."
      echo "Please install Java manually or ensure it's in your PATH."
      echo "On GitHub Actions runners, Java should be pre-installed."
      exit 1
    fi
  fi
fi

echo "Java version check:"
java -version

# For macOS, try different download strategies:
# 1. Try macOS-specific version (detect architecture)
# 2. Try no-JRE version (uses system Java)
# 3. Fallback to Linux version only if others fail

# Detect macOS architecture
ARCH="x64"
if [ "$(uname -m)" = "arm64" ]; then
  ARCH="arm64"
fi

echo "Detected architecture: $ARCH"

DOWNLOAD_URLS=(
  "https://download.red-gate.com/maven/release/com/redgate/flyway/flyway-commandline/$FLYWAY_VERSION/flyway-commandline-$FLYWAY_VERSION-macosx-$ARCH.tar.gz"
  "https://download.red-gate.com/maven/release/com/redgate/flyway/flyway-commandline/$FLYWAY_VERSION/flyway-commandline-$FLYWAY_VERSION-macosx-x64.tar.gz"
  "https://download.red-gate.com/maven/release/com/redgate/flyway/flyway-commandline/$FLYWAY_VERSION/flyway-commandline-$FLYWAY_VERSION-linux-x64-no-jre.tar.gz"
  "https://download.red-gate.com/maven/release/com/redgate/flyway/flyway-commandline/$FLYWAY_VERSION/flyway-commandline-$FLYWAY_VERSION-linux-x64.tar.gz"
)

DOWNLOAD_URL=""
DOWNLOAD_TYPE=""

for i in "${!DOWNLOAD_URLS[@]}"; do
  url="${DOWNLOAD_URLS[$i]}"
  echo "Checking availability of download option $((i+1)): $(basename "$url")"
  if curl --output /dev/null --silent --head --fail "$url"; then
    DOWNLOAD_URL="$url"
    case $i in
      0) DOWNLOAD_TYPE="macOS-$ARCH specific" ;;
      1) DOWNLOAD_TYPE="macOS-x64 fallback" ;;
      2) DOWNLOAD_TYPE="no-JRE (uses system Java)" ;;
      3) DOWNLOAD_TYPE="Linux with JRE" ;;
    esac
    echo "✅ Found available download: $DOWNLOAD_TYPE"
    break
  else
    echo "❌ Not available: $(basename "$url")"
  fi
done

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Error: No suitable Flyway download found for version $FLYWAY_VERSION"
  exit 1
fi

echo "Downloading Flyway ($DOWNLOAD_TYPE)..."
# Download and extract
curl -L "$DOWNLOAD_URL" | tar -xzf -

# Check if the download and extraction were successful
if [[ $? -ne 0 ]]; then
  echo "Error: Download failed. Please check that FLYWAY_VERSION '${FLYWAY_VERSION}' is correct and available for download."
  exit 1
fi

# Move the Flyway folder to the install directory
if [ -d "flyway-$FLYWAY_VERSION" ]; then
  mv "flyway-$FLYWAY_VERSION" "$INSTALL_DIR"
else
  echo "Error: Flyway directory not found after extraction."
  exit 1
fi

# Only patch JRE if we downloaded the Linux version
if [ "$DOWNLOAD_TYPE" = "Linux with JRE" ]; then
  echo "Downloaded Linux version with JRE. Checking Java compatibility..."
  
  # Test if the bundled Java works
  if ! "$INSTALL_DIR/jre/bin/java" -version >/dev/null 2>&1; then
    echo "Bundled Java is incompatible with macOS. Configuring to use system Java..."
    
    # Check if system Java is available
    if command -v java >/dev/null 2>&1; then
      # Modify the flyway script to use system Java instead of bundled JRE
      if [ -f "$INSTALL_DIR/flyway" ]; then
        # Backup original script
        cp "$INSTALL_DIR/flyway" "$INSTALL_DIR/flyway.original"
        
        # Replace the JRE detection logic to force system Java
        sed 's/if \[ -x "\$INSTALLDIR\/jre\/bin\/java" \]; then/if false; then/' "$INSTALL_DIR/flyway.original" > "$INSTALL_DIR/flyway"
        chmod +x "$INSTALL_DIR/flyway"
        
        echo "Modified Flyway to use system Java instead of bundled JRE"
      fi
    else
      echo "Error: System Java not found. Please install Java first."
      exit 1
    fi
  fi
else
  echo "Using native macOS version - no JRE patching needed"
fi

# Make sure the flyway binary is executable
chmod +x "$INSTALL_DIR/flyway"

# Make sure /usr/local/bin exists (it should on macOS)
if [ ! -d "/usr/local/bin" ]; then
  sudo mkdir -p /usr/local/bin
fi

# Create symbolic link to the Flyway executable
# Try without sudo first, then with sudo if needed
if ln -sf "$INSTALL_DIR/flyway" /usr/local/bin/flyway 2>/dev/null; then
  echo "Created symlink without sudo"
elif sudo ln -sf "$INSTALL_DIR/flyway" /usr/local/bin/flyway 2>/dev/null; then
  echo "Created symlink with sudo"
else
  echo "Warning: Could not create symlink. Flyway will be available at: $INSTALL_DIR/flyway"
  # Update PATH to include the install directory directly
  export PATH="$INSTALL_DIR:$PATH"
fi

echo "Flyway version $FLYWAY_VERSION is downloaded and installed."

echo "Updating PATH Variable for current session"
export PATH="/usr/local/bin:$PATH"

# Add to shell profiles for persistent PATH (detect shell type from environment)
if [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ] || [ -n "$ZSH_VERSION" ]; then
  SHELL_PROFILE="$HOME/.zshrc"
elif [ "$SHELL" = "/bin/bash" ] || [ "$SHELL" = "/usr/bin/bash" ] || [ -n "$BASH_VERSION" ]; then
  if [ -f "$HOME/.bash_profile" ]; then
    SHELL_PROFILE="$HOME/.bash_profile"
  else
    SHELL_PROFILE="$HOME/.bashrc"
  fi
else
  # Fallback: try to detect based on existing files
  if [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
  elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_PROFILE="$HOME/.bash_profile"
  elif [ -f "$HOME/.bashrc" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
  fi
fi

if [ -n "$SHELL_PROFILE" ]; then
  if ! grep -q "/usr/local/bin" "$SHELL_PROFILE" 2>/dev/null; then
    echo 'export PATH="/usr/local/bin:$PATH"' >> "$SHELL_PROFILE"
    echo "Added /usr/local/bin to PATH in $SHELL_PROFILE"
  fi
fi

# Validate Flyway installation with better error handling
echo "Validating Flyway installation..."

# Check multiple possible locations for flyway
FLYWAY_PATHS=("/usr/local/bin/flyway" "$INSTALL_DIR/flyway")
FLYWAY_EXECUTABLE=""

for path in "${FLYWAY_PATHS[@]}"; do
  if [ -f "$path" ] && [ -x "$path" ]; then
    FLYWAY_EXECUTABLE="$path"
    break
  fi
done

if [ -z "$FLYWAY_EXECUTABLE" ]; then
  echo "Error: Flyway executable not found at any expected location"
  echo "Checked locations:"
  for path in "${FLYWAY_PATHS[@]}"; do
    echo "  $path: $(ls -la "$path" 2>/dev/null || echo 'NOT FOUND')"
  done
  echo "Install directory contents:"
  ls -la "$INSTALL_DIR" 2>/dev/null || echo "Install directory not found: $INSTALL_DIR"
  exit 1
fi

# Try running flyway
if "$FLYWAY_EXECUTABLE" --version >/dev/null 2>&1; then
  INSTALLED_VERSION=$("$FLYWAY_EXECUTABLE" --version | grep -o 'Flyway .* Edition [0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*' | awk '{print $4}')
  echo "Flyway is successfully installed and running version $INSTALLED_VERSION."
  echo "Flyway executable location: $FLYWAY_EXECUTABLE"
  
  # If flyway is not in /usr/local/bin, update PATH to include the install directory
  if [ "$FLYWAY_EXECUTABLE" != "/usr/local/bin/flyway" ]; then
    export PATH="$INSTALL_DIR:$PATH"
    echo "Updated PATH to include: $INSTALL_DIR"
  fi
else
  echo "Flyway installation failed. Debugging information:"
  echo "Flyway executable: $FLYWAY_EXECUTABLE"
  echo "PATH: $PATH"
  echo "Trying to run flyway:"
  "$FLYWAY_EXECUTABLE" --version 2>&1 || echo "Failed to run flyway"
  echo "You may need to restart your terminal or run 'source $SHELL_PROFILE' to update your PATH."
  exit 1
fi

echo "Installation complete! You can now use 'flyway' command."