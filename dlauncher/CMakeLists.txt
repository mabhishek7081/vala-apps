cmake_minimum_required (VERSION 2.6)
project (dlauncher)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(ValaPrecompile)

find_package(PkgConfig)
pkg_check_modules(GTK3 REQUIRED gtk+-3.0>=3.8.0)

include_directories(${GTK3_INCLUDE_DIRS})
link_directories(${GTK3_LIBRARY_DIRS})

set(GETTEXT_PACKAGE "dlauncher")
add_definitions(-DGETTEXT_PACKAGE=\"dlauncher\")

vala_precompile(VALA_C 
    src/cache.vala
    src/model.vala
    src/main.vala
PACKAGES
    gtk+-3.0
    gio-unix-2.0
OPTIONS
    ${GLOBAL_VALAC_OPTIONS})
add_executable(dlauncher ${VALA_C})
target_link_libraries(dlauncher ${GTK3_LIBRARIES})

set(CMAKE_INSTALL_PREFIX /usr)

install(TARGETS dlauncher DESTINATION bin)
install(FILES data/dlauncher.desktop DESTINATION share/applications)
