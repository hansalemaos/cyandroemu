cimport cython
cimport numpy as np
from libc.stdint cimport int64_t
from libcpp.string cimport string,npos
from libcpp.utility cimport pair
from libcpp.vector cimport vector
from types import GeneratorType
from typing import Any, Generator
from collections import defaultdict
from collections.abc import Iterable
from functools import lru_cache
from functools import reduce
from itertools import takewhile
import collections
import cython
import io
import numpy as np
import os
import pandas as pd
import re as repy
import regex as re
import typing
from operator import itemgetter as operator_itemgetter
from operator import getitem as operator_getitem
from contextlib import suppress as contextlib_suppress
re.cache_all(True)


class Tuppsub(tuple):
    pass

#######################################################################################################################################
###################################################### Global vars ####################################################################
cdef:
    object regex_device_size_node_name = repy.compile(
    r"(?P<tmpindex>^[\d]+)\|(?P<aa_DEVICE>[\d,]+)\s+(?P<aa_SIZE>[\dt]+)\s+(?P<aa_NODE>\d+)\s+(?P<aa_NAME>.*$)",
    flags=re.I,
    )
    object regex_package_start = re.compile("^package:", flags=re.I).sub
    object regex_netstat = re.compile(rb"^\w+\s+\d+\s+\d+.*\s+\d+/.*$", flags=re.I).match
    object proc_match = re.compile(rb"^\s*\d+\s+\w+\s+.*$", flags=re.I).match
    list[str] columns_files = [
        "aa_PermissionsSymbolic",
        "aa_SELinuxContext",
        "aa_FileSize",
        "aa_OwnerUsername",
        "aa_GroupName",
        "aa_SymlinkTarget",
        "aa_ModificationTimestampEpoch",
        "aa_OwnerUID",
        "aa_GroupGID",
        "aa_PermissionsOctal",
        "aa_FullPath",
        "aa_FileName",
    ]
    dict[str,object] dtypes_files = {
        "aa_PermissionsSymbolic": np.dtype("object"),
        "aa_SELinuxContext": np.dtype("object"),
        "aa_FileSize": np.dtype("int64"),
        "aa_OwnerUsername": np.dtype("object"),
        "aa_GroupName": np.dtype("object"),
        "aa_SymlinkTarget": np.dtype("object"),
        "aa_ModificationTimestampEpoch": np.dtype("float64"),
        "aa_OwnerUID": np.dtype("int64"),
        "aa_GroupGID": np.dtype("int64"),
        "aa_PermissionsOctal": np.dtype("int64"),
        "aa_FullPath": np.dtype("object"),
        "aa_FileName": np.dtype("object"),
    }
    list[str] dict_variation=[
        "collections.defaultdict",
        "collections.UserDict",
        "collections.OrderedDict",
    ]
    object forbidden = (
        list,
        tuple,
        set,
        frozenset,
    )
    object allowed = (
        str,
        int,
        float,
        complex,
        bool,
        bytes,
        type(None),
        Tuppsub,
    )


#####################################################################################################################################
###################################################### C++ Stuff ####################################################################

cdef extern from "split_string.hpp" nogil :
    vector[string] split_string(string& input, string& delimiter)

cdef extern from "timeoutstuff.hpp" nogil :
    int64_t get_current_timestamp()


cdef extern from "cppsleep.hpp" nogil :
    void sleep_milliseconds(int milliseconds)

cdef extern from "stripstring.hpp" nogil :
    void strip_spaces_inplace(string& s)

cdef extern from "nonblockingsubprocess.hpp" nogil :
    cdef cppclass ShellProcessManager:
        void ShellProcessManager(
            string shell_command,
            size_t buffer_size,
            size_t stdout_max_len,
            size_t stderr_max_len,
            string exit_command,
            int print_stdout,
            int print_stderr)
        bint start_shell()
        bint stdin_write(string)
        string get_stdout()
        string get_stderr()
        void stop_shell()
        void clear_stdout()
        void clear_stderr()
        bint continue_reading_stdout
        bint continue_reading_stderr
#######################################################################################################################################
###################################################### Cython Stuff ####################################################################

cdef list convert_to_list(object folders):
    if not isinstance(folders, list):
        folders = [folders]
    return folders

def touch(path: str) -> bool:
    def _fullpath(path):
        return os.path.abspath(os.path.expanduser(path))

    def _mkdir(path):
        path = path.replace("\\", "/")
        if path.find("/") > 0 and not os.path.exists(os.path.dirname(path)):
            os.makedirs(os.path.dirname(path))

    def _utime(path):
        try:
            os.utime(path, None)
        except Exception:
            open(path, "a").close()

    def touch_(path):
        if path:
            path = _fullpath(path)
            _mkdir(path)
            _utime(path)

    try:
        touch_(path)
        return True
    except Exception as Fe:
        print(Fe)
        return False


def calculate_chmod(object s):
    cdef:
        Py_ssize_t last_index = len(s) - 1
        Py_ssize_t final_result = 0
    if len(s) < 9:
        return -1
    if isinstance(s, str):
        if s[last_index] != "-":
            final_result += 1
        if s[last_index - 1] != "-":
            final_result += 2
        if s[last_index - 2] != "-":
            final_result += 4
        if s[last_index - 3] != "-":
            final_result += 10
        if s[last_index - 4] != "-":
            final_result += 20
        if s[last_index - 5] != "-":
            final_result += 40
        if s[last_index - 6] != "-":
            final_result += 100
        if s[last_index - 7] != "-":
            final_result += 200
        if s[last_index - 8] != "-":
            final_result += 400
        return final_result
    if s[last_index] != 45:
        final_result += 1
    if s[last_index - 1] != 45:
        final_result += 2
    if s[last_index - 2] != 45:
        final_result += 4
    if s[last_index - 3] != 45:
        final_result += 10
    if s[last_index - 4] != 45:
        final_result += 20
    if s[last_index - 5] != 45:
        final_result += 40
    if s[last_index - 6] != 45:
        final_result += 100
    if s[last_index - 7] != 45:
        final_result += 200
    if s[last_index - 8] != 45:
        final_result += 400
    return final_result


################################################# START Recursive Dictstuff ###############################################################
class subi(dict):
    def __missing__(self, k):
        self[k] = self.__class__()
        return self[k]

cdef list_split(l, indices_or_sections):
    Ntotal = len(l)
    try:
        Nsections = len(indices_or_sections) + 1
        div_points = [0] + list(indices_or_sections) + [Ntotal]
    except TypeError:
        Nsections = int(indices_or_sections)
        if Nsections <= 0:
            raise ValueError("number sections must be larger than 0.") from None
        Neach_section, extras = divmod(Ntotal, Nsections)
        section_sizes = (
            [0] + extras * [Neach_section + 1] + (Nsections - extras) * [Neach_section]
        )
        div_points = []
        new_sum = 0
        for i in section_sizes:
            new_sum += i
            div_points.append(new_sum)

    sub_arys = []
    lenar = len(l)
    for i in range(Nsections):
        st = div_points[i]
        end = div_points[i + 1]
        if st >= lenar:
            break
        sub_arys.append((l[st:end]))

    return sub_arys

@cython.boundscheck(True)
@cython.wraparound(True)
@cython.nonecheck(True)
cdef bint isiter(
    object x,
    object consider_iter = (),
    object consider_non_iter = (),
):
    if type(x) in consider_iter:
        return True
    if type(x) in consider_non_iter:
        return False
    if isinstance(x, (int, float, bool, complex, type(None))):
        return False
    if isinstance(x, (list, tuple, set, frozenset, dict)):
        return True
    if isinstance(x, (GeneratorType,Iterable,collections.abc.Iterable,collections.abc.Sequence,typing.Iterable,typing.Iterator)):
        return True
    try:
        iter(x)
        return True
    except Exception:
        pass
    if hasattr(x, "__contains__"):
        try:
            for _ in x:
                return True
        except Exception:
            pass
    if hasattr(x, "__len__"):
        try:
            for _ in x:
                return True
        except Exception:
            pass
    if hasattr(x, "__getitem__"):
        try:
            for _ in x:
                return True
        except Exception:
            pass
    if hasattr(x, "__iter__"):
        try:
            for _ in x:
                return True
        except Exception:
            pass
    if not hasattr(x, "__trunc__"):
        try:
            for _ in x:
                return True
        except Exception:
            pass
    try:
        for _ in x:
            return True
    except Exception:
        pass
    return False

def convert_to_normal_dict(di):
    if isinstance(di, defaultdict):
        di = {k: convert_to_normal_dict(v) for k, v in di.items()}
    return di

def nested_dict():
    return defaultdict(nested_dict)

@cython.boundscheck(True)
@cython.wraparound(True)
@cython.nonecheck(True)
def dict_merger(*args):
    newdict = nested_dict()
    for it in args:
        for p in fla_tu(it):
            tcr = type(reduce(operator_getitem, p[1][:-1], it))
            if tcr is tuple or tcr is set:
                tcr = list
            if tcr == list:
                try:
                    if not reduce(operator_getitem, p[1][:-2], newdict)[p[1][-2]]:
                        reduce(operator_getitem, p[1][:-2], newdict)[p[1][-2]] = tcr()
                    reduce(operator_getitem, p[1][:-2], newdict)[p[1][-2]].append(p[0])
                except Exception:
                    try:
                        reduce(operator_getitem, p[1][:-1], newdict)[p[1][-1]] = p[0]
                    except Exception:
                        reduce(operator_getitem, p[1][:-2], newdict)[p[1][-2]] = [
                            reduce(operator_getitem, p[1][:-1], newdict)[p[1][-1]],
                            p[0],
                        ]
            else:
                try:
                    if not reduce(operator_getitem, p[1][:-1], newdict)[p[1][-1]]:
                        reduce(operator_getitem, p[1][:-1], newdict)[p[1][-1]] = p[0]
                    else:
                        reduce(operator_getitem, p[1][:-1], newdict)[p[1][-1]] = [
                            reduce(operator_getitem, p[1][:-1], newdict)[p[1][-1]]
                        ]
                        reduce(operator_getitem, p[1][:-1], newdict)[p[1][-1]].append(
                            p[0]
                        )
                except Exception:
                    reduce(operator_getitem, p[1][:-2], newdict)[p[1][-2]] = [
                        reduce(operator_getitem, p[1][:-1], newdict)[p[1][-1]],
                        p[0],
                    ]
    return convert_to_normal_dict(newdict)



@cython.nonecheck(True)
def aa_flatten_dict_tu(
    v: dict,
    listitem: tuple,
) -> Generator:
    if (
        isinstance(v, dict)
        or (hasattr(v, "items") and hasattr(v, "keys"))
        and not isinstance(v, allowed)
    ):
        for k, v2 in v.items():
            newtu = listitem + (k,)
            if isinstance(v2, allowed):
                yield Tuppsub((v2, newtu))
            else:
                yield from aa_flatten_dict_tu(
                    v2, listitem=newtu
                )
    elif isinstance(v, forbidden) and not isinstance(v, allowed):
        for indi, v2 in enumerate(v):
            if isinstance(v2, allowed):
                yield Tuppsub((v2, (listitem + (indi,))))
            else:
                yield from aa_flatten_dict_tu(
                    v2,
                    listitem=(listitem + (indi,)),
                )
    elif isinstance(v, allowed):
        yield Tuppsub((v, listitem))
    else:
        try:
            for indi2, v2 in enumerate(v):
                try:
                    if isinstance(v2, allowed):
                        yield Tuppsub((v2, (listitem + (indi2,))))

                    else:
                        yield aa_flatten_dict_tu(
                            v2,
                            listitem=(listitem + (indi2,)),
                        )
                except Exception:
                    yield Tuppsub((v2, listitem))
        except Exception:
            yield Tuppsub((v, listitem))


def fla_tu(
    item: Any,
    walkthrough: tuple = (),


) -> Generator:
    if isinstance(item, allowed):
        yield Tuppsub((item, (walkthrough,)))
    elif isinstance(item, forbidden) and not isinstance(item, allowed):
        for ini, xaa in enumerate(item):
            if not isinstance(xaa, allowed):
                try:
                    yield from fla_tu(
                        xaa,
                        walkthrough=(walkthrough + (ini,)),
                    )

                except Exception:
                    yield Tuppsub((xaa, (walkthrough + (ini,))))
            else:
                yield Tuppsub((xaa, (walkthrough + (ini,))))
    elif isinstance(item, dict):
        if not isinstance(item, allowed):
            yield from aa_flatten_dict_tu(
                item, listitem=walkthrough,
            )
        else:
            yield Tuppsub((item, (walkthrough,)))
    elif (
        hasattr(item, "items") and hasattr(item, "keys")
    ) or (str(type(item)) in dict_variation):
        if not isinstance(item, allowed):
            yield from aa_flatten_dict_tu(
                dict(item), listitem=walkthrough,
            )
        else:
            yield Tuppsub((item, (walkthrough,)))
    else:
        try:
            for ini2, xaa in enumerate(item):
                try:
                    if isinstance(xaa, allowed):
                        yield Tuppsub((xaa, (walkthrough + (ini2,))))
                    else:
                        yield from fla_tu(
                            xaa,
                            walkthrough=(walkthrough + (ini2,)),
                        )
                except Exception:
                    yield Tuppsub((xaa, (walkthrough + (ini2,))))
        except Exception:
            yield Tuppsub((item, (walkthrough,)))

