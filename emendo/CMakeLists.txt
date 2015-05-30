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

set(GETTEXT_PACKAGE "${CMAKE_PROJECT_NAME}")
add_definitions(-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")

add_subdirectory (po)

vala_precompile(VALA_C 
    src/operations.vala
    src/tabs.vala
    src/preferences/prefdialog.vala
    src/preferences/settings.vala
    src/preferences/apply.vala
    src/search/replace.vala
    src/search/find.vala
    src/widgets/application.vala
    src/widgets/color.vala
    src/widgets/nbook.vala
    src/widgets/dialogs.vala
    src/widgets/mainwin.vala
PACKAGES
    gtk+-3.0
    gtksourceview-3.0
    gee-0.8
OPTIONS)
add_executable("${CMAKE_PROJECT_NAME}" ${VALA_C})
target_link_libraries("${CMAKE_PROJECT_NAME}" ${GTKSOURCEVIEW3_LIBRARIES} ${GEE-0.8_LIBRARIES} -lm)

set(CMAKE_INSTALL_PREFIX /usr)

install(TARGETS "${CMAKE_PROJECT_NAME}" DESTINATION bin)
install(FILES data/emendo.desktop DESTINATION share/applications)
install(FILES data/emendo.png DESTINATION share/icons/hicolor/64x64/apps)
install(FILES data/org.vala-apps.emendo.gschema.xml DESTINATION share/glib-2.0/schemas)
