project('exe', ['vala', 'c'],
        version: '1.0',
        meson_version: '>=0.36')

gtk = dependency('gtk+-3.0')

vala_sources = [
    'src/main.vala',
    'src/settings.vala'
]

vala_args = [
    '--pkg=gtk+-3.0',
]

executable('gtk-appearance',
    vala_sources,
    vala_args: vala_args,
    install: true,
    dependencies : [gtk])

datadir = get_option('datadir')

install_data('data/gtk-appearance.desktop',
    install_dir : join_paths(datadir, 'applications'))
