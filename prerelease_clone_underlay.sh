#!/usr/bin/env sh

# fail script if any single command fails
set -e

if [ -z "$WORKSPACE" ]; then
    WORKSPACE=`pwd`
    echo "Using workspace: $WORKSPACE"
    echo ""
fi

# list of repositories to clone
# - gripit (git, https://github.com/Yannick-Oderri/gripit-release.git, release/kinetic/gripit)"

mkdir -p catkin_workspace/src

if [ ! -d "catkin_workspace/src/gripit" ]; then
    (set -x; git clone --recurse-submodules -b release/kinetic/gripit https://github.com/Yannick-Oderri/gripit-release.git catkin_workspace/src/gripit)
    (set -x; git -C catkin_workspace/src/gripit --no-pager log -n 1)
else
    echo "Skip cloning 'gripit' as it already exists (catkin_workspace/src/gripit)"
fi
echo ""