def convert_to_normal_dict_simple(di):
    if isinstance(di, MultiKeyDict):
        di = {k: convert_to_normal_dict_simple(v) for k, v in di.items()}
    return di

class MultiKeyDict(dict):
    def __init__(self, seq=None, **kwargs):
        if seq:
            super().__init__(seq, **kwargs)

        def convert_dict(di):
            if (isinstance(di, dict) and not isinstance(di, self.__class__)) or (
                hasattr(di, "items") and hasattr(di, "keys") and hasattr(di, "keys")
            ):
                ndi = self.__class__(
                    {},
                )
                for k, v in di.items():
                    ndi[k] = convert_dict(v)
                return ndi
            return di

        for key in self:
            self[key] = convert_dict(self[key])

    def __str__(self):
        return str(self.to_dict())

    def __missing__(self, key):
        self[key] = self.__class__({})
        return self[key]

    def __repr__(self):
        return self.__str__()

    def __delitem__(self, i):
        if isinstance(i, list):
            if len(i) > 1:
                lastkey = i[len(i)-1]
                i = i[:len(i)-1]
                it = iter(i)
                firstkey = next(it)
                value = self[firstkey]
                for element in it:
                    value = operator_itemgetter(element)(value)
                del value[lastkey]
            else:
                super().__delitem__(i[0])
        else:
            super().__delitem__(i)

    def __getitem__(self, key, /):
        if isinstance(key, list):
            if len(key) > 1:
                it = iter(key)
                firstkey = next(it)
                value = self[firstkey]
                for element in it:
                    value = operator_itemgetter(element)(value)
                return value
            else:
                return super().__getitem__(key[0])
        else:
            return super().__getitem__(key)

    def __setitem__(self, i, item):
        if isinstance(i, list):
            if len(i) > 1:
                lastkey = i[len(i)-1]
                i = i[:len(i)-1]
                it = iter(i)
                firstkey = next(it)
                value = self[firstkey]
                for element in it:
                    value = operator_itemgetter(element)(value)
                value[lastkey] = item
            else:
                return super().__setitem__(i[0], item)
        else:
            return super().__setitem__(i, item)

    def to_dict(self):
        return convert_to_normal_dict_simple(self)

    def update(self, other, /, **kwds):
        other = self.__class__(other)
        super().update(other, **kwds)

    def get(self, key, default=None):
        v = default
        if not isinstance(key, list):
            return super().get(key, default)
        else:
            if len(key) > 1:
                it = iter(key)
                firstkey = next(it)
                value = self[firstkey]
                for element in it:
                    if element in value:
                        value = operator_itemgetter(element)(value)
                    else:
                        return default
            else:
                return super().get(key[0], default)
            return value

    def pop(self, key, default=None):
        if not isinstance(key, list):
            return super().pop(key, default)

        elif len(key) == 1:
            return super().pop(key[0], default)
        else:
            return self._del_and_return(key, default)

    def _del_and_return(self, key, default=None):
        newkey = key[:len(key)-1]
        delkey = key[len(key)-1]
        it = iter(newkey)
        firstkey = next(it)
        value = self[firstkey]
        for element in it:
            if element in value:
                value = operator_itemgetter(element)(value)
            else:
                return default

        value1 = value[delkey]
        del value[delkey]
        return value1

    def reversed(self):
        return reversed(list(iter(self.keys())))


class MultiKeyIterDict(MultiKeyDict):
    def __init__(self, /, initialdata=None, **kwargs):
        super().__init__(initialdata, **kwargs)

    def nested_items(self):
        for v, k in fla_tu(self.to_dict()):
            yield list(k), v

    def nested_values(self):
        for v, _ in fla_tu(self.to_dict()):
            yield v

    def nested_keys(self):
        for _, k in fla_tu(self.to_dict()):
            yield list(k)

    def _check_last_item(self):
        cdef:
            list alreadydone = []
            list results = []
        for v, k in fla_tu(self.to_dict()):
            if len(k) > 1 and k not in alreadydone:
                qr = list(k)
                qr=qr[:len(qr)-1]
                if isinstance(v2 := self[qr], (dict, defaultdict)):
                    results.append((list(k), v))
                elif isiter(v2):
                    alreadydone.append(qr)
                    results.append((qr, v2))
                else:
                    results.append((list(k), v))
            else:
                results.append((list(k), v))
        return results

    def nested_value_search(self, value):
        for k, v in self._check_last_item():
            if v == value:
                yield k

    def nested_key_search(self, key):
        return (
            (q := list(takewhile(lambda xx: xx != key, list(x))) + [key], self[q])
            for x in list(self.nested_keys())
            if key in x
        )

    def nested_update(self, *args):
        self.update(dict_merger(self.to_dict(), *args))

    def nested_merge(self, *args):
        return convert_to_normal_dict_simple(dict_merger(self.to_dict(), *args))


def nested_list_to_nested_dict(l):
    di = MultiKeyIterDict()
    for v, k in fla_tu(l):
        di[list(k)] = v
    return di.to_dict()

@cython.boundscheck(True)
@cython.wraparound(True)
@cython.nonecheck(True)
def indent2dict(data, removespaces):
    @lru_cache
    def strstrip(x):
        return x.strip()

    def convert_to_normal_dict_simple(di):
        globcounter = 0

        def _convert_to_normal_dict_simple(di):
            nonlocal globcounter
            globcounter = globcounter + 1
            if not di:
                return globcounter
            if isinstance(di, subi):
                di = {k: _convert_to_normal_dict_simple(v) for k, v in di.items()}
            return di

        return _convert_to_normal_dict_simple(di)

    def splitfunc(alli, dh):
        def splifu(lix, ind):
            try:
                firstsplit = [n for n, y in enumerate(lix) if y[0] == ind]
            except Exception:
                return lix
            result1 = list_split(l=lix, indices_or_sections=firstsplit)
            newi = ind + 1
            splitted = []
            for l in result1:
                if newi < (lendh):
                    if isinstance(l, list):
                        if l:
                            la = splifu(l, newi)
                            splitted.append(la)
                    else:
                        splitted.append(l)
                else:
                    splitted.append(l)
            return splitted

        lendh = len(dh.keys())
        alli2 = [alli[0]] + alli
        return splifu(alli2, ind=0)

    if isinstance(data, (str, bytes)):
        da2 = data.splitlines()
    else:
        da2 = list(data)

    d = defaultdict(list)
    dox = da2.copy()
    dox = [x for x in dox if x.strip()]
    for dx in dox:
        eg = len(dx) - len(dx.lstrip())
        d[eg].append(dx)

    dh = {k: v[1] for k, v in enumerate(sorted(d.items()))}

    alli = []
    for xas in dox:
        for kx, kv in dh.items():
            if xas in kv:
                alli.append([kx, xas])
                break

    iu = splitfunc(alli, dh)

    allra = []
    d = nested_list_to_nested_dict(l=iu)
    lookupdi = {}
    for iasd, ius in enumerate((q for q in fla_tu(d) if not isinstance(q[0], int))):
        if iasd == 0:
            continue
        it = list(takewhile(lambda o: o == 0, reversed(ius[1][:-2])))
        it = ius[1][: -2 - len(it)]
        allra.append([it, ius[0]])
        lookupdi[it] = ius[0]

    allmils = []
    for im, _ in allra:
        mili = []
        for x in reversed(range(1, len(im) + 1)):
            try:
                mili.append(lookupdi[im[:x]])
            except Exception:
                with contextlib_suppress(Exception):
                    mili.append(lookupdi[im[: x - 1]])
        mili = tuple(reversed(mili))
        allmils.append(mili)
    allmilssorted = sorted(allmils, key=len, reverse=True)
    countdict = defaultdict(int)
    difi = subi()
    allmilssorted = [
        tuple(map(strstrip, x) if removespaces else x) for x in allmilssorted
    ]
    for ixas in allmilssorted:
        for rad in range(len(ixas) + 1):
            countdict[ixas[:rad]] += 1
    for key, item in countdict.items():
        if not key:
            continue
        if item != 1:
            continue
        vaxu = difi[key[0]]
        for inxa, kax in enumerate(key):
            if inxa == 0:
                continue
            vaxu = vaxu[kax]

    return convert_to_normal_dict_simple(difi)

def tointstr(v):
    return str(int(v))


def _dumpsys_splitter_to_dict(so,convert_to_dict=True):
    resultdict = MultiKeyIterDict({})
    for ita in re.split(
        r"\n(?=[^\s])",
        (
            b"".join([k for k in so if k.strip()])
            .decode("utf-8", "backslashreplace")
            .strip()
        ),
    ):
        with contextlib_suppress(Exception):
            result = indent2dict(ita, removespaces=True)
            resultdict.nested_update(result)
    if convert_to_dict:
        return resultdict.to_dict()
    return resultdict



################################################# END Recursive Dictstuff #################################################################

################################################# START CommandGetter ####################################################################

