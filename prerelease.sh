#!/usr/bin/env sh

# fail script if any single command fails
set -e

echo "Prerelease script"
echo ""
echo "By default this script will continue even if tests fail."
echo "If you want the script to abort and return a non-zero return code"
echo "you can set the environment variable ABORT_ON_TEST_FAILURE=1."
echo "You can also set ABORT_ON_TEST_FAILURE_UNDERLAY=1 or"
echo "ABORT_ON_TEST_FAILURE_OVERLAY=1 to only affect a specific workspace."
echo ""

export WORKSPACE=`pwd`
echo "Use workspace: $WORKSPACE"
echo ""

set +e
_ls_prerelease_scripts=`ls | grep -v "prerelease.*\.sh"`
set -e
if [ "$_ls_prerelease_scripts" != "" ]; then
  echo "This script should be executed either in an empty folder or in a folder only containing the prerelease scripts" 1>&2
  if [ "$1" != "-y" ]; then
    read -p "Do you wish to continue anyway, this might overwrite existing files and folders? (y/N) " answer
    case $answer in
      [yY]* ) ;;
      * ) exit 1;;
    esac
  fi
  echo ""
fi

echo ""
echo "Clone source repositories for underlay workspace"
echo ""
./prerelease_clone_underlay.sh
echo ""

echo ""
echo "Clone release repositories for overlay workspace"
echo ""
./prerelease_clone_overlay.sh
echo ""

echo ""
echo "Build underlay workspace"
echo ""
. `pwd`/prerelease_build_underlay.sh
echo ""

echo ""
if [ "$(ls -A "$WORKSPACE/catkin_workspace_overlay/src" 2> /dev/null)" != "" ]; then
  echo "Build overlay workspace"
  echo ""
  . `pwd`/prerelease_build_overlay.sh
else
  echo "Skipping empty overlay workspace"
fi
echo ""
