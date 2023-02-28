cmake_minimum_required(VERSION 3.2)

set(CMAKE_CXX_STANDARD 14)

add_executable(test_ex test.cc)
if (UNIX)
  if (APPLE)
  target_link_libraries(test_ex ${CMAKE_SOURCE_DIR}/lib/libbayunrest.dylib)
  else (APPLE)
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -pthread")
  target_link_libraries(test_ex ${CMAKE_SOURCE_DIR}/lib/libbayunrest.so)
  endif (APPLE)
endif (UNIX)

include_directories(${CMAKE_SOURCE_DIR}/include)
