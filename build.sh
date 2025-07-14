#!/bin/bash

# Build script for Simple Audio Sampler v2.5 (Crystal Cove)
# Usage: ./build.sh

set -e

V24_APP="releases/SimpleAudioSampler_v2.4.app"
V25_APP="releases/SimpleAudioSampler_v2.5.app"
V25_SRC="src/SimpleAudioSampler_v2.5_CrystalCove.swift"
V25_BIN="SimpleAudioSampler_v2.5_CrystalCove"
BUNDLE_BIN="SimpleAudioSampler"

# 1. Copy v2.4.app to v2.5.app
if [ -d "$V25_APP" ]; then
    echo "🗑 Removing old v2.5.app..."
    rm -rf "$V25_APP"
fi
cp -R "$V24_APP" "$V25_APP"
echo "✅ Copied $V24_APP to $V25_APP"

# 2. Compile the new Crystal Cove source
swiftc -O -o "$V25_BIN" \
    "$V25_SRC" \
    src/SimpleAudioSampler_v2.4_Waveform.swift \
    -framework SwiftUI \
    -framework AVFoundation \
    -framework CoreAudio \
    -framework UniformTypeIdentifiers

echo "✅ Compiled $V25_SRC to $V25_BIN"

# 3. Replace the binary in the app bundle
cp "$V25_BIN" "$V25_APP/Contents/MacOS/$BUNDLE_BIN"
echo "✅ Replaced binary in $V25_APP/Contents/MacOS/$BUNDLE_BIN"

# 4. Launch the app
open "$V25_APP"
echo "🚀 Launched $V25_APP"