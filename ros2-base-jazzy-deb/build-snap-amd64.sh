#!/bin/bash
set -e

# 'sudo' is required independently of the snapcraft version (here 8.x)
sudo snapcraft clean
sudo SNAPCRAFT_BUILD_ENVIRONMENT=host snapcraft pack --build-for=amd64 --verbosity=verbose
