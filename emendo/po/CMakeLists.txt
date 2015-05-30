include(Gettext)

set(potfile "${CMAKE_CURRENT_SOURCE_DIR}/emendo.pot")
gettext_create_pot("${potfile}" SRCFILES "src/*.vala src/widgets/*.vala src/preferences/*.vala src/search/*.vala" WORKING_DIRECTORY ".")
option(UPDATE_PO "Update .po files." ON)

gettext_create_translations("${potfile}" ALL)

#xgettext --language=C --keyword=_ --escape --sort-output -o po/emendo.pot src/*.vala src/widgets/*.vala src/preferences/*.vala src/search/*.vala
