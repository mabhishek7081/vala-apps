include(Gettext)

set(potfile "${CMAKE_CURRENT_SOURCE_DIR}/taeni.pot")
gettext_create_pot("${potfile}" SRCFILES "src/*.vala" WORKING_DIRECTORY ".")
option(UPDATE_PO "Update .po files." ON)

gettext_create_translations("${potfile}" ALL)
