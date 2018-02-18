project('exe', ['vala', 'c'],
        version: '1.0',
        meson_version: '>=0.36')

cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required : true)

gtk = dependency('gtk+-3.0')
gtksourceview = dependency('gtksourceview-3.0')

vala_sources = [
    'src/prefdialog.vala',
    'src/settings.vala',
    'src/operations.vala',
    'src/application.vala',
    'src/replace.vala',
    'src/tabs.vala',
    'src/color.vala',
    'src/apply.vala',
    'src/nbook.vala',
    'src/find.vala',
    'src/dialogs.vala',
    'src/mainwin.vala'
]

vala_args = [
    '--pkg=gtk+-3.0',
    '--pkg=gtksourceview-3.0',
]

executable('emendo',
    vala_sources,
    vala_args: vala_args,
    install: true,
    dependencies : [gtk, gtksourceview, m_dep])

datadir = get_option('datadir')

install_data('data/emendo.desktop',
    install_dir : join_paths(datadir, 'applications'))

install_data('data/org.vala-apps.emendo.gschema.xml',
    install_dir: join_paths(datadir, 'glib-2.0' ,'schemas'))
