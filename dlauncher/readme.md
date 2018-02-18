Dlauncher
=======

Application launcher

How to install?
````
cd vala-apps/dlauncher
mkdir build; cd build
meson --prefix=/usr --buildtype=plain
ninja install
gtk-update-icon-cache /usr/share/icons/hicolor
glib-compile-schemas /usr/share/glib-2.0/schemas
````
Dependencies:
````
gtk+-3.0 >= 3.10
libgnome-menu-3.0
````
