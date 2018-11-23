#!/bin/bash

set -e
BASE_DIR=$(pwd)

# Every directory under pwd should be a java version.
for oneJavaVersion in *; do
  cd ${BASE_DIR}/${oneJavaVersion}

  # every directory under that, is an architecture we support.

  for oneArch in *; do
    cd ${BASE_DIR}/${oneJavaVersion}/${oneArch}

    # Every directory under *that* is a distribution (trusty/xenial/etc) we're building for.
    BUILD_BASE_DIR=$(pwd)

    for oneDistribution in *; do
      echo "Building Distribution: $oneDistribution"

      # First, check if we can build binary packages for this combination.
      # This serves as a basic sanity check only.
      if [ "$(dpkg --print-architecture)" == "${oneArch}" ]; then
        echo "BINARY $oneJavaVersion $oneArch $oneDistribution" | figlet
        cd ${BUILD_BASE_DIR}/${oneDistribution}
        debuild -us -uc # binary build, no signing.
        cd ${BUILD_BASE_DIR}
        mv -v adoptopenjdk* /binaries/
      fi


      echo "$oneJavaVersion $oneArch $oneDistribution" | figlet
      cd ${BUILD_BASE_DIR}/${oneDistribution}
      debuild -S -us -uc # source-only build, no signing.
      cd ${BUILD_BASE_DIR}
      # we dont need these .build or .buildinfo files, thanks.

      # turns out DPUT needs these guys. I wonder why.
      # rm adoptopenjdk*.build adoptopenjdk*.buildinfo || true # debian does not generate them, so ignore errors
      mv -v adoptopenjdk* /sourcepkg/
    done

  done

done