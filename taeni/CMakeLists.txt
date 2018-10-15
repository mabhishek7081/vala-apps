cmake_minimum_required (VERSION 2.6)
project (taeni)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(ValaPrecompile)

find_package(PkgConfig)
pkg_check_modules(GTK3 REQUIRED gtk+-3.0>=3.14.0)
pkg_check_modules(VTE3 REQUIRED vte-2.91)

include_directories(${GTK3_INCLUDE_DIRS})
link_directories(${GTK3_LIBRARY_DIRS})

include_directories(${VTE3_INCLUDE_DIRS})
link_directories(${VTE3_LIBRARY_DIRS})

set(GETTEXT_PACKAGE "taeni")
add_definitions(-DGETTEXT_PACKAGE=\"taeni\")

vala_precompile(VALA_C 
    src/taeni.vala
PACKAGES
    gtk+-3.0
    vte-2.91
OPTIONS
    --vapidir=/usr/share/vala/vapi)
add_executable(taeni ${VALA_C})
target_link_libraries(taeni ${GTK3_LIBRARIES} ${VTE3_LIBRARIES} -lm)

set(CMAKE_INSTALL_PREFIX /usr)

install(TARGETS taeni DESTINATION bin)
install(FILES data/taeni.desktop DESTINATION share/applications)
install(FILES data/org.vala-apps.taeni.gschema.xml DESTINATION share/glib-2.0/schemas)
