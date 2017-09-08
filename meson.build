project('DerelictPQ', 'd',
    meson_version: '>=0.44.1',
    license: 'BSL-1.0',
    version: '3.0.0'
)

project_soversion = '0'

#
# Dependencies
#
pkgc = import('pkgconfig')
pq_dep = dependency('libpq', version: '>= 9.6')

#
# Sources
#
derelict_pq_src = [
    'source/derelict/pq/pq.d',
    'source/derelict/pq/statfun.d',
    'source/derelict/pq/types.d',
    'source/derelict/pq/package.d',
    'source/derelict/pq/dynload.d'
]

src_dir = include_directories('source/')

#
# Targets
#
derelict_pq_lib = library('derelict-pq',
        [derelict_pq_src],
        include_directories: [src_dir],
        dependencies: [pq_dep],
        install: true,
        version: meson.project_version(),
        soversion: project_soversion,
        d_module_versions: ['Derelict_Static']
)
pkgc.generate(name: 'derelict-pq',
              libraries: derelict_pq_lib,
              subdirs: 'd/derelict',
              version: meson.project_version(),
              description: 'A dynamic binding to libpq for the D Programming Language.',
              d_module_versions: ['Derelict_Static']
)

# determine the right version flag for the compiler we use
dc = meson.get_compiler('d')
static_version_flag = '-fversion=Derelict_Static'
if dc.get_id() == 'llvm'
    static_version_flag = '-d-version=Derelict_Static'
elif dc.get_id() == 'dmd'
    static_version_flag = '-version=Derelict_Static'
endif

# to allow others to easily use this as a subproject
derelict_pq_dep = declare_dependency(
    link_with: [derelict_pq_lib],
    include_directories: [src_dir],
    compile_args: [static_version_flag]
)

#
# Install
#
install_subdir('source/derelict/', install_dir: 'include/d/derelict/')
