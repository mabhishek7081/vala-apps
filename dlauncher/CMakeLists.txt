cmake_minimum_required (VERSION 2.6)
project (dlauncher)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(ValaPrecompile)

find_package(PkgConfig)
pkg_check_modules(GTK3 REQUIRED gtk+-3.0)
pkg_check_modules(LIBGNOME-MENU REQUIRED libgnome-menu-3.0)

include_directories(${GTK3_INCLUDE_DIRS})
link_directories(${GTK3_LIBRARY_DIRS})

include_directories(${LIBGNOME-MENU_INCLUDE_DIRS})
link_directories(${LIBGNOME-MENU_LIBRARY_DIRS})

set(GETTEXT_PACKAGE "dlauncher")
add_definitions(-DGETTEXT_PACKAGE=\"dlauncher\")

set(CFLAGS -DGMENU_I_KNOW_THIS_IS_UNSTABLE)
add_definitions(${CFLAGS})

vala_precompile(VALA_C 
    src/cache.vala
    src/model.vala
    src/style.vala
    src/main.vala
PACKAGES
    gtk+-3.0
    gio-unix-2.0
    libgnome-menu-3.0
OPTIONS)
add_executable("${CMAKE_PROJECT_NAME}" ${VALA_C})
target_link_libraries("${CMAKE_PROJECT_NAME}" ${GTK3_LIBRARIES} ${LIBGNOME-MENU_LIBRARIES})

set(CMAKE_INSTALL_PREFIX /usr)

install(TARGETS dlauncher DESTINATION bin)
install(FILES data/dlauncher.desktop DESTINATION share/applications)
install(FILES data/dlauncher.png DESTINATION share/icons/hicolor/64x64/apps)
