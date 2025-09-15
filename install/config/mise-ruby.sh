#!/bin/bash

# FEDARCHY: Configure mise for Ruby inside AUR container
AUR_CONTAINER="arch-aur"

# Check if mise is available in container
if ! distrobox enter "$AUR_CONTAINER" -- command -v mise &>/dev/null; then
    echo "Warning: mise not found in container, skipping Ruby configuration"
else

# Install Ruby using gcc-14 for compatibility
echo "Configuring mise for Ruby development..."
distrobox enter "$AUR_CONTAINER" -- mise settings set ruby.ruby_build_opts "CC=gcc-14 CXX=g++-14"

# Trust .ruby-version
distrobox enter "$AUR_CONTAINER" -- mise settings add idiomatic_version_file_enable_tools ruby
fi
