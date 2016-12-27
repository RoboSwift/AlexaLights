#!/bin/sh

set -e

SWIFTYGPIO="Packages/SwiftyGPIO-0.8.7/Sources"
SWIFTER="Packages/Swifter-1.3.2/Sources"

sudo cp $SWIFTYGPIO/* Sources
sudo cp $SWIFTER/* Sources

swiftc Sources/* -v

sudo ./main
