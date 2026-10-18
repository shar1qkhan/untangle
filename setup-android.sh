#!/bin/bash
set -e

echo "=== Installing JDK 17 + build tools ==="
if command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y openjdk-17-jdk curl unzip nodejs npm
elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm jdk17-openjdk curl unzip nodejs npm
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y java-17-openjdk curl unzip nodejs npm
else
    echo "Unsupported distro. Install JDK 17, curl, unzip, nodejs, npm manually."
    exit 1
fi

echo "=== Downloading Android command-line tools ==="
cd /tmp
curl -L -o cmdline-tools.zip \
  https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
rm -rf "$HOME/Android/Sdk/cmdline-tools"
mkdir -p "$HOME/Android/Sdk/cmdline-tools"
unzip -q cmdline-tools.zip -d "$HOME/Android/Sdk/cmdline-tools"
mv "$HOME/Android/Sdk/cmdline-tools/cmdline-tools" "$HOME/Android/Sdk/cmdline-tools/latest"
rm cmdline-tools.zip

echo "=== Adding env vars to ~/.bashrc ==="
if ! grep -q "ANDROID_HOME" "$HOME/.bashrc"; then
    {
        echo ''
        echo '# Android SDK'
        echo 'export ANDROID_HOME="$HOME/Android/Sdk"'
        echo 'export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"'
    } >> "$HOME/.bashrc"
fi

export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

echo "=== Accepting licenses ==="
yes | sdkmanager --licenses > /dev/null 2>&1 || true

echo "=== Installing SDK components (this takes a few minutes) ==="
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

echo ""
echo "=============================================="
echo "Setup complete."
echo "Now run:   source ~/.bashrc"
echo "Verify:    adb --version && java -version"
echo "=============================================="