cdef class CommandGetter:
    SH_FIND_FILES_WITH_CONTEXT = r'''{exe_path}find "{folder_path}" -maxdepth {max_depth} -printf "\"%M\",\"%Z\",\"%s\",\"%u\",\"%g\",\"%l\",\"%T@\",\"%U\",\"%G\",\"%m\",\"%p\",\"%f\"\n";find "{folder_path}" -maxdepth {max_depth} -iname ".*" -printf "\"%M\",\"%Z\",\"%s\",\"%u\",\"%g\",\"%l\",\"%T@\",\"%U\",\"%G\",\"%m\",\"%p\",\"%f\"\n"'''
    SH_FIND_PROP_FILES = '{exe_path}find / -type f -name "*.prop" 2>/dev/null'
    SH_FIND_FILES_WITH_ENDING = '{exe_path}find "{folder_path}" -type f -maxdepth {max_depth} -iname "*.{ending}" 2>/dev/null'
    SH_SAVE_SED_REPLACE = r"""
subssed() {{
    {exe_path}sed -i "s/$({exe_path}printf "%s" "$1" | {exe_path}sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$({exe_path}printf "%s" "$2" | {exe_path}sed -e 's/[\/&]/\\&/g')/g" "$3"
}}

sourcef='{file_path}'
str1='{string2replace}'
str2='{replacement}'
perm=$({exe_path}stat -c '%a' "$sourcef")
owner=$({exe_path}stat -c '%U' "$sourcef")
group=$({exe_path}stat -c '%G' "$sourcef")
atime=$({exe_path}stat -c '%X' "$sourcef")
mtime=$({exe_path}stat -c '%Y' "$sourcef")
selinux_context="$({exe_path}ls -Z "$sourcef" | {exe_path}awk '{{print $1}}')"
subssed "$sourcef" "$str1" "$str2"
{exe_path}chown "$owner" "$sourcef"
{exe_path}chgrp "$group" "$sourcef"
{exe_path}chmod "$perm" "$sourcef"
{exe_path}touch -m -d "@$mtime" "$sourcef"
{exe_path}touch -a -d "@$atime" "$sourcef"
{exe_path}chcon "$selinux_context" "$sourcef"
"""
    SH_SVC_ENABLE_WIFI = "{exe_path}svc wifi enable"
    SH_SVC_DISABLE_WIFI = "{exe_path}svc wifi disable"
    SH_TRIM_CACHES = "{exe_path}pm trim-caches 99999G"
    SH_FORCE_OPEN_APP = r"""
while true; do
  capture="$({exe_path}dumpsys window | {exe_path}grep -E 'mCurrentFocus|mFocusedApp' | {exe_path}grep -c "{package_name}")"
  if {exe_path}[ $capture -eq 0 ]; then
    {exe_path}am start "$({exe_path}cmd package resolve-activity --brief {package_name} | {exe_path}tail -n 1)"
  else
    break
  fi
  {exe_path}sleep {sleep_time}
  capture="$({exe_path}dumpsys window | {exe_path}grep -E 'mCurrentFocus|mFocusedApp' | {exe_path}grep -c "{package_name}")"
  if {exe_path}[ $capture -eq 0 ]; then
    {exe_path}monkey -p {package_name} 1 >/dev/null
  else
    break
  fi
  {exe_path}sleep {sleep_time}
done
"""
    SH_GET_MAIN_ACTIVITY = (
        r"""{exe_path}cmd package resolve-activity --brief {package_name}"""
    )
    SH_SVC_POWER_SHUT_DOWN = "{exe_path}svc power shutdown"
    SH_SVC_POWER_REBOOT = "{exe_path}svc power reboot"
    SH_DUMPSYS_DROPBOX = "{exe_path}dumpsys dropbox --print"
    SH_SET_NEW_LAUNCHER = """{exe_path}pm set-home-activity {package_name}"""
    SH_GET_PID_OF_SHELL = "echo $$"
    SH_TAR_FOLDER = "{exe_path}tar czf '{dst}' '{src}'"
    SH_EXTRACT_FILES = r"""UZ() {
  f_name="$(basename "$1" | awk -F. 'BEGIN{OFS="_"} {if ($(NF-1) == "tar") {ext = $(NF-1) "." $NF; NF-=2} else {ext = $NF; NF--}; print $0}')"
  f_ext="$(echo "$1" | awk -F. '{if ($(NF-1) == "tar") {print $(NF-1) "." $NF} else {print $NF}}')"
  case "$f_ext" in
    "zip")
      echo "unzipping zip to $f_name"
      mkdir "$f_name"
      unzip "$1" -d "$f_name"
      ;;
    "tar.gz" | "tgz")
      echo "unzipping tar.gz to $f_name"
      mkdir "$f_name"
      tar -zxvf "$1" -C "$f_name"
      ;;
    "tar")
      echo "unzipping tar to $f_name"
      mkdir "$f_name"
      tar -xvf "$1" -C "$f_name"
      ;;
    "gz")
      echo "unzipping gz to $f_name"
      mkdir "$f_name"
      gunzip -c "$1" > "$f_name"
      ;;
    "7z")
      echo "unzipping 7z to $f_name"
      mkdir "$f_name"
      7z x "$1" -o"$f_name"
      ;;
    *)
      echo "unknown file type: $f_ext"
      ;;
  esac
}

UZ COMPRESSED_ARCHIVE FOLDER_TO_EXTRACT
"""
    SH_GET_USER_ROTATION = "{exe_path}settings get system user_rotation"
    SH_COPY_DIR_RECURSIVE = "{exe_path}cp -R {src} {dst}"
    SH_BACKUP_FILE = "{exe_path}cp -R {src} {src}.bak"
    SH_REMOVE_FOLDER = "{exe_path}rm -r -f {folder}"
    SH_WHOAMI = "{exe_path}whoami"
    SH_DUMPSYS_PACKAGE = "{exe_path}dumpsys package {package}"
    SH_GRANT_PERMISSION = "{exe_path}pm grant {package} {permission}"
    SH_REVOKE_PERMISSION = "{exe_path}pm revoke {package} {permission}"
    SH_GET_AVAIABLE_KEYBOARDS = "{exe_path}ime list -s -a"
    SH_GET_ACTIVE_KEYBOARD = "{exe_path}settings get secure default_input_method"
    SH_GET_ALL_KEYBOARDS_INFORMATION = "{exe_path}ime list -a"
    SH_ENABLE_KEYBOARD = "{exe_path}ime enable {keyboard}"
    SH_DISABLE_KEYBOARD = "{exe_path}ime disable {keyboard}"
    SH_SET_KEYBOARD = "{exe_path}ime set {keyboard}"
    SH_IS_KEYBOARD_SHOWN = (
        '{exe_path}dumpsys input_method | {exe_path}grep -E "mInputShown|mVisibleBound"'
    )
    SH_SHOW_TOUCHES = "{exe_path}settings put system show_touches 1"
    SH_SHOW_TOUCHES_NOT = "{exe_path}settings put system show_touches 0"
    SH_SHOW_POINTER_LOCATION = "{exe_path}settings put system pointer_location 1"
    SH_SHOW_POINTER_LOCATION_NOT = "{exe_path}settings put system pointer_location 0"
    SH_INPUT_SWIPE = "{exe_path}input swipe {x1} {y1} {x2} {y2} {duration}"
    SH_INPUT_TAP = "{exe_path}input tap {x} {y}"
    SH_CLEAR_FILE_CONTENT = """{exe_path}printf "%s" '' > {file_path}"""
    SH_MAKEDIRS = "{exe_path}mkdir -p {folder}"
    SH_TOUCH = "{exe_path}touch {file_path}"
    SH_MV = "{exe_path}mv {src} {dst}"
    SH_OPEN_ACCESSIBILITY_SETTINGS = (
        "{exe_path}am start -a android.settings.ACCESSIBILITY_SETTINGS"
    )
    SH_OPEN_ADVANCED_MEMORY_PROTECTION_SETTINGS = (
        "{exe_path}am start -a android.settings.ADVANCED_MEMORY_PROTECTION_SETTINGS"
    )
    SH_OPEN_AIRPLANE_MODE_SETTINGS = (
        "{exe_path}am start -a android.settings.AIRPLANE_MODE_SETTINGS"
    )
    SH_OPEN_ALL_APPS_NOTIFICATION_SETTINGS = (
        "{exe_path}am start -a android.settings.ALL_APPS_NOTIFICATION_SETTINGS"
    )
    SH_OPEN_APN_SETTINGS = "{exe_path}am start -a android.settings.APN_SETTINGS"
    SH_OPEN_APPLICATION_DETAILS_SETTINGS = (
        "{exe_path}am start -a android.settings.APPLICATION_DETAILS_SETTINGS"
    )
    SH_OPEN_APPLICATION_DEVELOPMENT_SETTINGS = (
        "{exe_path}am start -a android.settings.APPLICATION_DEVELOPMENT_SETTINGS"
    )
    SH_OPEN_APPLICATION_SETTINGS = (
        "{exe_path}am start -a android.settings.APPLICATION_SETTINGS"
    )
    SH_OPEN_APP_LOCALE_SETTINGS = (
        "{exe_path}am start -a android.settings.APP_LOCALE_SETTINGS"
    )
    SH_OPEN_APP_NOTIFICATION_BUBBLE_SETTINGS = (
        "{exe_path}am start -a android.settings.APP_NOTIFICATION_BUBBLE_SETTINGS"
    )
    SH_OPEN_APP_NOTIFICATION_SETTINGS = (
        "{exe_path}am start -a android.settings.APP_NOTIFICATION_SETTINGS"
    )
    SH_OPEN_APP_OPEN_BY_DEFAULT_SETTINGS = (
        "{exe_path}am start -a android.settings.APP_OPEN_BY_DEFAULT_SETTINGS"
    )
    SH_OPEN_APP_SEARCH_SETTINGS = (
        "{exe_path}am start -a android.settings.APP_SEARCH_SETTINGS"
    )
    SH_OPEN_APP_USAGE_SETTINGS = (
        "{exe_path}am start -a android.settings.APP_USAGE_SETTINGS"
    )
    SH_OPEN_AUTOMATIC_ZEN_RULE_SETTINGS = (
        "{exe_path}am start -a android.settings.AUTOMATIC_ZEN_RULE_SETTINGS"
    )
    SH_OPEN_AUTO_ROTATE_SETTINGS = (
        "{exe_path}am start -a android.settings.AUTO_ROTATE_SETTINGS"
    )
    SH_OPEN_BATTERY_SAVER_SETTINGS = (
        "{exe_path}am start -a android.settings.BATTERY_SAVER_SETTINGS"
    )
    SH_OPEN_BLUETOOTH_SETTINGS = (
        "{exe_path}am start -a android.settings.BLUETOOTH_SETTINGS"
    )
    SH_OPEN_CAPTIONING_SETTINGS = (
        "{exe_path}am start -a android.settings.CAPTIONING_SETTINGS"
    )
    SH_OPEN_CAST_SETTINGS = "{exe_path}am start -a android.settings.CAST_SETTINGS"
    SH_OPEN_CHANNEL_NOTIFICATION_SETTINGS = (
        "{exe_path}am start -a android.settings.CHANNEL_NOTIFICATION_SETTINGS"
    )
    SH_OPEN_CONDITION_PROVIDER_SETTINGS = (
        "{exe_path}am start -a android.settings.CONDITION_PROVIDER_SETTINGS"
    )
    SH_OPEN_DATA_ROAMING_SETTINGS = (
        "{exe_path}am start -a android.settings.DATA_ROAMING_SETTINGS"
    )
    SH_OPEN_DATA_USAGE_SETTINGS = (
        "{exe_path}am start -a android.settings.DATA_USAGE_SETTINGS"
    )
    SH_OPEN_DATE_SETTINGS = "{exe_path}am start -a android.settings.DATE_SETTINGS"
    SH_OPEN_DEVICE_INFO_SETTINGS = (
        "{exe_path}am start -a android.settings.DEVICE_INFO_SETTINGS"
    )
    SH_OPEN_DISPLAY_SETTINGS = "{exe_path}am start -a android.settings.DISPLAY_SETTINGS"
    SH_OPEN_DREAM_SETTINGS = "{exe_path}am start -a android.settings.DREAM_SETTINGS"
    SH_OPEN_HARD_KEYBOARD_SETTINGS = (
        "{exe_path}am start -a android.settings.HARD_KEYBOARD_SETTINGS"
    )
    SH_OPEN_HOME_SETTINGS = "{exe_path}am start -a android.settings.HOME_SETTINGS"
    SH_OPEN_IGNORE_BACKGROUND_DATA_RESTRICTIONS_SETTINGS = "{exe_path}am start -a android.settings.IGNORE_BACKGROUND_DATA_RESTRICTIONS_SETTINGS"
    SH_OPEN_IGNORE_BATTERY_OPTIMIZATION_SETTINGS = (
        "{exe_path}am start -a android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS"
    )
    SH_OPEN_INPUT_METHOD_SETTINGS = (
        "{exe_path}am start -a android.settings.INPUT_METHOD_SETTINGS"
    )
    SH_OPEN_INPUT_METHOD_SUBTYPE_SETTINGS = (
        "{exe_path}am start -a android.settings.INPUT_METHOD_SUBTYPE_SETTINGS"
    )
    SH_OPEN_INTERNAL_STORAGE_SETTINGS = (
        "{exe_path}am start -a android.settings.INTERNAL_STORAGE_SETTINGS"
    )
    SH_OPEN_LOCALE_SETTINGS = "{exe_path}am start -a android.settings.LOCALE_SETTINGS"
    SH_OPEN_LOCATION_SOURCE_SETTINGS = (
        "{exe_path}am start -a android.settings.LOCATION_SOURCE_SETTINGS"
    )
    SH_OPEN_MANAGE_ALL_APPLICATIONS_SETTINGS = (
        "{exe_path}am start -a android.settings.MANAGE_ALL_APPLICATIONS_SETTINGS"
    )
    SH_OPEN_MANAGE_ALL_SIM_PROFILES_SETTINGS = (
        "{exe_path}am start -a android.settings.MANAGE_ALL_SIM_PROFILES_SETTINGS"
    )
    SH_OPEN_MANAGE_APPLICATIONS_SETTINGS = (
        "{exe_path}am start -a android.settings.MANAGE_APPLICATIONS_SETTINGS"
    )
    SH_OPEN_MANAGE_DEFAULT_APPS_SETTINGS = (
        "{exe_path}am start -a android.settings.MANAGE_DEFAULT_APPS_SETTINGS"
    )
    SH_OPEN_MANAGE_SUPERVISOR_RESTRICTED_SETTING = (
        "{exe_path}am start -a android.settings.MANAGE_SUPERVISOR_RESTRICTED_SETTING"
    )
    SH_OPEN_MANAGE_WRITE_SETTINGS = (
        "{exe_path}am start -a android.settings.MANAGE_WRITE_SETTINGS"
    )
    SH_OPEN_MEMORY_CARD_SETTINGS = (
        "{exe_path}am start -a android.settings.MEMORY_CARD_SETTINGS"
    )
    SH_OPEN_NETWORK_OPERATOR_SETTINGS = (
        "{exe_path}am start -a android.settings.NETWORK_OPERATOR_SETTINGS"
    )
    SH_OPEN_NFCSHARING_SETTINGS = (
        "{exe_path}am start -a android.settings.NFCSHARING_SETTINGS"
    )
    SH_OPEN_NFC_PAYMENT_SETTINGS = (
        "{exe_path}am start -a android.settings.NFC_PAYMENT_SETTINGS"
    )
    SH_OPEN_NFC_SETTINGS = "{exe_path}am start -a android.settings.NFC_SETTINGS"
    SH_OPEN_NIGHT_DISPLAY_SETTINGS = (
        "{exe_path}am start -a android.settings.NIGHT_DISPLAY_SETTINGS"
    )
    SH_OPEN_NOTIFICATION_ASSISTANT_SETTINGS = (
        "{exe_path}am start -a android.settings.NOTIFICATION_ASSISTANT_SETTINGS"
    )
    SH_OPEN_NOTIFICATION_LISTENER_DETAIL_SETTINGS = (
        "{exe_path}am start -a android.settings.NOTIFICATION_LISTENER_DETAIL_SETTINGS"
    )
    SH_OPEN_NOTIFICATION_LISTENER_SETTINGS = (
        "{exe_path}am start -a android.settings.NOTIFICATION_LISTENER_SETTINGS"
    )
    SH_OPEN_NOTIFICATION_POLICY_ACCESS_SETTINGS = (
        "{exe_path}am start -a android.settings.NOTIFICATION_POLICY_ACCESS_SETTINGS"
    )
    SH_OPEN_PRINT_SETTINGS = "{exe_path}am start -a android.settings.PRINT_SETTINGS"
    SH_OPEN_PRIVACY_SETTINGS = "{exe_path}am start -a android.settings.PRIVACY_SETTINGS"
    SH_OPEN_QUICK_ACCESS_WALLET_SETTINGS = (
        "{exe_path}am start -a android.settings.QUICK_ACCESS_WALLET_SETTINGS"
    )
    SH_OPEN_QUICK_LAUNCH_SETTINGS = (
        "{exe_path}am start -a android.settings.QUICK_LAUNCH_SETTINGS"
    )
    SH_OPEN_REGIONAL_PREFERENCES_SETTINGS = (
        "{exe_path}am start -a android.settings.REGIONAL_PREFERENCES_SETTINGS"
    )
    SH_OPEN_SATELLITE_SETTING = (
        "{exe_path}am start -a android.settings.SATELLITE_SETTING"
    )
    SH_OPEN_SEARCH_SETTINGS = "{exe_path}am start -a android.settings.SEARCH_SETTINGS"
    SH_OPEN_SECURITY_SETTINGS = (
        "{exe_path}am start -a android.settings.SECURITY_SETTINGS"
    )
    SH_OPEN_SETTINGS = "{exe_path}am start -a android.settings.SETTINGS"
    SH_OPEN_SETTINGS = "{exe_path}am start -a android.settings.SETTINGS"
    SH_OPEN_SOUND_SETTINGS = "{exe_path}am start -a android.settings.SOUND_SETTINGS"
    SH_OPEN_STORAGE_VOLUME_ACCESS_SETTINGS = (
        "{exe_path}am start -a android.settings.STORAGE_VOLUME_ACCESS_SETTINGS"
    )
    SH_OPEN_SYNC_SETTINGS = "{exe_path}am start -a android.settings.SYNC_SETTINGS"
    SH_OPEN_USAGE_ACCESS_SETTINGS = (
        "{exe_path}am start -a android.settings.USAGE_ACCESS_SETTINGS"
    )
    SH_OPEN_USER_DICTIONARY_SETTINGS = (
        "{exe_path}am start -a android.settings.USER_DICTIONARY_SETTINGS"
    )
    SH_OPEN_VOICE_INPUT_SETTINGS = (
        "{exe_path}am start -a android.settings.VOICE_INPUT_SETTINGS"
    )
    SH_OPEN_VPN_SETTINGS = "{exe_path}am start -a android.settings.VPN_SETTINGS"
    SH_OPEN_VR_LISTENER_SETTINGS = (
        "{exe_path}am start -a android.settings.VR_LISTENER_SETTINGS"
    )
    SH_OPEN_WEBVIEW_SETTINGS = "{exe_path}am start -a android.settings.WEBVIEW_SETTINGS"
    SH_OPEN_WIFI_IP_SETTINGS = "{exe_path}am start -a android.settings.WIFI_IP_SETTINGS"
    SH_OPEN_WIFI_SETTINGS = "{exe_path}am start -a android.settings.WIFI_SETTINGS"
    SH_OPEN_WIRELESS_SETTINGS = (
        "{exe_path}am start -a android.settings.WIRELESS_SETTINGS"
    )
    SH_OPEN_ZEN_MODE_PRIORITY_SETTINGS = (
        "{exe_path}am start -a android.settings.ZEN_MODE_PRIORITY_SETTINGS"
    )
    SH_OPEN_DEVELOPER_SETTINGS = (
        "{exe_path}am start -a android.settings.DEVELOPER_SETTINGS"
    )
    SH_RESCAN_MEDIA_FOLDER = """folder='{folder}'
string="$({exe_path}find "$folder" -type f 2> /dev/null)"
stringlines="$({exe_path}printf "%s\n" "$string" | {exe_path}wc -l)"
for i in $({exe_path}seq 1 $stringlines); do
  line="$({exe_path}printf "%s\n" "$string" | {exe_path}sed -n "$i"p)"
  {exe_path}am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d "file://${{line}}"
done"""
    SH_RESCAN_MEDIA_FILE = '{exe_path}am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d "file://{file_path}"'
    SH_SCREENCAP_PNG = "{exe_path}screencap -p {file_path}"
    SH_DUMP_PROCESS_MEMORY_TO_SDCARD = R"""getmemdump() {
	mkdir -p /sdcard/$1
    cat /proc/$1/maps | grep -v -E "rw-p.*deleted\)" | grep -E "rw-p.*" | awk '{print $1}' | (
        IFS="-"
        while read a b; do
            adec=$(printf "%d\n" 0x"$a")
            bdec=$(printf "%d\n" 0x"$b")
            si=$((bdec - adec))
            fina="/sdcard/$1/mem_$a.bin"
            echo "$fina $adec $bdec $si"
            dd if=/proc/$1/mem ibs=1 obs="$si" skip="$adec" count="$si" of="$fina"
        done
    )
}
oldIFS=$IFS
getmemdump PID2OBSERVE
IFS=$oldIFS"""
    SH_PM_CLEAR = "{exe_path}pm clear {package}"
    SH_CHANGE_WM_SIZE = "{exe_path}wm size {width}x{height}"
    SH_WM_RESET_SIZE = "{exe_path}wm size reset"
    SH_GET_WM_DENSITY = "{exe_path}wm density"
    SH_CHANGE_WM_DENSITY = "{exe_path}wm density {density}"
    SH_WM_RESET_DENSITY = "{exe_path}wm density reset"
    SH_AM_SCREEN_COMPAT_ON = "{exe_path}am screen-compat on {package}"
    SH_AM_SCREEN_COMPAT_OFF = "{exe_path}am screen-compat off {package}"
    SH_ENABLE_NOTIFICATIONS = (
        "{exe_path}settings put global heads_up_notifications_enabled 1"
    )
    SH_DISABLE_NOTIFICATIONS = (
        "{exe_path}settings put global heads_up_notifications_enabled 0"
    )
    SH_STILL_IMAGE_CAMERA = (
        "{exe_path}am start -a android.media.action.STILL_IMAGE_CAMERA"
    )
    SH_DISABLE_NETWORK_INTERFACE = "{exe_path}ifconfig {nic} down &"
    SH_ENABLE_NETWORK_INTERFACE = "{exe_path}ifconfig {nic} up &"
    SH_GET_LINUX_VERSION = "{exe_path}uname -a"
    SH_START_PACKAGE_WITH_MONKEY = "{exe_path}monkey -p {package} 1"
    SH_EXPAND_NOTIFICATIONS = "%scmd statusbar expand-notifications"
    SH_EXPAND_SETTINGS = "%scmd statusbar expand-settings"
    SH_LIST_PERMISSION_GROUPS = "%spm list permission-groups"
    SH_INPUT_DPAD_TAP = "%sinput dpad tap %s %s"
    SH_INPUT_KEYBOARD_TAP = "%sinput keyboard tap %s %s"
    SH_INPUT_MOUSE_TAP = "%sinput mouse tap %s %s"
    SH_INPUT_TOUCHPAD_TAP = "%sinput touchpad tap %s %s"
    SH_INPUT_GAMEPAD_TAP = "%sinput gamepad tap %s %s"
    SH_INPUT_TOUCHNAVIGATION_TAP = "%sinput touchnavigation tap %s %s"
    SH_INPUT_JOYSTICK_TAP = "%sinput joystick tap %s %s"
    SH_INPUT_TOUCHSCREEN_TAP = "%sinput touchscreen tap %s %s"
    SH_INPUT_STYLUS_TAP = "%sinput stylus tap %s %s"
    SH_INPUT_TRACKBALL_TAP = "%sinput trackball tap %s %s"
    SH_INPUT_DPAD_SWIPE = "%sinput dpad swipe %s %s %s %s %s"
    SH_INPUT_DPAD_DRAGANDDROP = "%sinput dpad draganddrop %s %s %s %s %s"
    SH_INPUT_DPAD_ROLL = "%sinput dpad roll %s %s"
    SH_INPUT_KEYBOARD_SWIPE = "%sinput keyboard swipe %s %s %s %s %s"
    SH_INPUT_KEYBOARD_DRAGANDDROP = "%sinput keyboard draganddrop %s %s %s %s %s"
    SH_INPUT_KEYBOARD_ROLL = "%sinput keyboard roll %s %s"
    SH_INPUT_MOUSE_SWIPE = "%sinput mouse swipe %s %s %s %s %s"
    SH_INPUT_MOUSE_DRAGANDDROP = "%sinput mouse draganddrop %s %s %s %s %s"
    SH_INPUT_MOUSE_ROLL = "%sinput mouse roll %s %s"
    SH_INPUT_TOUCHPAD_SWIPE = "%sinput touchpad swipe %s %s %s %s %s"
    SH_INPUT_TOUCHPAD_DRAGANDDROP = "%sinput touchpad draganddrop %s %s %s %s %s"
    SH_INPUT_TOUCHPAD_ROLL = "%sinput touchpad roll %s %s"
    SH_INPUT_GAMEPAD_SWIPE = "%sinput gamepad swipe %s %s %s %s %s"
    SH_INPUT_GAMEPAD_DRAGANDDROP = "%sinput gamepad draganddrop %s %s %s %s %s"
    SH_INPUT_GAMEPAD_ROLL = "%sinput gamepad roll %s %s"
    SH_INPUT_TOUCHNAVIGATION_SWIPE = "%sinput touchnavigation swipe %s %s %s %s %s"
    SH_INPUT_TOUCHNAVIGATION_DRAGANDDROP = (
        "%sinput touchnavigation draganddrop %s %s %s %s %s"
    )
    SH_INPUT_TOUCHNAVIGATION_ROLL = "%sinput touchnavigation roll %s %s"
    SH_INPUT_JOYSTICK_SWIPE = "%sinput joystick swipe %s %s %s %s %s"
    SH_INPUT_JOYSTICK_DRAGANDDROP = "%sinput joystick draganddrop %s %s %s %s %s"
    SH_INPUT_JOYSTICK_ROLL = "%sinput joystick roll %s %s"
    SH_INPUT_TOUCHSCREEN_SWIPE = "%sinput touchscreen swipe %s %s %s %s %s"
    SH_INPUT_TOUCHSCREEN_DRAGANDDROP = "%sinput touchscreen draganddrop %s %s %s %s %s"
    SH_INPUT_TOUCHSCREEN_ROLL = "%sinput touchscreen roll %s %s"
    SH_INPUT_STYLUS_SWIPE = "%sinput stylus swipe %s %s %s %s %s"
    SH_INPUT_STYLUS_DRAGANDDROP = "%sinput stylus draganddrop %s %s %s %s %s"
    SH_INPUT_STYLUS_ROLL = "%sinput stylus roll %s %s"
    SH_INPUT_TRACKBALL_SWIPE = "%sinput trackball swipe %s %s %s %s %s"
    SH_INPUT_TRACKBALL_DRAGANDDROP = "%sinput trackball draganddrop %s %s %s %s %s"
    SH_INPUT_TRACKBALL_ROLL = "%sinput trackball roll %s %s"
    SH_OPEN_URL = "{exe_path}am start -a android.intent.action.VIEW -d {url}"

    SH_READ_WRITE_REMOUNT_V01 = """busybox mount -o remount,rw /"""
    SH_READ_WRITE_REMOUNT_V02 = """busybox mount --all -o remount,rw -t vfat1"""
    SH_READ_WRITE_REMOUNT_V03 = """busybox mount --all -o remount,rw -t ext4"""
    SH_READ_WRITE_REMOUNT_V04 = """busybox mount -o remount,rw"""
    SH_READ_WRITE_REMOUNT_V05 = """busybox mount -o remount,rw /;"""
    SH_READ_WRITE_REMOUNT_V06 = """busybox mount -o rw&&remount /"""
    SH_READ_WRITE_REMOUNT_V07 = """busybox mount -o rw;remount /"""
    SH_READ_WRITE_REMOUNT_V08 = """busybox mount --all -o remount,rw -t vfat"""
    SH_READ_WRITE_REMOUNT_V09 = """busybox mount --all -o remount,rw -t ext4"""
    SH_READ_WRITE_REMOUNT_V10 = """busybox mount --all -o remount,rw -t vfat1"""
    SH_READ_WRITE_REMOUNT_V11 = """mount -o remount,rw /"""
    SH_READ_WRITE_REMOUNT_V12 = """mount --all -o remount,rw -t vfat1"""
    SH_READ_WRITE_REMOUNT_V13 = """mount --all -o remount,rw -t ext4"""
    SH_READ_WRITE_REMOUNT_V14 = """mount -o remount,rw"""
    SH_READ_WRITE_REMOUNT_V15 = """mount -o remount,rw /;"""
    SH_READ_WRITE_REMOUNT_V16 = """mount -o rw&&remount /"""
    SH_READ_WRITE_REMOUNT_V17 = """mount -o rw;remount /"""
    SH_READ_WRITE_REMOUNT_V18 = """mount --all -o remount,rw -t vfat"""
    SH_READ_WRITE_REMOUNT_V19 = """mount --all -o remount,rw -t ext4"""
    SH_READ_WRITE_REMOUNT_V20 = """mount --all -o remount,rw -t vfat1"""
    SH_READ_WRITE_REMOUNT_V21 = """getprop --help >/dev/null;mount -o remount,rw /;"""
    SH_READ_WRITE_REMOUNT_V22 = r"""mount -v | grep "^/" | grep -v '\\(rw,' | grep '\\(ro' | awk '{print "mount -o rw,remount " $1 " " $3}' | tr '\n' '\0' | xargs -0 -n1 su -c"""
    SH_READ_WRITE_REMOUNT_V23 = r"""mount -v | grep "^/" | grep -v '\\(rw,' | grep '\\(ro' | awk '{print "mount -o rw,remount " $1 " " $3}' | su -c sh"""
    SH_READ_WRITE_REMOUNT_V24 = r"""mount -v | grep "^/" | grep -v '\\(rw,' | grep '\\(ro' | awk '{system("mount -o rw,remount " $1 " " $3)}' """
    SH_READ_WRITE_REMOUNT_V25 = r"""su -c 'mount -v | grep -E "^/" | awk '\''{print "mount -o rw,remount " $1 " " $3}'\''' | tr '\n' '\0' | xargs -0 -n1 su -c"""
    SH_READ_WRITE_REMOUNT_V26 = r"""mount -Ev | grep -Ev 'nodev' | grep -Ev '/proc' | grep -v '\\(rw,' | awk 'BEGIN{FS="([[:space:]]+(on|type)[[:space:]]+)|([[:space:]]+\\()"}{print "mount -o rw,remount " $1 " " $2}' | xargs -n5 | su -c"""
    SH_READ_WRITE_REMOUNT_V27 = r"""su -c 'mount -v | grep -E "^/" | awk '\''{print "mount -o rw,remount " $1 " " $3}'\''' | sh su -c"""
    SH_READ_WRITE_REMOUNT_V28 = r"""getprop --help >/dev/null;su -c 'mount -v | grep -E "^/" | awk '\''{print "mount -o rw,remount " $1 " " $3}'\''' | tr '\n' '\0' | xargs -0 -n1 | su -c sh"""
    SH_GET_BIOS_INFO = R"""{exe_path}dd if=/dev/mem bs=1k skip=768 count=256 2>/dev/null | {exe_path}strings -n 8"""
    SH_PRINTENV = "{exe_path}printenv"
    SH_FREEZE_PROC = "{exe_path}kill -19 {pid}"
    SH_UNFREEZE_PROC = "{exe_path}kill -18 {pid}"
    SH_SHOW_FRAGMENTS_ON_SCREEN_ENABLE = """{exe_path}setprop debug.layout true
    {exe_path}service call activity 1599295570"""
    SH_SHOW_FRAGMENTS_SCREEN_DISABLE = """{exe_path}setprop debug.layout false"""

