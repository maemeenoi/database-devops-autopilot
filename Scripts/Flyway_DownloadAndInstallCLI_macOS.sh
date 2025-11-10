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
  # Look for flyway-commandline-X.X.X-macos-x64.tar.gz pattern
  latest_version=$(echo "$content" | grep -o 'flyway-commandline-[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*-macos-x64\.tar\.gz' | sed 's/flyway-commandline-\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)-macos-x64\.tar\.gz/\1/' | head -n 1)

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

# Try macOS specific download first, fallback to Linux version
DOWNLOAD_URL="https://download.red-gate.com/maven/release/com/redgate/flyway/flyway-commandline/$FLYWAY_VERSION/flyway-commandline-$FLYWAY_VERSION-macos-x64.tar.gz"

# Check if macOS version exists, otherwise use Linux version
if ! curl --output /dev/null --silent --head --fail "$DOWNLOAD_URL"; then
  echo "macOS version not available, using Linux version..."
  DOWNLOAD_URL="https://download.red-gate.com/maven/release/com/redgate/flyway/flyway-commandline/$FLYWAY_VERSION/flyway-commandline-$FLYWAY_VERSION-linux-x64.tar.gz"
fi

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

# Make sure /usr/local/bin exists (it should on macOS)
sudo mkdir -p /usr/local/bin

# Create symbolic link to the Flyway executable
sudo ln -sf "$INSTALL_DIR/flyway" /usr/local/bin/flyway

# Make sure the flyway binary is executable
chmod +x "$INSTALL_DIR/flyway"

echo "Flyway version $FLYWAY_VERSION is downloaded and installed."

echo "Updating PATH Variable for current session"
export PATH="/usr/local/bin:$PATH"

# Add to shell profile for persistent PATH
SHELL_PROFILE=""
if [ -n "$ZSH_VERSION" ]; then
  SHELL_PROFILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
  if [ -f "$HOME/.bash_profile" ]; then
    SHELL_PROFILE="$HOME/.bash_profile"
  else
    SHELL_PROFILE="$HOME/.bashrc"
  fi
fi

if [ -n "$SHELL_PROFILE" ]; then
  if ! grep -q "/usr/local/bin" "$SHELL_PROFILE" 2>/dev/null; then
    echo 'export PATH="/usr/local/bin:$PATH"' >> "$SHELL_PROFILE"
    echo "Added /usr/local/bin to PATH in $SHELL_PROFILE"
  fi
fi

# Validate Flyway installation
echo "Validating Flyway installation..."
if flyway --version >/dev/null 2>&1; then
  INSTALLED_VERSION=$(flyway --version | grep -o 'Flyway .* Edition [0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*' | awk '{print $4}')
  echo "Flyway is successfully installed and running version $INSTALLED_VERSION."
else
  echo "Flyway installation failed. Please check for issues."
  echo "You may need to restart your terminal or run 'source ~/.zshrc' (or ~/.bash_profile) to update your PATH."
  exit 1
fi

echo "Installation complete! You can now use 'flyway' command."