execute_process(COMMAND "/tmp/catkin_workspace/build_isolated/gripit/catkin_generated/python_distutils_install.sh" RESULT_VARIABLE res)

if(NOT res EQUAL 0)
  message(FATAL_ERROR "execute_process(/tmp/catkin_workspace/build_isolated/gripit/catkin_generated/python_distutils_install.sh) returned error code ")
endif()