################################################# END CommandGetter ####################################################################

cdef string convert_python_object_to_cpp_string(object shell_command):
    cdef:
        string cpp_shell_command
        bytes tmp_bytes
    if isinstance(shell_command,bytes):
        cpp_shell_command=<string>shell_command
    elif isinstance(shell_command,str):
        tmp_bytes=shell_command.encode()
        cpp_shell_command=<string>(tmp_bytes)
    else:
        tmp_bytes=str(shell_command).encode()
        cpp_shell_command=<string>(tmp_bytes)
    return cpp_shell_command


cdef class CySubProc:
    cdef ShellProcessManager*subproc

    def __init__(self,
                object shell_command,
                size_t buffer_size=4096,
                size_t stdout_max_len=4096,
                size_t stderr_max_len=4096,
                object exit_command=b"exit",
                bint print_stdout=False,
                bint print_stderr=False,
                ):
        cdef:
            string cpp_shell_command
            string cpp_exit_command
        cpp_shell_command=convert_python_object_to_cpp_string(shell_command)
        cpp_exit_command=convert_python_object_to_cpp_string(exit_command)

        self.subproc= new ShellProcessManager(
        shell_command=cpp_shell_command,
        buffer_size=buffer_size,
        stdout_max_len=stdout_max_len,
        stderr_max_len=stderr_max_len,
        exit_command=cpp_exit_command,
        print_stdout=print_stdout,
        print_stderr=print_stderr
    )
    cpdef start_shell(
        self,
    ):
        self.subproc.start_shell()
    cpdef stdin_write(self, object cmd):
        cdef:
            string cpp_cmd
        cpp_cmd=convert_python_object_to_cpp_string(cmd)
        self.subproc.stdin_write(cpp_cmd)

    cpdef bytes get_stdout(self):
        if not self.subproc.continue_reading_stdout:
            raise OSError("Pipes closed!")
        return self.subproc.get_stdout()

    cpdef bytes get_stderr(self):
        if not self.subproc.continue_reading_stderr:
            raise OSError("Pipes closed!")
        return self.subproc.get_stderr()

    cpdef stop_shell(self):
        self.subproc.stop_shell()

    cdef string read_stdout(self):
        if not self.subproc.continue_reading_stdout:
            raise OSError("Pipes closed!")
        return self.subproc.get_stdout()

    cdef string read_stderr(self):
        if not self.subproc.continue_reading_stderr:
            raise OSError("Pipes closed!")
        return self.subproc.get_stderr()

    def __dealloc__(self):
        del self.subproc


