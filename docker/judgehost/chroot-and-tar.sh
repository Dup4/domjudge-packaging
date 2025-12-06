#!/bin/bash

set -euo pipefail

# Usage: https://github.com/DOMjudge/domjudge/blob/main/misc-tools/dj_make_chroot.in#L58-L87
/opt/domjudge/judgehost/bin/dj_make_chroot \
    -D Ubuntu \
    -R noble \
    -i openjdk-21-jdk-headless,openjdk-21-jre-headless

# ICPC 2025 requires kotlin compiler
echo "[..] Installing Kotlin compiler"
KOTLIN_VERSION="1.9.24"
KOTLIN_URL="https://github.com/JetBrains/kotlin/releases/download/v${KOTLIN_VERSION}/kotlin-compiler-${KOTLIN_VERSION}.zip"

# Download and install Kotlin compiler in chroot
wget -q "${KOTLIN_URL}" -O /tmp/kotlin-compiler.zip
mkdir -p /chroot/usr/local/lib
unzip -q /tmp/kotlin-compiler.zip -d /chroot/usr/local/lib/
rm /tmp/kotlin-compiler.zip

# Create symlinks for kotlin binaries in chroot
mkdir -p /chroot/usr/local/bin
ln -sf /usr/local/lib/kotlinc/bin/kotlinc /chroot/usr/local/bin/kotlinc
ln -sf /usr/local/lib/kotlinc/bin/kotlin /chroot/usr/local/bin/kotlin

echo "[..] Kotlin ${KOTLIN_VERSION} installed successfully"

cd /
echo "[..] Compressing chroot"
tar -czpf /chroot.tar.gz --exclude=/chroot/tmp --exclude=/chroot/proc --exclude=/chroot/sys --exclude=/chroot/mnt --exclude=/chroot/media --exclude=/chroot/dev --one-file-system /chroot
echo "[..] Compressing judge"
tar -czpf /judgehost.tar.gz /opt/domjudge/judgehost
