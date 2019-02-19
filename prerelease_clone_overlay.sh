#!/usr/bin/env sh

# fail script if any single command fails
set -e

if [ -z "$WORKSPACE" ]; then
    WORKSPACE=`pwd`
    echo "Using workspace: $WORKSPACE"
    echo ""
fi

PYTHONPATH=/usr/lib/python3/dist-packages:$PYTHONPATH /usr/bin/python3 /usr/bin/generate_prerelease_overlay_script.py https://raw.githubusercontent.com/ros-infrastructure/ros_buildfarm_config/production/index.yaml kinetic ubuntu xenial amd64 --pkg  --exclude-pkg  --level 1 > prerelease_clone_overlay_impl.sh
echo ""

chmod u+x prerelease_clone_overlay_impl.sh
./prerelease_clone_overlay_impl.sh
