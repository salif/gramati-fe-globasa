#!/usr/bin/bash
set -e
cd ./bg-claude
mdbook build
[ -d ../docs/bg-claude ] && rm -r ../docs/bg-claude
mv ./book/ ../docs/bg-claude
cd ../bg-gemini
mdbook build
[ -d ../docs/bg-gemini ] && rm -r ../docs/bg-gemini
mv ./book/ ../docs/bg-gemini
cd ../eng
mdbook build
[ -d ../docs/eng ] && rm -r ../docs/eng
mv ./book/ ../docs/eng
cd ..
