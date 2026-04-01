cmake_minimum_required(VERSION 3.16)
project(DemoProject)

# -----------------------
# SQLite3
# -----------------------
add_library(sqlite3 STATIC external/sqlite/sqlite3.c)
target_include_directories(sqlite3 PUBLIC external/sqlite)

# -----------------------
# tvision
# -----------------------
add_subdirectory(external/tvision)

# -----------------------
# sql module (cinem/sql.cpp)
# -----------------------
add_library(sql_module cinem/sql.cpp)
target_link_libraries(sql_module PUBLIC sqlite3)
target_include_directories(sql_module PUBLIC cinem)

# -----------------------
# cinem executable
# -----------------------
add_executable(cinem cinem/cinem.cpp)
target_link_libraries(cinem PRIVATE tvision sql_module)
target_include_directories(cinem PRIVATE cinem)
