cmake_minimum_required(VERSION 2.8.1)
project(Raytracer)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

SET(CMAKE_C_COMPILER ${CMAKE_CXX_COMPILER})
set(CMAKE_CXX_FLAGS "-Wall -Wextra -std=gnu++11")
set(CMAKE_CXX_FLAGS_DEBUG "-g")
set(CMAKE_CXX_FLAGS_RELEASE "-O2")

SET(CMAKE_COLOR_MAKEFILE ON)
SET(CMAKE_VERBOSE_MAKEFILE ON)

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    add_compile_options(-fdiagnostics-color=always)
elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    add_compile_options(-fcolor-diagnostics)
endif()

find_package(OpenCV REQUIRED COMPONENTS core highgui imgproc)

include_directories(../src/)

add_definitions(-DOPENCV_VERSION)
add_definitions(-DDEFAULT_RENDERER=SWRenderer)
AUX_SOURCE_DIRECTORY(../src/libfixmath libfixmath)

add_executable(rt
   ../src/main.cpp
   ../src/sphere.h
   ../src/timer.h
   ../src/timer.cpp
   ../src/base64.h
   ../src/base64.cpp
   ../src/vec3.h
   ../src/testscenes.h
   ../src/rtbase.h
   ../src/swrenderer.h
   ../src/swrenderer.cpp
   ${libfixmath})
set_property(TARGET rt PROPERTY CXX_STANDARD 11)
target_link_libraries(rt ${OpenCV_LIBS} pthread)

