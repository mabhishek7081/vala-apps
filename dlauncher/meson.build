project('exe', ['vala', 'c'],
        version: '1.0',
        meson_version: '>=0.36')

gtk = dependency('gtk+-3.0')
gmenu = dependency('libgnome-menu-3.0')

vala_sources = [
    'src/cache.vala',
    'src/model.vala',
    'src/main.vala'
]

vala_args = [
    '--pkg=gtk+-3.0',
    '--pkg=libgnome-menu-3.0',
    '--pkg=gio-unix-2.0'
]

c_args = [
         '-DGMENU_I_KNOW_THIS_IS_UNSTABLE',
]

executable('dlauncher',
    vala_sources,
    vala_args: vala_args,
    c_args: c_args,
    install: true,
    dependencies : [gtk, gmenu])

datadir = get_option('datadir')

install_data('data/dlauncher.desktop',
    install_dir : join_paths(datadir, 'applications'))
