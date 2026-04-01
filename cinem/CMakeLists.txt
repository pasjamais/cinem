cmake_minimum_required(VERSION 3.16)
project(cinem)
# .cpp
file(GLOB CINEM_SOURCES *.cpp)

add_executable(cinem ${CINEM_SOURCES})

# tvision and SQL module
target_link_libraries(cinem PRIVATE tvision sql_module)

#  current directory for headers
target_include_directories(cinem PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
