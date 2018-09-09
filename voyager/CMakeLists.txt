cmake_minimum_required (VERSION 2.6)
project (voyager)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(ValaPrecompile)

find_package(PkgConfig)
pkg_check_modules(GTK3 REQUIRED gtk+-3.0>=3.8.0)

pkg_check_modules (GTK_3_22 QUIET gtk+-3.0>=3.20)
if (GTK_3_22_FOUND)
    set (GLOBAL_VALAC_OPTIONS ${GLOBAL_VALAC_OPTIONS} --define=GTK_3_22)
    message ("-- Compiling for Gtk 3.22")
else (GTK_3_22_FOUND)
    message ("-- Compiling for Gtk 3.18")
endif (GTK_3_22_FOUND)

include_directories(${GTK3_INCLUDE_DIRS})
link_directories(${GTK3_LIBRARY_DIRS})

set(GETTEXT_PACKAGE "voyager")
add_definitions(-DGETTEXT_PACKAGE=\"voyager\")

vala_precompile(VALA_C 
    src/voyager.vala
PACKAGES
    gtk+-3.0
OPTIONS
    ${GLOBAL_VALAC_OPTIONS})
add_executable(voyager ${VALA_C})
target_link_libraries(voyager ${GTK3_LIBRARIES} -lm)

set(CMAKE_INSTALL_PREFIX /usr)

install(TARGETS voyager DESTINATION bin)
install(FILES data/voyager.desktop DESTINATION share/applications)
install(FILES data/org.vala-apps.voyager.gschema.xml DESTINATION share/glib-2.0/schemas)
