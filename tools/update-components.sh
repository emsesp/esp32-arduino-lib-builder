#/bin/bash

source ./tools/config.sh

#
# CLONE/UPDATE TINYUSB
#
echo "Updating TinyUSB..."
TINYUSB_REPO_URL="https://github.com/hathach/tinyusb.git"
TINYUSB_REPO_DIR="$AR_COMPS/arduino_tinyusb/tinyusb"
TINYUSB_PATCH_DIR="$AR_PATCHES/tinyusb"
# TinyUSB is pinned to a commit, so the clone lives on a detached HEAD (no pull possible)
TINYUSB_COMMIT="99c53f32c20654348cfd0cd7fc87d94543674c81"
if [ ! -d "$TINYUSB_REPO_DIR" ]; then
       git clone -b master "$TINYUSB_REPO_URL" "$TINYUSB_REPO_DIR" && \
       git -C "$TINYUSB_REPO_DIR" checkout "$TINYUSB_COMMIT"
else
       # The clone is build output, not a workspace: drop the patches of the previous run,
       # and anything they left behind, so the checkout of the pinned commit is clean.
       git -C "$TINYUSB_REPO_DIR" reset --hard && \
       git -C "$TINYUSB_REPO_DIR" clean -fd && \
       git -C "$TINYUSB_REPO_DIR" fetch && \
       git -C "$TINYUSB_REPO_DIR" checkout "$TINYUSB_COMMIT"
fi
if [ $? -ne 0 ]; then exit 1; fi

# Fixes we cannot wait for upstream on, see patches/tinyusb/README.md
for patch in "$TINYUSB_PATCH_DIR"/*.diff; do
    [ -e "$patch" ] || continue
    # A patch stops applying once its fix is upstream, which is where all of these are headed.
    # Skipping the ones already in the tree keeps that day from breaking the build; anything
    # that neither applies nor is present is a patch that needs refreshing, so fail there.
    if git -C "$TINYUSB_REPO_DIR" apply --reverse --check "$patch" 2>/dev/null; then
        echo "Skipping $(basename "$patch"), already in TinyUSB..."
        continue
    fi
    echo "Patching TinyUSB with $(basename "$patch")..."
    git -C "$TINYUSB_REPO_DIR" apply "$patch"
    if [ $? -ne 0 ]; then exit 1; fi
done
