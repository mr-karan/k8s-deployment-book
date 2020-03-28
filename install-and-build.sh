#!/bin/bash
set -e
# grab mdbook
echo "downloading mdbook-v0.3.6-x86_64-unknown-linux-gnu.tar.gz"
set -x
curl -sL https://github.com/rust-lang/mdBook/releases/download/v0.3.6/mdbook-v0.3.6-x86_64-unknown-linux-gnu.tar.gz | tar xz
mv mdbook /tmp/mdbook
chmod +x /tmp/mdbook
# clean and build
/tmp/mdbook clean && /tmp/mdbook build
