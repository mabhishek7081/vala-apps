project('exe', ['vala', 'c'],
        version: '1.0',
        meson_version: '>=0.36')

cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required : true)

gtk = dependency('gtk+-3.0')

vala_sources = [
    'src/voyager.vala'
]

vala_args = [
    '--pkg=gtk+-3.0',
]

executable('voyager',
    vala_sources,
    vala_args: vala_args,
    install: true,
    dependencies : [gtk, m_dep])

datadir = get_option('datadir')

install_data('data/voyager.desktop',
    install_dir : join_paths(datadir, 'applications'))

install_data('data/org.vala-apps.voyager.gschema.xml',
    install_dir: join_paths(datadir, 'glib-2.0' ,'schemas'))
