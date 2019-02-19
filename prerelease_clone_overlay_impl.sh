#!/usr/bin/env sh

# fail script if any single command fails
set -e

if [ -z "$WORKSPACE" ]; then
    WORKSPACE=`pwd`
    echo "Using workspace: $WORKSPACE"
    echo ""
fi

# list of repositories to clone

mkdir -p catkin_workspace_overlay/src


