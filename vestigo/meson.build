project('exe', ['vala', 'c'],
        version: '1.0',
        meson_version: '>=0.36')

gtk = dependency('gtk+-3.0')

vala_sources = [
    'src/settings.vala',
    'src/vars.vala',
    'src/operations.vala',
    'src/monitor.vala',
    'src/menu.vala',
    'src/iconview.vala',
    'src/window.vala',
    'src/main.vala'
]

vala_args = [
    '--pkg=gtk+-3.0',
]

exe = executable('vestigo',
    vala_sources,
    vala_args: vala_args,
    install: true,
    dependencies : [gtk])

datadir = get_option('datadir')

install_data('data/vestigo.desktop',
    install_dir : join_paths(datadir, 'applications'))

install_data('data/org.vala-apps.vestigo.gschema.xml',
    install_dir: join_paths(datadir, 'glib-2.0' ,'schemas'))
