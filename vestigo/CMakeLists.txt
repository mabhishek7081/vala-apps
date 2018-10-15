cmake_minimum_required (VERSION 2.6)
project (vestigo)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(ValaPrecompile)

find_package(PkgConfig)
pkg_check_modules(GTK3 REQUIRED gtk+-3.0>=3.14.0)

include_directories(${GTK3_INCLUDE_DIRS})
link_directories(${GTK3_LIBRARY_DIRS})

set(GETTEXT_PACKAGE "vestigo")
add_definitions(-DGETTEXT_PACKAGE=\"vestigo\")

vala_precompile(VALA_C 
    src/settings.vala
    src/vars.vala
    src/operations.vala
    src/monitor.vala
    src/menu.vala
    src/iconview.vala
    src/window.vala
    src/main.vala
PACKAGES
    gtk+-3.0
OPTIONS)
add_executable(vestigo ${VALA_C})
target_link_libraries(vestigo ${GTK3_LIBRARIES})

set(CMAKE_INSTALL_PREFIX /usr)

install(TARGETS vestigo DESTINATION bin)
install(FILES data/vestigo.desktop DESTINATION share/applications)
install(FILES data/org.vala-apps.vestigo.gschema.xml DESTINATION share/glib-2.0/schemas)
