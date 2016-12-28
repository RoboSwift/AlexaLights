#!/bin/sh

set -e

swiftc Sources/* -v

sudo ./main
