#!/usr/bin/env sh

# fail script if any single command fails
set -e

if [ -z "$WORKSPACE" ]; then
    WORKSPACE=`pwd`
    echo "Using workspace: $WORKSPACE"
    echo ""
fi

# run all build steps
echo "Build step 1"
echo "# BEGIN SECTION: docker version"
docker version
echo "# END SECTION"
echo "# BEGIN SECTION: docker info"
docker info
echo "# END SECTION"
echo ""

echo "Build step 2"
echo "# BEGIN SECTION: Check docker status"
echo "Testing trivial docker invocation..."
docker run --rm ubuntu:xenial true ; echo "'docker run' returned $?"
echo ""

echo "Build step 3"
echo "# END SECTION"
echo ""

echo "Build step 4"
echo "# BEGIN SECTION: Embed wrapper scripts"
rm -fr wrapper_scripts
mkdir wrapper_scripts
printf "#!/usr/bin/env python3\n\n# Copyright 2016 Open Source Robotics Foundation, Inc.\n#\n# Licensed under the Apache License, Version 2.0 (the \"License\");\n# you may not use this file except in compliance with the License.\n# You may obtain a copy of the License at\n#\n#     http://www.apache.org/licenses/LICENSE-2.0\n#\n# Unless required by applicable law or agreed to in writing, software\n# distributed under the License is distributed on an \"AS IS\" BASIS,\n# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n# See the License for the specific language governing permissions and\n# limitations under the License.\n\nimport subprocess\nimport sys\nfrom time import sleep\n\n\ndef main(argv=sys.argv[1:]):\n    max_tries = 10\n    known_error_strings = [\n        'Connection timed out',\n    ]\n\n    command = argv[0]\n    if command == 'clone':\n        rc, _, _ = call_git_repeatedly(\n            argv, known_error_strings, max_tries)\n        return rc\n    else:\n        assert \"Command '%%s' not implemented\" %% command\n\n\ndef call_git_repeatedly(argv, known_error_strings, max_tries):\n    command = argv[0]\n    for i in range(1, max_tries + 1):\n        if i > 1:\n            sleep_time = 5 + 2 * i\n            print(\"Reinvoke 'git %%s' (%%d/%%d) after sleeping %%s seconds\" %%\n                  (command, i, max_tries, sleep_time))\n            sleep(sleep_time)\n        rc, known_error_conditions = call_git(argv, known_error_strings)\n        if rc == 0 or not known_error_conditions:\n            break\n        print('')\n        print('Invocation failed due to the following known error conditions: '\n              ', '.join(known_error_conditions))\n        print('')\n        # retry in case of failure with known error condition\n    return rc, known_error_conditions, i\n\n\ndef call_git(argv, known_error_strings):\n    known_error_conditions = []\n\n    cmd = ['git'] + argv\n    print(\"Invoking '%%s'\" %% ' '.join(cmd))\n    proc = subprocess.Popen(\n        cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)\n    while True:\n        line = proc.stdout.readline()\n        if not line:\n            break\n        line = line.decode()\n        sys.stdout.write(line)\n        for known_error_string in known_error_strings:\n            if known_error_string in line:\n                if known_error_string not in known_error_conditions:\n                    known_error_conditions.append(known_error_string)\n    proc.wait()\n    rc = proc.returncode\n    return rc, known_error_conditions\n\n\nif __name__ == '__main__':\n    sys.exit(main())" > wrapper_scripts/git.py
echo "# END SECTION"
echo ""

echo "Build step 5"
if [ ! -d "ros_buildfarm" ]; then
echo "# BEGIN SECTION: Clone ros_buildfarm"
rm -fr ros_buildfarm
python3 -u wrapper_scripts/git.py clone --depth 1 -b 2.0.1 https://github.com/ros-infrastructure/ros_buildfarm.git ros_buildfarm
git -C ros_buildfarm --no-pager log -n 1
rm -fr ros_buildfarm/.git
rm -fr ros_buildfarm/doc
echo "# END SECTION"
else
echo "Using existing ros_buildfarm folder"
fi
echo ""

