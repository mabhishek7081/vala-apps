DESTDIR?=

CFLAGS=--target-glib=2.38 --pkg gtk+-3.0
LDFLAGS=-X -DGETTEXT_PACKAGE=\"$(BINARY)\" -X -w
SOURCE=src/*.vala
BINARY=wpset

all:
	valac $(CFLAGS) $(LDFLAGS) $(SOURCE) -o $(BINARY)
	gcc src/imlibsetroot.c -o imlibsetroot -lImlib2 -lX11 -lXinerama

clean:
	rm $(BINARY)
	rm imlibsetroot
	rm po/sr/$(BINARY).mo

gen_mo:
	msgfmt -c -v -o po/sr/$(BINARY).mo po/sr/$(BINARY).po

gen_po:
	xgettext --language=C --keyword=_ --escape --sort-output -o po/$(BINARY).pot $(SOURCE)
	msgmerge -s -U po/sr/$(BINARY).po po/$(BINARY).pot

install: all gen_mo
	install -Dm755 $(BINARY) $(DESTDIR)/usr/bin/$(BINARY)
	install -Dm755 imlibsetroot $(DESTDIR)/usr/bin/imlibsetroot
	install -Dm755 data/$(BINARY)-shell $(DESTDIR)/usr/bin/$(BINARY)-shell
	install -Dm644 data/$(BINARY).desktop $(DESTDIR)/usr/share/applications/$(BINARY).desktop
	install -Dm644 data/org.vala-apps.$(BINARY).gschema.xml $(DESTDIR)/usr/share/glib-2.0/schemas/org.vala-apps.$(BINARY).gschema.xml
	install -Dm644 po/sr/$(BINARY).mo $(DESTDIR)/usr/share/locale/sr/LC_MESSAGES/$(BINARY).mo

uninstall:
	rm $(DESTDIR)/usr/bin/$(BINARY)
	rm $(DESTDIR)/usr/bin/imlibsetroot
	rm $(DESTDIR)/usr/bin/$(BINARY)-shell
	install -Dm644 data/$(BINARY).desktop $(DESTDIR)/usr/share/applications/$(BINARY).desktop
	rm $(DESTDIR)/usr/share/glib-2.0/schemas/org.vala-apps.$(BINARY).gschema.xml
	rm $(DESTDIR)/usr/share/locale/sr/LC_MESSAGES/$(BINARY).mo
