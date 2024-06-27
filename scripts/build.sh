#!/usr/bin/bash
set -e
cd ./claude
mdbook build
[ -d ../docs/claude ] && rm -r ../docs/claude
mv ./book/ ../docs/claude
cd ../gemini
mdbook build
[ -d ../docs/gemini ] && rm -r ../docs/gemini
mv ./book/ ../docs/gemini
cd ..
