from Cython.Compiler import Options
from setuptools import Extension, setup
from Cython.Build import cythonize
import sys
import platform

import numpy as np
# import os

# os.environ["OMP_THREAD_LIMIT"] = "1"
# os.environ["MAGICK_THREAD_LIMIT"] = "1"
# os.environ["KMP_ALL_THREADS"] = "1"
# os.environ["KMP_TEAMS_THREAD_LIMIT"] = "1"
# os.environ["OMP_THREAD_LIMIT"] = "1"
# os.environ["KMP_DEVICE_THREAD_LIMIT"] = "1"

numpyincludefolder = np.get_include()

iswindows = "win" in platform.platform().lower()
name = "keycode"

Options.docstrings = False
Options.embed_pos_in_docstring = False
Options.generate_cleanup_code = False
Options.clear_to_none = True
Options.annotate = True
Options.fast_fail = False
Options.warning_errors = False
Options.error_on_unknown_names = True
Options.error_on_uninitialized = True
Options.convert_range = True
Options.cache_builtins = True
Options.gcc_branch_hints = True
Options.lookup_module_cpdef = False
Options.embed = False
Options.cimport_from_pyx = True
Options.buffer_max_dims = 8
Options.closure_freelist_size = 8


configdict = {
    "py_limited_api": False,
    "name": name,
    "sources": [
        name + ".pyx",
    ],
    "include_dirs": [
        numpyincludefolder,
    ],
    "define_macros": [
        ("NPY_NO_DEPRECATED_API", 1),
        # ("NPY_1_7_API_VERSION", 0),
        # ("CYTHON_USE_DICT_VERSIONS", 0),
        # ("CYTHON_FAST_GIL", 1),
        # ("CYTHON_USE_PYLIST_INTERNALS", 1),
        # ("CYTHON_USE_UNICODE_INTERNALS", 1),
        # ("CYTHON_ASSUME_SAFE_MACROS", 1),
        # ("CYTHON_USE_TYPE_SLOTS", 1),
        # ("CYTHON_USE_PYTYPE_LOOKUP", 1),
        # ("CYTHON_USE_ASYNC_SLOTS", 1),
        # ("CYTHON_USE_PYLONG_INTERNALS", 1),
        # ("CYTHON_USE_UNICODE_WRITER", 1),
        # ("CYTHON_UNPACK_METHODS", 1),
        # ("CYTHON_USE_EXC_INFO_STACK", 1),
        # ("CYTHON_ATOMICS", 1),
    ],
    "undef_macros": [],
    "library_dirs": [],
    "libraries": [],
    "runtime_library_dirs": [],
    "extra_objects": [],
    "extra_compile_args": [
        # "/std:c++20",
    ]
    if iswindows
    else [
        "-march=native",
        "-mtune=native",
        "-std=c++2a",
        "-ferror-limit=1000000",
        "-pthread",
        # "-flto-jobs=1",
    ],
    "extra_link_args": [],
    "export_symbols": [],
    "swig_opts": [],
    "depends": [],
    "language": "c++",
    "optional": None,
}
compiler_directives = {
    "binding": False,
    "boundscheck": False,
    "wraparound": False,
    "initializedcheck": False,
    "nonecheck": False,
    "overflowcheck": False,
    "overflowcheck.fold": True,
    "embedsignature": True,
    "embedsignature.format": "c",  # (c / python / clinic)
    "cdivision": True,
    "cdivision_warnings": True,
    "cpow": True,
    "always_allow_keywords": True,
    "c_api_binop_methods": False,
    "profile": False,
    "linetrace": False,
    "infer_types": True,
    "language_level": 3,  # (2/3/3str)
    "c_string_type": "bytes",  # (bytes / str / unicode)
    "c_string_encoding": "ascii",  # (ascii, default, utf-8, etc.)
    "type_version_tag": False,
    "unraisable_tracebacks": True,
    "iterable_coroutine": True,
    "annotation_typing": True,
    "emit_code_comments": True,
    "cpp_locals": False,
    "legacy_implicit_noexcept": False,
    "optimize.use_switch": True,
    "optimize.unpack_method_calls": True,
    "warn.undeclared": True,  # (default False)
    "warn.unreachable": True,  # (default True)
    "warn.maybe_uninitialized": True,  # (default False)
    "warn.unused": True,  # (default False)
    "warn.unused_arg": True,  # (default False)
    "warn.unused_result": True,  # (default False)
    "warn.multiple_declarators": True,  # (default True)
    "show_performance_hints": True,  # (default True)
}
compdi = configdict
clidict = compiler_directives

ext_modules = Extension(**configdict)

setup(
    name=name,
    ext_modules=cythonize(ext_modules, compiler_directives=compiler_directives),
)
sys.exit(0)
