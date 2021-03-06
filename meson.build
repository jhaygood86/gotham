project(
    'io.github.jhaygood86.gotham', 'vala', 'c',
    meson_version: '>= 0.49',
    version: '0.1.0'
)

vapi_dir = meson.current_source_dir() / 'vapi'
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'src/Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

icon_res = gnome.compile_resources(
    'mauborgne-icon-resources',
    join_paths('data', 'gresource.xml'),
    source_dir: 'data'
)

gotham_deps = [
    dependency('gobject-2.0'),
    dependency('gtk+-3.0'),
    dependency('libhandy-1', version: '>=0.90.0'),
    dependency('granite', version: '>=6.0.0'),
    dependency('gee-0.8'),
    dependency('appstream-glib')
]

executable(
    meson.project_name(),
    icon_res,
    config_file,
    'src/AppModel.vala',
    'src/Application.vala',
    'src/MainWindow.vala',
    'src/ApplicationRow.vala',
    dependencies: gotham_deps,
    install: true
)

subdir('data')
