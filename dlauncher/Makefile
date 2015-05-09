DESTDIR?=

CFLAGS=--target-glib=2.38 --pkg gtk+-3.0 --pkg gio-unix-2.0 --pkg libgnome-menu-3.0
LDFLAGS=-X -DGETTEXT_PACKAGE=\"$(BINARY)\" -X "-DGMENU_I_KNOW_THIS_IS_UNSTABLE" -X -w
SOURCE=src/*.vala
BINARY=dlauncher

all:
	valac $(CFLAGS) $(LDFLAGS) $(SOURCE) -o $(BINARY)

clean:
	rm $(BINARY)

install: all
	install -Dm755 $(BINARY) $(DESTDIR)/usr/bin/$(BINARY)
	install -Dm644 data/$(BINARY).desktop $(DESTDIR)/usr/share/applications/$(BINARY).desktop
	install -Dm644 data/$(BINARY).png $(DESTDIR)/usr/share/icons/hicolor/64x64/apps/$(BINARY).png

uninstall:
	rm $(DESTDIR)/usr/bin/$(BINARY)
	rm $(DESTDIR)/usr/share/applications/$(BINARY).desktop
	rm $(DESTDIR)/usr/share/icons/hicolor/64x64/apps/$(BINARY).png
