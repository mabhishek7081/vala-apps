project('exe', ['vala', 'c'],
        version: '1.0',
        meson_version: '>=0.36')

gtk = dependency('gtk+-3.0')
poppler = dependency('poppler-glib')

vala_sources = [
    'src/settings.vala',
    'src/pagezoom.vala',
    'src/viewer.vala',
    'src/main.vala',
    'src/dialogs.vala'
]

vala_args = [
    '--pkg=gtk+-3.0',
    '--pkg=poppler-glib',
]

executable('agatha',
    vala_sources,
    vala_args: vala_args,
    install: true,
    dependencies : [gtk, poppler])

datadir = get_option('datadir')

install_data('data/agatha.desktop',
    install_dir : join_paths(datadir, 'applications'))

install_data('data/org.vala-apps.agatha.gschema.xml',
    install_dir: join_paths(datadir, 'glib-2.0' ,'schemas'))
