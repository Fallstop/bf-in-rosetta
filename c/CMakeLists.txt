cmake_minimum_required(VERSION 3.5)

project(bf-c)

include_directories("include")

add_executable(c main.c src/sized_string.c src/runner.c)