cdef class Shelly:
    cdef:
        string* finish_cmd_to_write
        string* finish_cmd_to_write_stderr
        string* bin_finish_cmd
        string* su_exe
        string* cpp_new_line
        string* cpp_empty_string
        CySubProc p
        CommandGetter _c
        str system_bin
        bytes system_bin_as_binary

    def __dealloc__(self):
        del self.finish_cmd_to_write
        del self.finish_cmd_to_write_stderr
        del self.su_exe
        del self.bin_finish_cmd
        del self.cpp_new_line
        del self.cpp_empty_string

    def __init__(self,
                object shell_command,
                size_t buffer_size=40960,
                size_t stdout_max_len=40960,
                size_t stderr_max_len=40960,
                object exit_command=b"exit",
                bint print_stdout=False,
                bint print_stderr=False,
                str su_exe="su",
                str finish_cmd="HERE_IS_FINISH",
                str system_bin="",
                ):
        cdef:
                bytes self_su_exe = su_exe.encode("utf-8")
                bytes self_finish_cmd_to_write = f"""printf "\n%s\n" '{finish_cmd}'""".encode()
                bytes self_finish_cmd_to_write_stderr = (
            f"""printf "\n%s\n" '{finish_cmd}' >&2""".encode()
        )
        self.finish_cmd_to_write=new string(<string>self_finish_cmd_to_write)
        self.finish_cmd_to_write_stderr=new string(<string>self_finish_cmd_to_write_stderr)
        self.su_exe=new string(<string>self_su_exe)
        self.bin_finish_cmd=new string(convert_python_object_to_cpp_string(finish_cmd))
        self.cpp_new_line= new string(b"\n")
        self.cpp_empty_string= new string(b"")
        self.system_bin=system_bin
        self.system_bin_as_binary = system_bin.encode("utf-8")
        self.p = CySubProc(
                shell_command=shell_command,
                buffer_size=buffer_size,
                stdout_max_len=stdout_max_len,
                stderr_max_len=stderr_max_len,
                exit_command=exit_command,
                print_stdout=print_stdout,
                print_stderr=print_stderr,
                )
        self._c = CommandGetter()
        self.p.start_shell()
        self.p.stdin_write("echo STARTED")
        self.p.stdin_write("echo STARTED >&2")

    cpdef pair[string,string] write_and_wait(self, object line, int64_t timeout=10, bint strip_results=True):
        cdef:
            string formatted_line = convert_python_object_to_cpp_string(line)
            pair[string,string] result =self._write_and_wait(formatted_line=formatted_line, timeout=timeout, strip_results=strip_results)

        return result

    cpdef pair[vector[string],vector[string]] write_and_wait_list(self, object line, int64_t timeout=10, bint strip_results=True):
        cdef:
            string formatted_line = convert_python_object_to_cpp_string(line)
            pair[string,string] result =self._write_and_wait(formatted_line=formatted_line, timeout=timeout, strip_results=strip_results)
            pair[vector[string],vector[string]] resultpair=pair[vector[string],vector[string]]([],[])
        if not result.first.empty():
            resultpair.first=split_string(result.first,self.cpp_new_line[0])
        if not result.second.empty():
            resultpair.second=split_string(result.second,self.cpp_new_line[0])
        return resultpair


    cdef pair[string,string] _write_and_wait(self, string formatted_line, int64_t timeout=10, bint strip_results=True) nogil:
        cdef:
            string outstring_stdout
            string outstring_stderr
            size_t string_search_position=npos
            string tmpstring
            int64_t start_time
            int64_t end_time
            pair[string,string] resultpair = pair[string,string](self.cpp_empty_string[0],self.cpp_empty_string[0])
        outstring_stderr.reserve(256)
        outstring_stdout.reserve(8192)
        self.p.subproc.clear_stdout()
        self.p.subproc.clear_stderr()
        formatted_line.append(self.cpp_new_line[0])
        formatted_line.append(self.finish_cmd_to_write[0])
        formatted_line.append(self.cpp_new_line[0])
        formatted_line.append(self.finish_cmd_to_write_stderr[0])
        formatted_line.append(self.cpp_new_line[0])
        self.p.subproc.stdin_write(formatted_line)
        sleep_milliseconds(3)
        start_time = get_current_timestamp()
        end_time = start_time + timeout
        while npos==string_search_position and get_current_timestamp() < end_time:
            tmpstring=self.p.subproc.get_stderr()
            if tmpstring.empty():
                sleep_milliseconds(1)
                continue
            outstring_stderr.append(tmpstring)
            string_search_position=outstring_stderr.find(self.bin_finish_cmd[0])
        start_time = get_current_timestamp()
        end_time = start_time + timeout
        if (npos!=string_search_position):
            outstring_stderr.erase(outstring_stderr.begin()+string_search_position,outstring_stderr.end())
        string_search_position=npos
        while npos==string_search_position and get_current_timestamp() < end_time:
            tmpstring=self.p.subproc.get_stdout()
            if tmpstring.empty():
                sleep_milliseconds(1)
                continue
            outstring_stdout.append(tmpstring)

            string_search_position=outstring_stdout.find(self.bin_finish_cmd[0])
        if (npos!=string_search_position):
            outstring_stdout.erase(outstring_stdout.begin()+string_search_position,outstring_stdout.end())
        resultpair.first=outstring_stdout
        resultpair.second=outstring_stderr
        if strip_results:
            if not resultpair.first.empty():
                strip_spaces_inplace(resultpair.first)
            if not resultpair.second.empty():
                strip_spaces_inplace(resultpair.second)
        return resultpair



    def get_df_files_with_context_printf(self, object folders, int64_t max_depth=1, int64_t timeout=10):
        cdef:
            list ac=[]
        folders=convert_to_list(folders)
        for folder in folders:
            ac.append(
                self._c.SH_FIND_FILES_WITH_CONTEXT.format(
                    exe_path=self.system_bin, folder_path=folder, max_depth=max_depth
                )
            )
        return pd.read_csv(
            io.StringIO(
                (self.write_and_wait("\n".join(ac), timeout=timeout).first)
                .decode("utf-8", "backslashreplace")
            ),
            encoding="utf-8",
            sep=",",
            index_col=False,
            encoding_errors="backslashreplace",
            on_bad_lines="warn",
            engine="python",
            na_filter=False,
            quoting=1,
            names=columns_files,
            dtype=dtypes_files,
        )
    def get_df_files_with_context_ls(
        self, object folders, int64_t max_depth=1, bint with_dates=True, int64_t timeout=10
    ):
        cdef:
            list ac=[]
            pair[vector[string],vector[string]] so_se_pair,so_se_pair2
            list[bytes] complete_command_list = []
            list[bytes] goodfiles = []
            bytes complete_command_list_bytes
            Py_ssize_t index,file_index
        folders=convert_to_list(folders)
        for folder in folders:
            ac.append(
                f'find {folder} -maxdepth {max_depth} -type f\nfind {folder} -maxdepth {max_depth} -type f -iname ".*"'
            )
        so_se_pair = self.write_and_wait_list("\n".join(ac).encode("utf-8"), timeout=timeout)
        for file_index in range(so_se_pair.first.size()):
            complete_command_list.append(
                self.system_bin_as_binary + b"ls -lZ " + bytes(so_se_pair.first[file_index]).rstrip()
            )
        complete_command_list_bytes = b"\n".join(complete_command_list)
        so_se_pair2 = self.write_and_wait_list(complete_command_list_bytes, timeout=timeout)

        for index in range((so_se_pair2.first.size())):
            linetmp = bytes(so_se_pair2.first[index]).strip().split(maxsplit=8)
            if len(linetmp) != 9:
                continue
            linetmp[6] = linetmp[6] + b" " + linetmp[7]
            del linetmp[7]
            goodfiles.append(b'"' + b'","'.join(linetmp) + b'"')

        df = pd.read_csv(
            io.StringIO(b"\n".join(goodfiles).decode("utf-8", "backslashreplace")),
            encoding="utf-8",
            sep=",",
            index_col=False,
            encoding_errors="backslashreplace",
            on_bad_lines="warn",
            engine="python",
            na_filter=False,
            quoting=1,
            names=[
                "aa_Permissions",
                "aa_Links",
                "aa_Owner",
                "aa_Group",
                "aa_SELinux",
                "aa_Size",
                "aa_Date",
                "aa_Path",
            ],
        )
        if with_dates:
            df.loc[:, "aa_date_time"] = pd.to_datetime(df.aa_Date, errors="coerce")
            print(df)
            df.loc[:, "aa_tstamp"] = df["aa_date_time"].apply(
                lambda x: x.value if not pd.isna(x) else pd.NA
            )
        df.loc[:, "aa_Permissions_as_int"] = df.aa_Permissions.apply(
            calculate_chmod
        )
        return df

    def get_df_build_props(self, int64_t timeout=10):
        cdef:
            pair[vector[string],vector[string]] so_se_pair,so_se_pair2
            list complete_command_list = []
            Py_ssize_t li,file_index
            str file_stripped

        so_se_pair = self.write_and_wait_list(
            self._c.SH_FIND_PROP_FILES.format(exe_path=self.system_bin),
            timeout=timeout
        )
        for file_index in range(so_se_pair.first.size()):
            file_stripped = bytes(so_se_pair.first[file_index]).strip().decode("utf-8", "backslashreplace")
            so_se_pair2 = self.write_and_wait_list(f"{self.system_bin}cat " + file_stripped,timeout=timeout)
            for li in range(so_se_pair2.first.size()):
                complete_command_list.append((file_stripped, li, bytes(so_se_pair2.first[li])))
        return pd.DataFrame(
            complete_command_list, columns=["aa_file", "aa_line", "aa_line_content"]
        )

    def get_df_files_with_ending(self, object folders, object endings, int64_t max_depth=10000, int64_t timeout=10):
        cdef:
            list ac = []
            str wholecmd
            pair[vector[string],vector[string]] so_se_pair
        folders=convert_to_list(folders)
        endings=convert_to_list(endings)
        for folder in folders:
            for ending in endings:
                ac.append(
                    self._c.SH_FIND_FILES_WITH_ENDING.format(
                        exe_path=self.system_bin,
                        folder_path=folder,
                        max_depth=max_depth,
                        ending=ending,
                    )
                )
        wholecmd = "\n".join(ac)
        so_se_pair = self.write_and_wait_list(wholecmd.encode("utf-8"), timeout=timeout)
        return pd.DataFrame(
            (q.decode("utf-8", "backslashreplace").strip() for q in list(so_se_pair.first)),
            columns=["aa_file"],
        )

    def get_df_top_procs(self, timeout=1000):
        return pd.read_csv(
            io.StringIO(
                (
                    b"\n".join(
                        b'"' + b'","'.join(q) + b'"'
                        for x in list(
                            self.write_and_wait_list(
                                f"{self.system_bin}top -b -n1", timeout=timeout
                            ).first
                        )
                        if proc_match(x)
                        and len(q := x.strip().split(maxsplit=11)) == 12
                    )
                ).decode("utf-8", "backslashreplace")
            ),
            encoding="utf-8",
            sep=",",
            index_col=False,
            encoding_errors="backslashreplace",
            on_bad_lines="warn",
            engine="python",
            na_filter=False,
            quoting=1,
            names=[
                "aa_PID",
                "aa_USER",
                "aa_PR",
                "aa_NI",
                "aa_VIRT",
                "aa_RES",
                "aa_SHR",
                "aa_CPU",
                "aa_MEM",
                "aa_TIME",
                "aa_ARGS",
            ],
        )
    def get_df_users(self, start=0, end=2000, timeout=10000):
        cdef:
            pair[vector[string],vector[string]] so_se_pair
            list[list] usergroup = []
            list ss
            Py_ssize_t s_index
        so_se_pair = self.write_and_wait_list(
            f'for q in $({self.system_bin}seq {start} {end}); do {self.system_bin}id "$q";done'
        )
        for s_index in range(so_se_pair.first.size()):
            ss = bytes(so_se_pair.first[s_index]).decode("utf-8", "backslashreplace").split()
            if len(ss) >= 2:
                usergroup.append([])
            else:
                continue
            for sss in ss:
                item = sss.split("=")
                if len(item) == 2:
                    usergroup[len(usergroup)-1].append(tuple(item))
            usergroup[len(usergroup)-1] = dict(usergroup[len(usergroup)-1])
        return pd.DataFrame(usergroup)

    def get_df_groups_of_user(self, start=0, end=2000, timeout=10000):
        cdef:
            pair[vector[string],vector[string]] so_se_pair
            list ss
            Py_ssize_t s_index
            dict usergroupdict = {}
        so_se_pair = self.write_and_wait_list(
            f'for q in $({self.system_bin}seq {start} {end}); do u="$({self.system_bin}groups "$q")" && echo "$u||||$q" ;done'
        )

        for s_index in range(so_se_pair.first.size()):
            ss = (bytes(so_se_pair.first[s_index]).decode("utf-8", "backslashreplace")).split("||||")
            if len(ss) != 2:
                continue
            usergroupdict[int(ss[1])] = ss[0]
        return (
            pd.Series(usergroupdict)
            .to_frame()
            .reset_index()
            .rename(columns={"index": "aa_id", 0: "aa_groups"})
        )
    def get_df_netstat_tlnp(self, timeout=100):
        return pd.read_csv(
            io.StringIO(
                "\n".join(
                    (
                        '"' + '","'.join(h) + '"'
                        for h in (
                            z[:6] + z[6].split("/", maxsplit=1)
                            for z in (
                                y.decode("utf-8", "backslashreplace")
                                .split(maxsplit=6)
                                for y in self.write_and_wait_list(
                                    f"{self.system_bin}netstat -tlnp", timeout=timeout
                                ).first
                                if regex_netstat(y)
                            )
                            if len(z) == 7
                        )
                        if len(h) == 8
                    )
                )
            ),
            encoding="utf-8",
            sep=",",
            index_col=False,
            encoding_errors="backslashreplace",
            on_bad_lines="warn",
            engine="python",
            na_filter=False,
            quoting=1,
            names=[
                "aa_Proto",
                "aa_RecvQ",
                "aa_SendQ",
                "aa_LocalAddress",
                "aa_ForeignAddress",
                "aa_State",
                "aa_PID",
                "aa_ProgramName",
            ],
        )
    def touch_make(self,object path):
        cdef:
            Py_ssize_t i
        path=convert_to_list(path)
        for i in range(len(path)):
            touch(path[i])

    def sh_save_sed_replace(self, file_path, string2replace, replacement, timeout=1000):
        return self._write_and_wait(
            self._c.SH_SAVE_SED_REPLACE.format(
                exe_path=self.system_bin,
                file_path=file_path,
                string2replace=string2replace,
                replacement=replacement,
            ),
            timeout=timeout,
        )

    def sh_svc_enable_wifi(self, timeout=10):
        return self._write_and_wait(
            self._c.SH_SVC_ENABLE_WIFI.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_svc_disable_wifi(self, timeout=10):
        return self._write_and_wait(
            self._c.SH_SVC_DISABLE_WIFI.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )
    def sh_trim_cache(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_TRIM_CACHES.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_force_open_app(self, package_name, sleep_time, timeout=3):
        return self.write_and_wait(
            self._c.SH_FORCE_OPEN_APP.format(
                exe_path=self.system_bin,
                package_name=package_name,
                sleep_time=sleep_time,
            ),
            timeout=timeout,
        )
    def sh_get_main_activity(self, package_name, timeout=3):
        return self.write_and_wait(
            self._c.SH_GET_MAIN_ACTIVITY.format(
                exe_path=self.system_bin,
                package_name=package_name,
            ),
            timeout=timeout,
        )

    def sh_svc_power_shutdown(self, timeout=3):
        return self.write_and_wait(
            self._c.SH_SVC_POWER_SHUT_DOWN.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_svc_power_reboot(self, timeout=3):
        return self.write_and_wait(
            self._c.SH_SVC_POWER_REBOOT.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )
    def sh_dumpsys_dropbox(self, timeout=3):
        return self.write_and_wait(
            self._c.SH_DUMPSYS_DROPBOX.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_set_new_launcher(self, package_name, timeout=3):
        return self.write_and_wait(
            self._c.SH_SET_NEW_LAUNCHER.format(
                exe_path=self.system_bin,
                package_name=package_name,
            ),
            timeout=timeout,
        )
    def sh_tar_folder(self, src, dst, timeout=1000000):
        return self.write_and_wait(
            self._c.SH_TAR_FOLDER.format(
                exe_path=self.system_bin,
                dst=dst,
                src=src,
            ),
            timeout=timeout,
        )

    def sh_extract_tar_zip(self, src_file, dst_folder, timeout=1000000):
        return self.write_and_wait(
            self._c.SH_EXTRACT_FILES.replace("COMPRESSED_ARCHIVE", src_file).replace(
                "FOLDER_TO_EXTRACT", dst_folder
            ),
            timeout=timeout,
        )
    def sh_get_user_rotation(self, timeout=10):
        return int(
            bytes(
                self.write_and_wait(
                    self._c.SH_GET_USER_ROTATION.format(
                        exe_path=self.system_bin,
                    ),
                    timeout=timeout,
                ).first
            ).strip()
        )


    def sh_copy_dir_recursive(self, src, dst, timeout=1000):
        return self.write_and_wait(
            self._c.SH_COPY_DIR_RECURSIVE.format(
                exe_path=self.system_bin,
                src=src,
                dst=dst,
            ),
            timeout=timeout,
        )

    def sh_backup_file(self, src, timeout=1000):
        return self.write_and_wait(
            self._c.SH_BACKUP_FILE.format(
                exe_path=self.system_bin,
                src=src,
            ),
            timeout=timeout,
        )

    def sh_remove_folder(self, folder, timeout=1000):
        return self.write_and_wait(
            self._c.SH_REMOVE_FOLDER.format(
                exe_path=self.system_bin,
                folder=folder,
            ),
            timeout=timeout,
        )
    def sh_get_pid_of_shell(self, int64_t timeout=3):
        return int(
            self.write_and_wait(
                self._c.SH_GET_PID_OF_SHELL,
                timeout=timeout,
            ).first
        )
    def sh_whoami(self, int64_t timeout=10):
        return self.write_and_wait(
            self._c.SH_WHOAMI.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        ).first

    def su(self):
        self.p.subproc.stdin_write(self.su_exe[0])

    def sh_dumpsys_package(self, package, timeout=1000, bint convert_to_dict=True):
        cdef:
            bytes so
            list[bytes] byteslist
        so = self.write_and_wait(
            self._c.SH_DUMPSYS_PACKAGE.format(
                exe_path=self.system_bin,
                package=package,
            ),
            timeout=timeout,
        ).first
        byteslist=so.splitlines(keepends=True)
        return _dumpsys_splitter_to_dict(byteslist,convert_to_dict=convert_to_dict)

    def sh_get_all_wanted_permissions_from_package(self, package, timeout=1000):
        cdef:
            set all_permissions
        dd1 = self.sh_dumpsys_package(package,timeout=timeout,convert_to_dict=False)
        declared_permissions = list(dd1.nested_key_search("declared permissions:"))
        requested_permissions = list(dd1.nested_key_search("requested permissions:"))
        install_permissions = list(dd1.nested_key_search("install permissions:"))
        all_permissions = set()
        for permissions in [
            declared_permissions,
            requested_permissions,
            install_permissions,
        ]:
            for install_permission in permissions:
                for ipi in install_permission[len(install_permission)-1]:
                    all_permissions.add(ipi.split(":")[0].strip())
        return sorted(all_permissions)

    def sh_grant_permission(self, package, permission, timeout=10):
        return self.write_and_wait(
            self._c.SH_GRANT_PERMISSION.format(
                exe_path=self.system_bin,
                package=package,
                permission=permission,
            ),
            timeout=timeout,
        )

    def sh_grant_permission(self, package, permission, timeout=10):
        return self.write_and_wait(
            self._c.SH_REVOKE_PERMISSION.format(
                exe_path=self.system_bin,
                package=package,
                permission=permission,
            ),
            timeout=timeout,
        )

    def sh_grant_all_wanted_permissions(self, package, timeout=1000):
        cdef:
            list allcmds = []
        permissions = self.sh_get_all_wanted_permissions_from_package(package, timeout=timeout)
        for permission in permissions:
            allcmds.append(
                self._c.SH_GRANT_PERMISSION.format(
                    exe_path=self.system_bin,
                    package=package,
                    permission=permission,
                )
            )
        return self.write_and_wait("\n".join(allcmds), timeout=timeout)

    def sh_revoke_all_wanted_permissions(self, package, timeout=1000):
        cdef:
            list allcmds = []
        permissions = self.sh_get_all_wanted_permissions_from_package(package, timeout=timeout)
        for permission in permissions:
            allcmds.append(
                self._c.SH_REVOKE_PERMISSION.format(
                    exe_path=self.system_bin,
                    package=package,
                    permission=permission,
                )
            )
        return self.write_and_wait("\n".join(allcmds), timeout=timeout)

    def sh_parse_whole_dumpsys_to_dict(self, timeout=100,convert_to_dict=False):
        cdef:
            bytes so3
            dict wholedict = {}
            list[bytes] so
            list[str] so2
        so = self.write_and_wait_list(f"{self.system_bin}dumpsys -l", timeout=timeout).first
        so2 = [
            f"{self.system_bin}dumpsys " + x.decode("utf-8").strip()
            for x in so
            if len(x) > 1 and x[0] == 32
        ]
        for cmd in so2:
            so3 = self.write_and_wait(cmd, timeout=timeout).first
            wholedict[cmd.split()[1]] = _dumpsys_splitter_to_dict(so3.splitlines(keepends=True),convert_to_dict=convert_to_dict)
        return wholedict

    def sh_parse_dumpsys_to_dict(self, subcmd, timeout=100,convert_to_dict=False):
        cdef:
            bytes so3
        so3=self.write_and_wait(f"{self.system_bin}dumpsys {subcmd}", timeout=timeout).first
        return _dumpsys_splitter_to_dict(so3.splitlines(keepends=True),convert_to_dict=convert_to_dict)


    def sh_get_available_keyboards(self, timeout=10):
        return [
            x.decode("utf-8", "backslashreplace").strip()
            for x in self.write_and_wait_list(
                self._c.SH_GET_AVAIABLE_KEYBOARDS.format(
                    exe_path=self.system_bin,
                ),
                timeout=timeout,
            ).first
        ]

    @cython.boundscheck
    def sh_get_active_keyboard(self, timeout=10):
        return [
            x.decode("utf-8", "backslashreplace").strip()
            for x in self.write_and_wait_list(
                self._c.SH_GET_ACTIVE_KEYBOARD.format(
                    exe_path=self.system_bin,
                ),
                timeout=timeout,
            ).first
        ][0]

    def sh_get_all_information_about_all_keyboards(self, timeout=10,convert_to_dict=False):
        return _dumpsys_splitter_to_dict(
            bytes(self.write_and_wait(
                self._c.SH_GET_ALL_KEYBOARDS_INFORMATION.format(
                    exe_path=self.system_bin,
                ),
                timeout=timeout,
            ).first).splitlines(keepends=True), convert_to_dict=convert_to_dict
        )

    def sh_enable_keyboard(self, keyboard, timeout=10):
        return self.write_and_wait(
            self._c.SH_ENABLE_KEYBOARD.format(
                exe_path=self.system_bin,
                keyboard=keyboard,
            ),
            timeout=timeout,
        )

    def sh_disable_keyboard(self, keyboard, timeout=10):
        return self.write_and_wait(
            self._c.SH_DISABLE_KEYBOARD.format(
                exe_path=self.system_bin,
                keyboard=keyboard,
            ),
            timeout=timeout,
        )

    def sh_is_keyboard_shown(self, timeout=10):
        cdef:
            bytes stdout
        stdout = (
            self.write_and_wait(
                self._c.SH_IS_KEYBOARD_SHOWN.format(
                    exe_path=self.system_bin,
                ),
                timeout=timeout,
            ).first
        )
        return b"mInputShown=true" in stdout

    def sh_set_keyboard(self, keyboard, timeout=10):
        return self.write_and_wait(
            self._c.SH_SET_KEYBOARD.format(
                exe_path=self.system_bin,
                keyboard=keyboard,
            ),
            timeout=timeout,
        )

    def sh_show_touches(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_SHOW_TOUCHES.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_dont_show_touches(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_SHOW_TOUCHES_NOT.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_show_pointer_location(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_SHOW_POINTER_LOCATION.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_dont_show_pointer_location(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_SHOW_POINTER_LOCATION_NOT.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_input_swipe(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_SWIPE.format(
                exe_path=self.system_bin,
                x1=int(x1),
                y1=int(y1),
                x2=int(x2),
                y2=int(y2),
                duration=int(duration),
            ),
            timeout=timeout,
        )

    def sh_input_tap(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_TAP.format(
                exe_path=self.system_bin,
                x=int(x),
                y=int(y),
            ),
            timeout=timeout,
        )

    def df_apply_md5_code_of_files(self, df, column_name, timeout=1000000):
        df.loc[:, str(column_name) + "_md5"] = (
            self.system_bin + "md5sum -b '" + df[column_name].str.replace("'", "'\\''",regex=False) + "'"
        )
        df.loc[:, str(column_name) + "_md5"] = [
            x.decode("utf-8", "backslashreplace").strip()
            for x in self.write_and_wait_list(
                "\n".join(df.loc[:, str(column_name) + "_md5"].to_list()),
                timeout=timeout,
            ).first
        ][: len(df)]

    def sh_clear_file_content(self, file_path, timeout=10):
        return self.write_and_wait(
            self._c.SH_CLEAR_FILE_CONTENT.format(
                exe_path=self.system_bin,
                file_path=file_path,
            ),
            timeout=timeout,
        )

    def sh_makedirs(self, folder, timeout=10):
        return self.write_and_wait(
            self._c.SH_MAKEDIRS.format(
                exe_path=self.system_bin,
                folder=folder,
            ),
            timeout=timeout,
        )

    def sh_touch(self, file_path, timeout=10):
        return self.write_and_wait(
            self._c.SH_TOUCH.format(
                exe_path=self.system_bin,
                file_path=file_path,
            ),
            timeout=timeout,
        )

    def sh_mv(self, src, dst, timeout=10):
        return self.write_and_wait(
            self._c.SH_MV.format(
                exe_path=self.system_bin,
                src=src,
                dst=dst,
            ),
            timeout=timeout,
        )

    def get_df_mounts(self, timeout=100):
        return pd.DataFrame(
            [
                h
                for h in [
                    z[:2] + z[2].split(maxsplit=1)
                    for z in [
                        y
                        for y in [
                            re.split(
                                r"\s+\b(?:on|type)\b\s+",
                                x.strip().decode("utf-8", "backslashreplace"),
                            )
                            for x in self.write_and_wait_list(f"{self.system_bin}mount -v",timeout=timeout).first
                        ]
                        if len(y) == 3
                    ]
                ]
                if len(h) == 4
            ],
            columns=["aa_identifier", "aa_mountpoint", "aa_type", "aa_options"],
        )
    def sh_open_accessibility_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_ACCESSIBILITY_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_advanced_memory_protection_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_ADVANCED_MEMORY_PROTECTION_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_airplane_mode_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_AIRPLANE_MODE_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_all_apps_notification_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_ALL_APPS_NOTIFICATION_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_apn_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_APN_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_application_details_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_APPLICATION_DETAILS_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_application_development_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_APPLICATION_DEVELOPMENT_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_application_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_APPLICATION_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_app_locale_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_APP_LOCALE_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_app_notification_bubble_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_APP_NOTIFICATION_BUBBLE_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_app_notification_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_APP_NOTIFICATION_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_app_open_by_default_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_APP_OPEN_BY_DEFAULT_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_app_search_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_APP_SEARCH_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_app_usage_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_APP_USAGE_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_automatic_zen_rule_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_AUTOMATIC_ZEN_RULE_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_auto_rotate_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_AUTO_ROTATE_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_battery_saver_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_BATTERY_SAVER_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_bluetooth_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_BLUETOOTH_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_captioning_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_CAPTIONING_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_cast_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_CAST_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_channel_notification_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_CHANNEL_NOTIFICATION_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_condition_provider_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_CONDITION_PROVIDER_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_data_roaming_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_DATA_ROAMING_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_data_usage_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_DATA_USAGE_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_date_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_DATE_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_device_info_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_DEVICE_INFO_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_display_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_DISPLAY_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_dream_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_DREAM_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_hard_keyboard_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_HARD_KEYBOARD_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_home_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_HOME_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_ignore_background_data_restrictions_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_IGNORE_BACKGROUND_DATA_RESTRICTIONS_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_ignore_battery_optimization_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_IGNORE_BATTERY_OPTIMIZATION_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_input_method_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_INPUT_METHOD_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_input_method_subtype_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_INPUT_METHOD_SUBTYPE_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_internal_storage_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_INTERNAL_STORAGE_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_locale_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_LOCALE_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_location_source_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_LOCATION_SOURCE_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_manage_all_applications_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_MANAGE_ALL_APPLICATIONS_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_manage_all_sim_profiles_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_MANAGE_ALL_SIM_PROFILES_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_manage_applications_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_MANAGE_APPLICATIONS_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_manage_default_apps_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_MANAGE_DEFAULT_APPS_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_manage_supervisor_restricted_setting(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_MANAGE_SUPERVISOR_RESTRICTED_SETTING.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_manage_write_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_MANAGE_WRITE_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_memory_card_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_MEMORY_CARD_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_network_operator_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_NETWORK_OPERATOR_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_nfcsharing_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_NFCSHARING_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_nfc_payment_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_NFC_PAYMENT_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_nfc_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_NFC_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_night_display_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_NIGHT_DISPLAY_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_notification_assistant_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_NOTIFICATION_ASSISTANT_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_notification_listener_detail_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_NOTIFICATION_LISTENER_DETAIL_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_notification_listener_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_NOTIFICATION_LISTENER_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_notification_policy_access_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_NOTIFICATION_POLICY_ACCESS_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_print_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_PRINT_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_privacy_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_PRIVACY_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_quick_access_wallet_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_QUICK_ACCESS_WALLET_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_quick_launch_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_QUICK_LAUNCH_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_regional_preferences_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_REGIONAL_PREFERENCES_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_satellite_setting(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_SATELLITE_SETTING.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_search_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_SEARCH_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_security_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_SECURITY_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_sound_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_SOUND_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_storage_volume_access_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_STORAGE_VOLUME_ACCESS_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_sync_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_SYNC_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_usage_access_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_USAGE_ACCESS_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_user_dictionary_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_USER_DICTIONARY_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_voice_input_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_VOICE_INPUT_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_vpn_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_VPN_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_vr_listener_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_VR_LISTENER_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_webview_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_WEBVIEW_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_wifi_ip_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_WIFI_IP_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_wifi_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_WIFI_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_wireless_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_WIRELESS_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_zen_mode_priority_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_ZEN_MODE_PRIORITY_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_open_developer_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_DEVELOPER_SETTINGS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_rescan_media_folder(self, folder, timeout=10):
        return self.write_and_wait(
            self._c.SH_RESCAN_MEDIA_FOLDER.format(
                exe_path=self.system_bin,
                folder=folder,
            ),
            timeout=timeout,
        )

    def sh_rescan_media_file(self, file_path, timeout=10):
        return self.write_and_wait(
            self._c.SH_RESCAN_MEDIA_FILE.format(
                exe_path=self.system_bin,
                file_path=file_path,
            ),
            timeout=timeout,
        )
    def sh_dump_process_memory_to_sdcard(self, pid, timeout=100000):
        return self.write_and_wait(
            self._c.SH_DUMP_PROCESS_MEMORY_TO_SDCARD.replace("PID2OBSERVE", str(pid)),
            timeout=timeout,
        )

    def sh_pm_clear(self, package, timeout=10):
        return self.write_and_wait(
            self._c.SH_PM_CLEAR.format(
                exe_path=self.system_bin,
                package=package,
            ),
            timeout=timeout,
        )
    def get_df_ps_el(self, timeout=1000):
        df = pd.read_csv(
            io.StringIO(
                (
                    b"\n".join(
                        (
                            b'"' + b'","'.join(y) + b'"'
                            for y in (
                                x.strip().split(maxsplit=13)
                                for x in self.write_and_wait_list(
                                    f"""{self.system_bin}ps -el""",timeout=timeout
                                ).first
                            )
                            if len(y) == 14
                        )
                    )
                ).decode("utf-8", "backslashreplace")
            ),
            encoding="utf-8",
            sep=",",
            index_col=False,
            encoding_errors="backslashreplace",
            on_bad_lines="warn",
            engine="python",
            na_filter=False,
            quoting=1,
        )
        df.columns = ["aa_" + x for x in df.columns]
        return df
    def sh_wm_change_size(self, width, height, timeout=10):
        return self.write_and_wait(
            self._c.SH_CHANGE_WM_SIZE.format(
                exe_path=self.system_bin,
                width=width,
                height=height,
            ),
            timeout=timeout,
        )

    def sh_wm_reset_size(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_WM_RESET_SIZE.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_wm_get_density(self, timeout=10):
        cdef:
            bytes resu
        resu = (
            self.write_and_wait(
                self._c.SH_GET_WM_DENSITY.format(
                    exe_path=self.system_bin,
                ),
                timeout=timeout,
            ).first
        )
        resu2 = resu.strip().split()
        return int(resu2[len(resu2) - 1])

    def sh_wm_change_density(self, density, timeout=10):
        return self.write_and_wait(
            self._c.SH_CHANGE_WM_DENSITY.format(
                exe_path=self.system_bin,
                density=density,
            ),
            timeout=timeout,
        )

    def sh_wm_reset_density(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_WM_RESET_DENSITY.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_am_screen_compat_on(self, package, timeout=10):
        return self.write_and_wait(
            self._c.SH_AM_SCREEN_COMPAT_ON.format(
                exe_path=self.system_bin,
                package=package,
            ),
            timeout=timeout,
        )

    def sh_am_screen_compat_off(self, package, timeout=10):
        return self.write_and_wait(
            self._c.SH_AM_SCREEN_COMPAT_OFF.format(
                exe_path=self.system_bin,
                package=package,
            ),
            timeout=timeout,
        )

    def sh_enable_notifications(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_ENABLE_NOTIFICATIONS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_disable_notifications(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_DISABLE_NOTIFICATIONS.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )

    def sh_still_image_camera(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_STILL_IMAGE_CAMERA.format(
                exe_path=self.system_bin,
            ),
            timeout=timeout,
        )
    def sh_disable_network_interface(self, nic, timeout=10):
        return self.write_and_wait(
            self._c.SH_DISABLE_NETWORK_INTERFACE.format(
                exe_path=self.system_bin,
                nic=nic,
            ),
            timeout=timeout,
        )

    def sh_enable_network_interface(self, nic, timeout=10):
        return self.write_and_wait(
            self._c.SH_ENABLE_NETWORK_INTERFACE.format(
                exe_path=self.system_bin,
                nic=nic,
            ),
            timeout=timeout,
        )

    def sh_get_linux_version(self, timeout=10):
        return (
            (
                self.write_and_wait(
                    self._c.SH_GET_LINUX_VERSION.format(
                        exe_path=self.system_bin,
                    ),
                    timeout=timeout,
                ).first
            )
            .decode("utf-8", "backslashreplace")
            .strip()
        )
    def get_df_packages(self, timeout=10):
        df2 = pd.DataFrame(
            (
                h
                for h in (
                    regex_package_start("", y[0]).rsplit("=", maxsplit=1) + y[1:]
                    for y in (
                        x.strip().decode().rsplit(maxsplit=2)
                        for x in self.write_and_wait_list(
                            f"""{self.system_bin}pm list packages -f -i -U -s""",
                            timeout=timeout,
                        ).first
                    )
                    if len(y) == 3
                )
                if len(h) == 4
            ),
            columns=["aa_apk", "aa_package", "aa_installer", "aa_uid"],
        ).assign(
            aa_3rd_party=False,
        )
        try:
            df1 = pd.DataFrame(
                (
                    h
                    for h in (
                        regex_package_start("", y[0]).rsplit("=", maxsplit=1)
                        + y[1:]
                        for y in (
                            x.strip().decode().rsplit(maxsplit=2)
                            for x in self.write_and_wait_list(
                                f"""{self.system_bin}pm list packages -f -i -U -3""",
                                timeout=timeout,
                            ).first
                        )
                        if len(y) == 3
                    )
                    if len(h) == 4
                ),
                columns=["aa_apk", "aa_package", "aa_installer", "aa_uid"],
            ).assign(
                aa_3rd_party=True,
            )
            return pd.concat([df2, df1], ignore_index=True)
        except Exception:
            return df2

    def get_df_netstat_connections_of_apps(self, resolve_names=True, timeout=10):
        cdef:
            list[bytes] so
        if resolve_names:
            so = self.write_and_wait_list(
                f"""{self.system_bin}netstat -W -p -u -t -l -e""",
                timeout=timeout,
            ).first
        else:
            so = self.write_and_wait_list(
                f"""{self.system_bin}netstat -n -W -p -u -t -l -e""",
                timeout=timeout,
            ).first
        return pd.read_csv(
            io.StringIO(
                (
                    b"\n".join(
                        (
                            b'"' + b'","'.join(z) + b'"'
                            for z in (
                                y[:8] + y[8].split(b"/", maxsplit=1)
                                for y in (x.strip().split(maxsplit=8) for x in so)
                                if len(y) == 9 and y[1].isdigit() and y[2].isdigit()
                            )
                        )
                    )
                ).decode("utf-8", "backslashreplace")
            ),
            encoding="utf-8",
            sep=",",
            index_col=False,
            encoding_errors="backslashreplace",
            on_bad_lines="warn",
            engine="python",
            na_filter=False,
            quoting=1,
            names=[
                "aa_proto",
                "aa_recv_q",
                "aa_send_q",
                "aa_local_addr",
                "aa_foreign_addr",
                "aa_state",
                "aa_user",
                "aa_inode",
                "aa_pid",
                "aa_program",
            ],
        )
    def sh_expand_notifications(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_EXPAND_NOTIFICATIONS % (self.system_bin,),
            timeout=timeout,
        )

    def sh_expand_settings(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_EXPAND_SETTINGS % (self.system_bin,),
            timeout=timeout,
        )

    def sh_list_permission_groups(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_LIST_PERMISSION_GROUPS % (self.system_bin,),
            timeout=timeout,
        )

    def sh_input_dpad_tap(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_DPAD_TAP % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_keyboard_tap(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_KEYBOARD_TAP % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_mouse_tap(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_MOUSE_TAP % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_touchpad_tap(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_TOUCHPAD_TAP % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_gamepad_tap(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_GAMEPAD_TAP % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_touchnavigation_tap(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_TOUCHNAVIGATION_TAP
            % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_joystick_tap(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_JOYSTICK_TAP % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_touchscreen_tap(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_TOUCHSCREEN_TAP
            % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_stylus_tap(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_STYLUS_TAP % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_trackball_tap(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_TRACKBALL_TAP
            % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_dpad_swipe(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_DPAD_SWIPE
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_dpad_draganddrop(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_DPAD_DRAGANDDROP
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_dpad_roll(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_DPAD_ROLL % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_keyboard_swipe(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_KEYBOARD_SWIPE
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_keyboard_draganddrop(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_KEYBOARD_DRAGANDDROP
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_keyboard_roll(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_KEYBOARD_ROLL
            % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_mouse_swipe(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_MOUSE_SWIPE
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_mouse_draganddrop(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_MOUSE_DRAGANDDROP
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_mouse_roll(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_MOUSE_ROLL % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_touchpad_swipe(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_TOUCHPAD_SWIPE
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_touchpad_draganddrop(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_TOUCHPAD_DRAGANDDROP
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_touchpad_roll(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_TOUCHPAD_ROLL
            % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_gamepad_swipe(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_GAMEPAD_SWIPE
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_gamepad_draganddrop(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_GAMEPAD_DRAGANDDROP
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_gamepad_roll(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_GAMEPAD_ROLL % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_touchnavigation_swipe(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_TOUCHNAVIGATION_SWIPE
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_touchnavigation_draganddrop(
        self, x1, y1, x2, y2, duration, timeout=10
    ):
        return self.write_and_wait(
            self._c.SH_INPUT_TOUCHNAVIGATION_DRAGANDDROP
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_touchnavigation_roll(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_TOUCHNAVIGATION_ROLL
            % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_joystick_swipe(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_JOYSTICK_SWIPE
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_joystick_draganddrop(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_JOYSTICK_DRAGANDDROP
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_joystick_roll(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_JOYSTICK_ROLL
            % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_touchscreen_swipe(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_TOUCHSCREEN_SWIPE
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_touchscreen_draganddrop(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_TOUCHSCREEN_DRAGANDDROP
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_touchscreen_roll(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_TOUCHSCREEN_ROLL
            % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_stylus_swipe(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_STYLUS_SWIPE
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_stylus_draganddrop(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_STYLUS_DRAGANDDROP
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_stylus_roll(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_STYLUS_ROLL % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_input_trackball_swipe(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_TRACKBALL_SWIPE
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_trackball_draganddrop(self, x1, y1, x2, y2, duration, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_TRACKBALL_DRAGANDDROP
            % (
                self.system_bin,
                tointstr(x1),
                tointstr(y1),
                tointstr(x2),
                tointstr(y2),
                tointstr(duration),
            ),
            timeout=timeout,
        )

    def sh_input_trackball_roll(self, x, y, timeout=10):
        return self.write_and_wait(
            self._c.SH_INPUT_TRACKBALL_ROLL
            % (self.system_bin, tointstr(x), tointstr(y)),
            timeout=timeout,
        )

    def sh_open_url(self, url, timeout=10):
        return self.write_and_wait(
            self._c.SH_OPEN_URL.format(exe_path=self.system_bin, url=url),
            timeout=timeout,
        )

    def sh_get_bios_information(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_GET_BIOS_INFO.format(exe_path=self.system_bin),
            timeout=timeout,
        )
    def sh_printenv(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_PRINTENV.format(exe_path=self.system_bin),
            timeout=timeout,
        )

    def sh_freeze_proc(self, pid, timeout=10):
        return self.write_and_wait(
            self._c.SH_FREEZE_PROC.format(exe_path=self.system_bin, pid=pid),
            timeout=timeout,
        )

    def sh_unfreeze_proc(self, pid, timeout=10):
        return self.write_and_wait(
            self._c.SH_UNFREEZE_PROC.format(exe_path=self.system_bin, pid=pid),
            timeout=timeout,
        )

    def sh_show_fragments_on_screen_enable(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_SHOW_FRAGMENTS_ON_SCREEN_ENABLE.format(exe_path=self.system_bin),
            timeout=timeout,
        )

    def sh_show_fragments_on_screen_disable(self, timeout=10):
        return self.write_and_wait(
            self._c.SH_SHOW_FRAGMENTS_SCREEN_DISABLE.format(exe_path=self.system_bin),
            timeout=timeout,
        )

    def sh_read_write_remount(self, methods, timeout=100):
        cdef:
            list results = []
            dict remount_dict = {
            1: self._c.SH_READ_WRITE_REMOUNT_V01,
            2: self._c.SH_READ_WRITE_REMOUNT_V02,
            3: self._c.SH_READ_WRITE_REMOUNT_V03,
            4: self._c.SH_READ_WRITE_REMOUNT_V04,
            5: self._c.SH_READ_WRITE_REMOUNT_V05,
            6: self._c.SH_READ_WRITE_REMOUNT_V06,
            7: self._c.SH_READ_WRITE_REMOUNT_V07,
            8: self._c.SH_READ_WRITE_REMOUNT_V08,
            9: self._c.SH_READ_WRITE_REMOUNT_V09,
            10: self._c.SH_READ_WRITE_REMOUNT_V10,
            11: self._c.SH_READ_WRITE_REMOUNT_V11,
            12: self._c.SH_READ_WRITE_REMOUNT_V12,
            13: self._c.SH_READ_WRITE_REMOUNT_V13,
            14: self._c.SH_READ_WRITE_REMOUNT_V14,
            15: self._c.SH_READ_WRITE_REMOUNT_V15,
            16: self._c.SH_READ_WRITE_REMOUNT_V16,
            17: self._c.SH_READ_WRITE_REMOUNT_V17,
            18: self._c.SH_READ_WRITE_REMOUNT_V18,
            19: self._c.SH_READ_WRITE_REMOUNT_V19,
            20: self._c.SH_READ_WRITE_REMOUNT_V20,
            21: self._c.SH_READ_WRITE_REMOUNT_V21,
            22: self._c.SH_READ_WRITE_REMOUNT_V22,
            23: self._c.SH_READ_WRITE_REMOUNT_V23,
            24: self._c.SH_READ_WRITE_REMOUNT_V24,
            25: self._c.SH_READ_WRITE_REMOUNT_V25,
            26: self._c.SH_READ_WRITE_REMOUNT_V26,
            27: self._c.SH_READ_WRITE_REMOUNT_V27,
            28: self._c.SH_READ_WRITE_REMOUNT_V28,
        }
        if isinstance(methods, int):
            methods = [methods]

        for method in methods:
            results.append(self.write_and_wait(remount_dict[method], timeout=timeout))
        return results


    def get_df_lsmod(self, timeout=1000):
        so = list(self.write_and_wait_list(f"""{self.system_bin}lsmod""",timeout=timeout).first)
        if len(so)<2:
            return pd.DataFrame()
        so=so[1:]
        return pd.read_csv(
            io.StringIO(
                (
                    b"\n".join(
                        b'"' + b'","'.join(y[:3] + [y[3].rstrip(b" |").strip()]) + b'"'
                        for y in [(x + b" |").split(maxsplit=3) for x in so]
                        if len(y)==4
                    )
                ).decode("utf-8", "backslashreplace")
            ),
            encoding="utf-8",
            sep=",",
            index_col=False,
            encoding_errors="backslashreplace",
            on_bad_lines="warn",
            engine="python",
            na_filter=False,
            quoting=1,
            names=[
                "aa_module",
                "aa_size",
                "aa_used_by_no",
                "aa_used_by",
            ],
        )


    def get_df_lsof(self, timeout=1000000):
        so = list(self.write_and_wait_list(f"""{self.system_bin}lsof""", timeout=timeout).first)
        if len(so)<2:
            return pd.DataFrame()
        so=so[1:]
        df = pd.read_csv(
            io.StringIO(
                (
                    b"\n".join(
                        (
                            b'"' + b'","'.join(y) + b'"'
                            for y in [x.strip().split(maxsplit=5) for x in so]
                            if len(y) == 6
                        )
                    )
                ).decode("utf-8", "backslashreplace")
            ),
            encoding="utf-8",
            sep=",",
            index_col=False,
            encoding_errors="backslashreplace",
            on_bad_lines="warn",
            engine="python",
            na_filter=False,
            quoting=1,
            names=[
                "aa_COMMAND",
                "aa_PID",
                "aa_USER",
                "aa_FD",
                "aa_TYPE",
                "aa_DEVICE_SIZE_NODE_NAME",
            ],
        )

        df.loc[:,"tmpindex"] = df.index.__array__().copy()
        df.loc[:, "aa_DEVICE_SIZE_NODE_NAME"] = (
            df["tmpindex"].astype(str) + "|" + df["aa_DEVICE_SIZE_NODE_NAME"]
        )

        DEVICE_SIZE_NODE_NAME = df.aa_DEVICE_SIZE_NODE_NAME.str.extractall(
            regex_device_size_node_name,
        ).reset_index(drop=True)
        DEVICE_SIZE_NODE_NAME.loc[:, "tmpindex"] = (
            DEVICE_SIZE_NODE_NAME.tmpindex.astype(int)
        )
        DEVICE_SIZE_NODE_NAME.set_index("tmpindex", inplace=True)
        return (
            pd.merge(
                df, DEVICE_SIZE_NODE_NAME, how="left", left_index=True, right_index=True
            )
            .dropna(inplace=False)
            .drop(columns=["tmpindex", "aa_DEVICE_SIZE_NODE_NAME"], inplace=False)
            .reset_index(drop=True)
        )
