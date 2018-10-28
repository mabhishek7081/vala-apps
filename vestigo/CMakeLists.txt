cmake_minimum_required (VERSION 2.6)
project (vestigo)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(ValaPrecompile)

find_package(PkgConfig)
pkg_check_modules(GTK3 REQUIRED gtk+-3.0>=3.14.0)
pkg_check_modules(GUDEV REQUIRED gudev-1.0)

include_directories(${GTK3_INCLUDE_DIRS})
link_directories(${GTK3_LIBRARY_DIRS})

include_directories(${GUDEV_INCLUDE_DIRS})
link_directories(${GUDEV_LIBRARY_DIRS})

set(GETTEXT_PACKAGE "vestigo")
add_definitions(-DGETTEXT_PACKAGE=\"vestigo\")

vala_precompile(VALA_C 
    src/iconview.vala
    src/main.vala
    src/menu.vala
    src/monitor.vala
    src/operations.vala
    src/settings.vala
    src/thumbnails.vala
    src/vars.vala
    src/window.vala
PACKAGES
    gtk+-3.0
    gudev-1.0
OPTIONS
)

add_executable(vestigo ${VALA_C})
target_link_libraries(vestigo ${GTK3_LIBRARIES} ${GUDEV_LIBRARIES})

set(CMAKE_INSTALL_PREFIX /usr)

install(TARGETS vestigo DESTINATION bin)
install(FILES data/vestigo.desktop DESTINATION share/applications)
install(FILES data/org.vala-apps.vestigo.gschema.xml DESTINATION share/glib-2.0/schemas)


