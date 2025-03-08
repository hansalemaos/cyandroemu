cimport cython
from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp.unordered_map cimport unordered_map
from libc.stdint cimport int64_t
from libcpp.utility cimport pair
import os.path
# https://www.youtube.com/watch?v=sWgDk-o-6ZE  (21:20)
cdef extern from "fuzzmatcher.h" nogil :
    cdef cppclass StringMatcher:
        StringMatcher(vector[string]&, vector[string]&)
        void _load_vecs_for_cython(vector[string]*, vector[string]*)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ab_map_longest_common_substring_v1(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ba_map_longest_common_substring_v1(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ab_map_hemming_distance_1way(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ba_map_hemming_distance_1way(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ab_map_hemming_distance_2ways(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ba_map_hemming_distance_2ways(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ab_map_longest_common_substring_v0(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ba_map_longest_common_substring_v0(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ab_map_longest_common_subsequence_v0(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ba_map_longest_common_subsequence_v0(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ab_map_damerau_levenshtein_distance_2ways(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ba_map_damerau_levenshtein_distance_2ways(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ab_map_damerau_levenshtein_distance_1way(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ba_map_damerau_levenshtein_distance_1way(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ab_map_levenshtein_distance_1way(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ba_map_levenshtein_distance_1way(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ab_map_levenshtein_distance_2ways(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ba_map_levenshtein_distance_2ways(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ab_map_jaro_distance_1way(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ba_map_jaro_distance_1way(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ab_map_jaro_winkler_distance_1way(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ba_map_jaro_winkler_distance_1way(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ab_map_jaro_winkler_distance_2ways(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ba_map_jaro_winkler_distance_2ways(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ab_map_jaro_2ways(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ba_map_jaro_2ways(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ab_map_subsequence_v1(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ba_map_subsequence_v1(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ab_map_subsequence_v2(bint print_results, bint convert_to_csv, string file_path)
        unordered_map[int64_t, unordered_map[int64_t, pair[double, int64_t]]] ba_map_subsequence_v2(bint print_results, bint convert_to_csv, string file_path)
        StringMatcher& to_upper()
        StringMatcher& to_lower()
        StringMatcher& to_without_non_alphanumeric()
        StringMatcher& to_without_non_printable()
        StringMatcher& to_100_percent_copy()
        StringMatcher& to_without_whitespaces()
        StringMatcher& to_with_normalized_whitespaces()
        void _str__for_cython();


cdef extern from "fuzzmatcher.h" namespace "stringhelpers" nogil :
    vector[string] read_file_to_vector_lines(const string& filename)
    void _repr__for_cython(vector[string]*v);


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



cdef void convert_to_stdvec(object stri, vector[string]& outvector):
    cdef:
        Py_ssize_t i
        string converted_cpp
    if isinstance(stri, (str, bytes)):
        stri = [stri]
    outvector.resize(len(stri))
    outvector.clear()
    for i in range(len(stri)):
        converted_cpp=convert_python_object_to_cpp_string(stri[i])
        outvector.emplace_back(converted_cpp)

cdef:
    string emptystring = <string>b""
    vector[string] emptystringvec = [b""]

@cython.final
cdef class PyStringMatcher:
    cdef:
        StringMatcher*sm
        vector[string] stri1list
        vector[string] stri2list

    def __cinit__(self):
        self.sm = new StringMatcher(emptystringvec,emptystringvec)
        self.stri1list=[]
        self.stri2list=[]

    def __init__(self, object stri1, object stri2):
        convert_to_stdvec(stri1,self.stri1list)
        convert_to_stdvec(stri2,self.stri2list)
        self.sm._load_vecs_for_cython(<vector[string]*>(&self.stri1list),<vector[string]*>(&self.stri2list))

    def __dealloc__(self):
        del self.sm

    def _filter_results(self, dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r, bint ab = True, bint sort_reverse=False):
        cdef:
            dict[str,object] outdict={}
            list sorteddict
            Py_ssize_t index
            bytes pystri1, pystri2
        sorteddict=sorted([[tuple(x[1].values())[0][0],x] for x in r.items()], key=lambda y: y[0],reverse=sort_reverse)
        for index in range(len(sorteddict)):
            if ab:
                pystri1=(self.stri1list[0][sorteddict[index][1][0]])
                pystri2=(self.stri2list[0][tuple(sorteddict[index][1][1].keys())[0]])
                outdict[index]={
                    "aa_match":sorteddict[index][0],
                    "aa_1_is_sub":tuple(sorteddict[index][1][1].values())[0][1],
                    "aa_index_1":sorteddict[index][1][0],
                    "aa_index_2":tuple(sorteddict[index][1][1].keys())[0],
                    "aa_str_1":pystri1.decode('utf-8','backslashreplace'),
                    "aa_str_2":pystri2.decode('utf-8','backslashreplace'),
                }
            else:
                pystri1=(self.stri2list[0][sorteddict[index][1][0]])
                pystri2=(self.stri1list[0][tuple(sorteddict[index][1][1].keys())[0]])
                outdict[index]={
                    "aa_match":sorteddict[index][0],
                    "aa_2_is_sub":tuple(sorteddict[index][1][1].values())[0][1],
                    "aa_index_2":sorteddict[index][1][0],
                    "aa_index_1":tuple(sorteddict[index][1][1].keys())[0],
                    "aa_str_2":pystri1.decode('utf-8','backslashreplace'),
                    "aa_str_1":pystri2.decode('utf-8','backslashreplace'),
                }
        return outdict

    def ab_map_damerau_levenshtein_distance_1way(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ab_map_damerau_levenshtein_distance_1way(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=True,sort_reverse=False)

    def ab_map_damerau_levenshtein_distance_2ways(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ab_map_damerau_levenshtein_distance_2ways(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=True,sort_reverse=False)

    def ab_map_hemming_distance_1way(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ab_map_hemming_distance_1way(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=True,sort_reverse=False)

    def ab_map_hemming_distance_2ways(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ab_map_hemming_distance_2ways(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=True,sort_reverse=False)

    def ab_map_jaro_2ways(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ab_map_jaro_2ways(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=True,sort_reverse=True)

    def ab_map_jaro_distance_1way(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ab_map_jaro_distance_1way(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=True,sort_reverse=True)

    def ab_map_jaro_winkler_distance_1way(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ab_map_jaro_winkler_distance_1way(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=True,sort_reverse=True)

    def ab_map_jaro_winkler_distance_2ways(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ab_map_jaro_winkler_distance_2ways(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=True,sort_reverse=True)

    def ab_map_levenshtein_distance_1way(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ab_map_levenshtein_distance_1way(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=True,sort_reverse=False)

    def ab_map_levenshtein_distance_2ways(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ab_map_levenshtein_distance_2ways(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=True,sort_reverse=False)

    def ab_map_longest_common_subsequence_v0(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ab_map_longest_common_subsequence_v0(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=True,sort_reverse=True)

    def ab_map_longest_common_substring_v0(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ab_map_longest_common_substring_v0(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=True,sort_reverse=True)

    def ab_map_longest_common_substring_v1(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ab_map_longest_common_substring_v1(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=True,sort_reverse=True)

    def ab_map_subsequence_v1(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ab_map_subsequence_v1(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=True,sort_reverse=True)

    def ab_map_subsequence_v2(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ab_map_subsequence_v2(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=True,sort_reverse=True)

    def ba_map_damerau_levenshtein_distance_1way(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ba_map_damerau_levenshtein_distance_1way(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=False,sort_reverse=False)

    def ba_map_damerau_levenshtein_distance_2ways(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ba_map_damerau_levenshtein_distance_2ways(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=False,sort_reverse=False)

    def ba_map_hemming_distance_1way(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ba_map_hemming_distance_1way(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=False,sort_reverse=False)

    def ba_map_hemming_distance_2ways(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ba_map_hemming_distance_2ways(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=False,sort_reverse=False)

    def ba_map_jaro_2ways(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ba_map_jaro_2ways(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=False,sort_reverse=True)

    def ba_map_jaro_distance_1way(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ba_map_jaro_distance_1way(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=False,sort_reverse=True)

    def ba_map_jaro_winkler_distance_1way(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ba_map_jaro_winkler_distance_1way(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=False,sort_reverse=True)

    def ba_map_jaro_winkler_distance_2ways(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ba_map_jaro_winkler_distance_2ways(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=False,sort_reverse=True)

    def ba_map_levenshtein_distance_1way(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ba_map_levenshtein_distance_1way(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=False,sort_reverse=False)

    def ba_map_levenshtein_distance_2ways(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ba_map_levenshtein_distance_2ways(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=False,sort_reverse=False)

    def ba_map_longest_common_subsequence_v0(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ba_map_longest_common_subsequence_v0(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=False,sort_reverse=True)

    def ba_map_longest_common_substring_v0(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ba_map_longest_common_substring_v0(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=False,sort_reverse=True)

    def ba_map_longest_common_substring_v1(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ba_map_longest_common_substring_v1(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=False,sort_reverse=True)

    def ba_map_subsequence_v1(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ba_map_subsequence_v1(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=False,sort_reverse=True)

    def ba_map_subsequence_v2(self, bint print_cpp=False):
        cdef:
            dict[int64_t,dict[int64_t,tuple[double,int64_t]]] r
        r =self.sm.ba_map_subsequence_v2(print_cpp,False,emptystring)
        return self._filter_results(r=r,ab=False,sort_reverse=True)

    def cpp_data_to_upper(self):
        self.sm.to_upper()
        return self

    def cpp_data_to_lower(self):
        self.sm.to_lower()
        return self

    def cpp_data_to_without_non_alphanumeric(self):
        self.sm.to_without_non_alphanumeric()
        return self

    def cpp_data_to_without_non_printable(self):
        self.sm.to_without_non_printable()
        return self

    def cpp_data_to_100_percent_copy(self):
        self.sm.to_100_percent_copy()
        return self

    def cpp_data_to_without_whitespaces(self):
        self.sm.to_without_whitespaces()
        return self

    def cpp_data_to_with_normalized_whitespaces(self):
        self.sm.to_with_normalized_whitespaces()
        return self



