cmake_minimum_required (VERSION 2.6)
project (voyager)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(ValaPrecompile)

find_package(PkgConfig)
pkg_check_modules(GTK3 REQUIRED gtk+-3.0>=3.22.0)

include_directories(${GTK3_INCLUDE_DIRS})
link_directories(${GTK3_LIBRARY_DIRS})

set(GETTEXT_PACKAGE "voyager")
add_definitions(-DGETTEXT_PACKAGE=\"voyager\")

vala_precompile(VALA_C 
    src/voyager.vala
PACKAGES
    gtk+-3.0
OPTIONS)
add_executable(voyager ${VALA_C})
target_link_libraries(voyager ${GTK3_LIBRARIES} -lm)

set(CMAKE_INSTALL_PREFIX /usr)

install(TARGETS voyager DESTINATION bin)
install(FILES data/voyager.desktop DESTINATION share/applications)
install(FILES data/org.vala-apps.voyager.gschema.xml DESTINATION share/glib-2.0/schemas)
