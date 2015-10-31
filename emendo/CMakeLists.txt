cmake_minimum_required (VERSION 2.6)
project (emendo)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(ValaPrecompile)

find_package(PkgConfig)
pkg_check_modules(GTK3 REQUIRED gtk+-3.0)
pkg_check_modules(GTKSOURCEVIEW3 REQUIRED gtksourceview-3.0)
pkg_check_modules(GEE-0.8 REQUIRED gee-0.8)

include_directories(${GTKSOURCEVIEW3_INCLUDE_DIRS})
link_directories(${GTKSOURCEVIEW3_LIBRARY_DIRS})

include_directories(${GEE-0.8_INCLUDE_DIRS})
link_directories(${GEE-0.8_LIBRARY_DIRS})

set(GETTEXT_PACKAGE emendo)
add_definitions(-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")

add_subdirectory (po)

vala_precompile(VALA_C 
    src/operations.vala
    src/tabs.vala
    src/prefdialog.vala
    src/settings.vala
    src/apply.vala
    src/replace.vala
    src/find.vala
    src/application.vala
    src/color.vala
    src/nbook.vala
    src/dialogs.vala
    src/mainwin.vala
PACKAGES
    gtk+-3.0
    gtksourceview-3.0
    gee-0.8
OPTIONS)
add_executable(emendo ${VALA_C})
target_link_libraries(emendo ${GTKSOURCEVIEW3_LIBRARIES} ${GEE-0.8_LIBRARIES} -lm)

set(CMAKE_INSTALL_PREFIX /usr)

install(TARGETS emendo DESTINATION bin)
install(FILES data/emendo.desktop DESTINATION share/applications)
install(FILES data/org.vala-apps.emendo.gschema.xml DESTINATION share/glib-2.0/schemas)