echo "Build step 6"
# generate key files
echo "# BEGIN SECTION: Write PGP repository keys"
mkdir -p $WORKSPACE/keys
rm -fr $WORKSPACE/keys/*
echo "-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.11 (GNU/Linux)

mQGiBEsy5KkRBADJbDSISoamRM5AA20bfAeBuhhaI+VaiCVcxw90sq9AI5lIc42F
WzM2acm8yplqWiehAqOLKd+iIrqNGZ+VavZEPTx7o06UZUMRoPBiTFaCwrQ5avKz
lt7ij8PRMVWNrJ7A2lDYXfFQVV1o3Xo06qVnv0KLLUmiur0LBu4H/oTH3wCgt+/I
D3LUKaMJsc77KwFBTjHB0EsD/26Z2Ud12f3urSNyN6VMWnP3rz6xsmtY4Qsmkbnr
JuduxCQBZv6bX1Cr2ulXkv0fFOr+s5OyUv7zyCPbxiJFh3Br7fJGb0b5/M208KPe
giITY9hMh/aUbKjXCPoOXPxSL6SWOWV8taR6903EFyLBN0qno/kXIBKnVqBZobgn
jIEPA/0fTnxtZtE7EpirGQMF2caJfv7/LCgXmRs9xAhgbE0/caoa1tnc79uaHmLZ
FtbGFoAO31YNYM/IUHtmabbGdvZ4oYUwDhjBevVvC7aI+XhuNGK5mU8qCLLSEUOl
CUr6BJq/0iFmjwjmwk9idZEYhqSNy2OoYJbq45rbHfbdKLEVrbQeUk9TIEJ1aWxk
ZXIgPHJvc2J1aWxkQHJvcy5vcmc+iGAEExECACAFAksy5KkCGwMGCwkIBwMCBBUC
CAMEFgIDAQIeAQIXgAAKCRBVI7rusB+hFmk7AJ0XsLp05KA8l3YzAumZfjSN04MZ
jQCfQHfp4aQUXdOCUtetVo0QZUX3IuO5Ag0ESzLkrhAIAOCuSC83VXYWf8gOMSzd
xwpsH/uLV9Wze2LGnajsJLjEOhcsz2BHfxqNXhYaE9aQaodPCpbUAkPq8tLbpXy0
SWRCx0F5RcplXx5vIWbP6TlfPbRpK70w7IWd6vsNrjwEHjlhOLcNcj42sp5pgx4b
dceK06k5Ml2hYovPnD9o2TYgjOqg5FHZ2g1J0103n/66bN/hZnpLaZJYQiPWCyq6
K0565i1k2Y7hgWB/OXqwaqCehqmLTvpyQGzE1UJvKLuYU+T+4hBnSPbT3KIi5fCz
lIwvxijOMcfbkLhzYQXcU0Rd1VItcd5nmPL4z97jBxzuhkgxXpGR4WGKhvsA2Z9Y
UtsAAwYH/3Bf44bTpD9bVADUdab3e7zm8iHfh9K/a83mIgDB7mHV6WuemQVTf/1d
eu4mI5WtpbOCoucybGfjGIIAcSxwIx6VfC7HSp4J51bOpHhbdDffUEk6QVsZjwoF
yn3W9W3ZVeTI+ch/Qoo5a98SnmdjN8eXI/qCuiXOHc6rXDXc2R0iox/1EAS8xGVd
cYZe7IWBO2CjCknyhLrWxZHoy+i1GCZ9KvPF/Ef2dmLhCydT73ZlumsY8N5vm76Q
ul1G7f8LNbnMgXQafRkPffrAXSVhGY3Z2IiBwFNgxcKTq479l7yedYRGeU1A+SYI
YmRFWHXt3rTkMlQSpxCsB0fAYfrwEqqISQQYEQIACQUCSzLkrgIbDAAKCRBVI7ru
sB+hFpryAJ4puo6cMZxa6wITHFAM/k84+aRijwCeItuWpUngP25xDuDGMsKarcNi
qYE=
=Vgio
-----END PGP PUBLIC KEY BLOCK-----
" > $WORKSPACE/keys/0.key
echo "# END SECTION"
echo ""

echo "Build step 7"
rm -fr $WORKSPACE/docker_generating_dockers
mkdir -p $WORKSPACE/docker_generating_dockers

# monitor all subprocesses and enforce termination
python3 -u $WORKSPACE/ros_buildfarm/scripts/subprocess_reaper.py $$ --cid-file $WORKSPACE/docker_generating_dockers/docker.cid > $WORKSPACE/docker_generating_dockers/subprocess_reaper.log 2>&1 &
# sleep to give python time to startup
sleep 1

# generate Dockerfile, build and run it
# generating the Dockerfiles for the actual devel tasks
echo "# BEGIN SECTION: Generate Dockerfile - devel tasks"
export TZ="EST+05"
export PYTHONPATH=$WORKSPACE/ros_buildfarm:$PYTHONPATH
python3 -u $WORKSPACE/ros_buildfarm/scripts/devel/run_devel_job.py --rosdistro-index-url https://raw.githubusercontent.com/ros/rosdistro/master/index.yaml kinetic default prerelease ubuntu xenial amd64 --distribution-repository-urls http://repositories.ros.org/ubuntu/testing --distribution-repository-key-files $WORKSPACE/keys/0.key --dockerfile-dir $WORKSPACE/docker_generating_dockers
echo "# END SECTION"

echo "# BEGIN SECTION: Build Dockerfile - generating devel tasks"
cd $WORKSPACE/docker_generating_dockers
python3 -u $WORKSPACE/ros_buildfarm/scripts/misc/docker_pull_baseimage.py
docker build --force-rm -t devel_task_generation.kinetic_prerelease .
echo "# END SECTION"

echo "# BEGIN SECTION: Run Dockerfile - generating devel tasks"
rm -fr $WORKSPACE/docker_build_and_install
rm -fr $WORKSPACE/docker_build_and_test
mkdir -p $WORKSPACE/docker_build_and_install
mkdir -p $WORKSPACE/docker_build_and_test
docker run --rm  --cidfile=$WORKSPACE/docker_generating_dockers/docker.cid -e=HOME=/home/buildfarm -e=TRAVIS=$TRAVIS -e=ROS_BUILDFARM_PULL_REQUEST_BRANCH=$ROS_BUILDFARM_PULL_REQUEST_BRANCH -v $WORKSPACE/ros_buildfarm:/tmp/ros_buildfarm:ro -v $WORKSPACE/catkin_workspace:/tmp/catkin_workspace:ro -v $WORKSPACE/docker_build_and_install:/tmp/docker_build_and_install -v $WORKSPACE/docker_build_and_test:/tmp/docker_build_and_test -v ~/.ccache:/home/buildfarm/.ccache devel_task_generation.kinetic_prerelease
cd -
echo "# END SECTION"
echo ""

echo "Build step 8"
# monitor all subprocesses and enforce termination
python3 -u $WORKSPACE/ros_buildfarm/scripts/subprocess_reaper.py $$ --cid-file $WORKSPACE/docker_build_and_install/docker.cid > $WORKSPACE/docker_build_and_install/subprocess_reaper.log 2>&1 &
# sleep to give python time to startup
sleep 1

echo "# BEGIN SECTION: Build Dockerfile - build and install"
# build and run build_and_install Dockerfile
cd $WORKSPACE/docker_build_and_install
python3 -u $WORKSPACE/ros_buildfarm/scripts/misc/docker_pull_baseimage.py
docker build --force-rm -t devel_build_and_install.kinetic_prerelease .
echo "# END SECTION"

echo "# BEGIN SECTION: Run Dockerfile - build and install"
docker run --rm  --cidfile=$WORKSPACE/docker_build_and_install/docker.cid -e=TRAVIS=$TRAVIS -v $WORKSPACE/ros_buildfarm:/tmp/ros_buildfarm:ro -v $WORKSPACE/catkin_workspace:/tmp/catkin_workspace devel_build_and_install.kinetic_prerelease
cd -
echo "# END SECTION"
echo ""

echo "Build step 9"
# monitor all subprocesses and enforce termination
python3 -u $WORKSPACE/ros_buildfarm/scripts/subprocess_reaper.py $$ --cid-file $WORKSPACE/docker_build_and_test/docker.cid > $WORKSPACE/docker_build_and_test/subprocess_reaper.log 2>&1 &
# sleep to give python time to startup
sleep 1

echo "# BEGIN SECTION: Build Dockerfile - build and test"
# build and run build_and_test Dockerfile
cd $WORKSPACE/docker_build_and_test
python3 -u $WORKSPACE/ros_buildfarm/scripts/misc/docker_pull_baseimage.py
docker build --force-rm -t devel_build_and_test.kinetic_prerelease .
echo "# END SECTION"

echo "# BEGIN SECTION: Run Dockerfile - build and test"
docker run --rm  --cidfile=$WORKSPACE/docker_build_and_test/docker.cid -e=TRAVIS=$TRAVIS -v $WORKSPACE/ros_buildfarm:/tmp/ros_buildfarm:ro -v $WORKSPACE/catkin_workspace:/tmp/catkin_workspace devel_build_and_test.kinetic_prerelease
cd -
echo "# END SECTION"
echo ""

echo "Build step 10"
if [ "$skip_cleanup" = "false" ]; then
echo "# BEGIN SECTION: Clean up to save disk space on agents"
rm -fr catkin_workspace/build_isolated
rm -fr catkin_workspace/devel_isolated
rm -fr catkin_workspace/install_isolated
echo "# END SECTION"
fi
echo ""


echo ""
echo "Test results of underlay workspace"
echo ""

catkin_test_results_CMD="catkin_test_results $WORKSPACE/catkin_workspace/test_results --all"
echo "Invoking: $catkin_test_results_CMD"
echo ""
if type "catkin_test_results" > /dev/null; then
  set +e
  $catkin_test_results_CMD
  catkin_test_results_RC=$?
  set -e
  if [ -n "$ABORT_ON_TEST_FAILURE" -a "$ABORT_ON_TEST_FAILURE" != "0" ]; then
    (exit $catkin_test_results_RC)
  fi
else
  echo "'catkin_test_results' not found on the PATH. Please install catkin and source the environment to output the test result summary."
  catkin_test_results_RC=0
fi
catkin_test_results_RC_underlay=$catkin_test_results_RC
unset catkin_test_results_RC
if [ -n "$ABORT_ON_TEST_FAILURE_UNDERLAY" -a \
  "$ABORT_ON_TEST_FAILURE_UNDERLAY" != "0" ]
then
  (exit $catkin_test_results_RC_underlay)
fi
