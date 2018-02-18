project('exe', ['vala', 'c'],
        version: '1.0',
        meson_version: '>=0.36')

gtk = dependency('gtk+-3.0')
imlib = dependency('imlib2')
x11 = dependency('x11')
xinerama = dependency('xinerama')

vala_sources = [
    'src/wpset.vala'
]

vala_args = [
    '--pkg=gtk+-3.0'
]

executable('wpset',
    vala_sources,
    vala_args: vala_args,
    install: true,
    dependencies : [gtk])
executable('imlibsetroot', 
    'src/imlibsetroot.c', 
    install: true,
    dependencies : [imlib, x11, xinerama])

datadir = get_option('datadir')

install_data('data/wpset.desktop',
    install_dir : join_paths(datadir, 'applications'))

install_data('data/org.vala-apps.wpset.gschema.xml',
    install_dir: join_paths(datadir, 'glib-2.0' ,'schemas'))

