#!/bin/sh

if [ -n "$DESTDIR" ] ; then
    case $DESTDIR in
        /*) # ok
            ;;
        *)
            /bin/echo "DESTDIR argument must be absolute... "
            /bin/echo "otherwise python's distutils will bork things."
            exit 1
    esac
    DESTDIR_ARG="--root=$DESTDIR"
fi

echo_and_run() { echo "+ $@" ; "$@" ; }

echo_and_run cd "/tmp/catkin_workspace/src/gripit"

# ensure that Python install destination exists
echo_and_run mkdir -p "$DESTDIR/tmp/catkin_workspace/install_isolated/lib/python2.7/dist-packages"

# Note that PYTHONPATH is pulled from the environment to support installing
# into one location when some dependencies were installed in another
# location, #123.
echo_and_run /usr/bin/env \
    PYTHONPATH="/tmp/catkin_workspace/install_isolated/lib/python2.7/dist-packages:/tmp/catkin_workspace/build_isolated/gripit/lib/python2.7/dist-packages:$PYTHONPATH" \
    CATKIN_BINARY_DIR="/tmp/catkin_workspace/build_isolated/gripit" \
    "/usr/bin/python" \
    "/tmp/catkin_workspace/src/gripit/setup.py" \
    build --build-base "/tmp/catkin_workspace/build_isolated/gripit" \
    install \
    $DESTDIR_ARG \
    --install-layout=deb --prefix="/tmp/catkin_workspace/install_isolated" --install-scripts="/tmp/catkin_workspace/install_isolated/bin"
