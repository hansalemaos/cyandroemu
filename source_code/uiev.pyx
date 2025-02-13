cimport cython
cimport numpy as np
from .errorwriter import errwrite
from ast import literal_eval
from io import StringIO,BytesIO
from libc.stdint cimport int64_t,uint8_t
from libcpp.string cimport string,to_string
from libcpp.vector cimport vector
from os import environ as os_environ
from pandas import isna as pdisna
from pandas import read_csv
from pandas.core.base import PandasObject
from pandas.core.frame import DataFrame, Series, Index
from posix.stdio cimport popen, pclose,FILE
from libc.stdio cimport fputc,fclose,fprintf,fopen
from subprocess import Popen as subprocess_Popen
from subprocess import run as subprocess_run
from time import sleep
import numpy as np
import os
import pandas as pd
import requests
import cython
from struct import Struct
import zipfile
from contextlib import suppress as contextlib_suppress
#re.cache_all(True)
import warnings
warnings.simplefilter(action='ignore', category=pd.errors.PerformanceWarning)

#######################################################################################################################################
###################################################### Global vars ####################################################################
ctypedef struct color_rgb_with_coords_and_count:
    Py_ssize_t x
    Py_ssize_t y
    Py_ssize_t count
    uint8_t r
    uint8_t g
    uint8_t b
ctypedef vector[color_rgb_with_coords_and_count] vec_rgbxycount

cdef:
    int SIG_BOOLEAN = ord("Z")
    int SIG_BYTE = ord("B")
    int SIG_SHORT = ord("S")
    int SIG_INT = ord("I")
    int SIG_LONG = ord("J")
    int SIG_FLOAT = ord("F")
    int SIG_DOUBLE = ord("D")
    int SIG_STRING = ord("R")
    int SIG_MAP = ord("M")
    int SIG_END_MAP = 0
    str PYTHON_STRUCT_UNPACK_SIG_BOOLEAN = "?"
    str PYTHON_STRUCT_UNPACK_SIG_BYTE = "b"
    str PYTHON_STRUCT_UNPACK_SIG_SHORT = "h"
    str PYTHON_STRUCT_UNPACK_SIG_INT = "i"
    str PYTHON_STRUCT_UNPACK_SIG_LONG = "q"
    str PYTHON_STRUCT_UNPACK_SIG_FLOAT = "f"
    str PYTHON_STRUCT_UNPACK_SIG_DOUBLE = "d"
    str PYTHON_STRUCT_UNPACK_SIG_STRING = "s"
    str LITTLE_OR_BIG = ">"
    object STRUCT_UNPACK_SIG_BOOLEAN = Struct(
        f"{LITTLE_OR_BIG}{PYTHON_STRUCT_UNPACK_SIG_BOOLEAN}"
    ).unpack
    object STRUCT_UNPACK_SIG_BYTE = Struct(
        f"{LITTLE_OR_BIG}{PYTHON_STRUCT_UNPACK_SIG_BYTE}"
    ).unpack
    object STRUCT_UNPACK_SIG_SHORT = Struct(
        f"{LITTLE_OR_BIG}{PYTHON_STRUCT_UNPACK_SIG_SHORT}"
    ).unpack
    object STRUCT_UNPACK_SIG_INT = Struct(
        f"{LITTLE_OR_BIG}{PYTHON_STRUCT_UNPACK_SIG_INT}"
    ).unpack
    object STRUCT_UNPACK_SIG_LONG = Struct(
        f"{LITTLE_OR_BIG}{PYTHON_STRUCT_UNPACK_SIG_LONG}"
    ).unpack
    object STRUCT_UNPACK_SIG_FLOAT = Struct(
        f"{LITTLE_OR_BIG}{PYTHON_STRUCT_UNPACK_SIG_FLOAT}"
    ).unpack
    object STRUCT_UNPACK_SIG_DOUBLE = Struct(
        f"{LITTLE_OR_BIG}{PYTHON_STRUCT_UNPACK_SIG_DOUBLE}"
    ).unpack
    string cpp_distance_metric=<string>b"Euclidean"
    dict[object,str] cache_tesseract={}
    dict[object,object] cache_apply_literal_eval_to_tuple
    string str_NEWLINE=<string>b"\n"
    int MAX_32BIT_INT_VALUE=2147483647
    string str_REPLACE_XCOORD = <string>b"REPLACE_XCOORD"
    string str_REPLACE_YCOORD = <string>b"REPLACE_YCOORD"
    string str_REPLACE_INPUTDEVICE = <string>b"REPLACE_INPUTDEVICE"
    string str_REPLACE_MAX = <string>b"REPLACE_MAX"
    string str_REPLACE_DISPLAYWIDTH = <string>b"REPLACE_DISPLAYWIDTH"
    string str_REPLACE_DISPLAYHEIGHT = <string>b"REPLACE_DISPLAYHEIGHT"
    string str_SENDEVENTPATH = <string>b"SENDEVENTPATH"
    string write_binary=<string>b"wb"
    string ppm_header=<string>b"P6\n%d %d\n%d\n"
    dict[str,object] std_kwargs_dict = {"shell": True, "env": os_environ, "capture_output": False}
    dict[str,object] std_kwargs_dict_popen = {
    "shell": True,
    "env": os_environ,
    "stdout": -3,
    "stderr": -3,
    "stdin": -1,
    }
    string SHELL_SENDEVENT_ORIGINAL_BEGIN = rb"""SENDEVENTPATH REPLACE_INPUTDEVICE 3 53 $((REPLACE_XCOORD * REPLACE_MAX / REPLACE_DISPLAYWIDTH))"""
    string SHELL_SENDEVENT_ORIGINAL_END = rb"""SENDEVENTPATH REPLACE_INPUTDEVICE 3 54 $((REPLACE_YCOORD * REPLACE_MAX / REPLACE_DISPLAYHEIGHT))
SENDEVENTPATH REPLACE_INPUTDEVICE 0 2 0
SENDEVENTPATH REPLACE_INPUTDEVICE 0 0 0
SENDEVENTPATH REPLACE_INPUTDEVICE 0 2 0
SENDEVENTPATH REPLACE_INPUTDEVICE 0 0 0"""
    string SHELL_SENDEVENT_MOUSE_CLICK_ORIGINAL_BEGIN = rb"""SENDEVENTPATH REPLACE_INPUTDEVICE 3 0 $((REPLACE_XCOORD * REPLACE_MAX / REPLACE_DISPLAYWIDTH))
SENDEVENTPATH REPLACE_INPUTDEVICE 0 0 0
SENDEVENTPATH REPLACE_INPUTDEVICE 3 1 $((REPLACE_YCOORD * REPLACE_MAX / REPLACE_DISPLAYHEIGHT))
SENDEVENTPATH REPLACE_INPUTDEVICE 0 0 0
SENDEVENTPATH REPLACE_INPUTDEVICE 0 2 0
SENDEVENTPATH REPLACE_INPUTDEVICE 0 0 0
SENDEVENTPATH REPLACE_INPUTDEVICE  1 272 1
SENDEVENTPATH REPLACE_INPUTDEVICE 0 0 0"""
    string SHELL_SENDEVENT_MOUSE_CLICK_ORIGINAL_END = rb"""SENDEVENTPATH REPLACE_INPUTDEVICE  1 272 0
SENDEVENTPATH REPLACE_INPUTDEVICE 0 0 0"""

    list[str] columns_fragments = [
    "aa_my_id",
    "aa_my_group_id",
    "aa_my_element_id",
    "aa_my_direct_parent_id",
    "aa_my_parent_ids",
    "aa_original_string",
    "aa_center_x",
    "aa_center_y",
    "aa_area",
    "aa_start_x",
    "aa_start_y",
    "aa_end_x",
    "aa_end_y",
    "aa_height",
    "aa_width",
    "aa_is_sqare",
    "aa_rel_width_height",
    "aa_hashcode_int",
    "aa_mid_int",
    "aa_spaces",
    "aa_classname",
    "aa_element_id",
    "aa_hashcode",
    "aa_mid",
    "aa_start_x_relative",
    "aa_end_x_relative",
    "aa_start_y_relative",
    "aa_end_y_relative",
    "aa_clickable",
    "aa_context_clickable",
    "aa_drawn",
    "aa_enabled",
    "aa_focusable",
    "aa_long_clickable",
    "aa_pflag_activated",
    "aa_pflag_dirty_mask",
    "aa_pflag_focused",
    "aa_pflag_hovered",
    "aa_pflag_invalidated",
    "aa_pflag_is_root_namespace",
    "aa_pflag_prepressed",
    "aa_pflag_selected",
    "aa_scrollbars_horizontal",
    "aa_scrollbars_vertical",
    "aa_visibility",
    ]
    dict[str,object] dtypes_fragments = {
    "aa_my_id": np.dtype("int64"),
    "aa_my_group_id": np.dtype("int64"),
    "aa_my_element_id": np.dtype("int64"),
    "aa_my_direct_parent_id": np.dtype("int64"),
    "aa_my_parent_ids": np.dtype("object"),
    "aa_original_string": np.dtype("object"),
    "aa_center_x": np.dtype("int64"),
    "aa_center_y": np.dtype("int64"),
    "aa_area": np.dtype("int64"),
    "aa_start_x": np.dtype("int64"),
    "aa_start_y": np.dtype("int64"),
    "aa_end_x": np.dtype("int64"),
    "aa_end_y": np.dtype("int64"),
    "aa_height": np.dtype("int64"),
    "aa_width": np.dtype("int64"),
    "aa_is_sqare": np.dtype("int64"),
    "aa_rel_width_height": np.dtype("float64"),
    "aa_hashcode_int": np.dtype("int64"),
    "aa_mid_int": np.dtype("int64"),
    "aa_spaces": np.dtype("int64"),
    "aa_classname": np.dtype("object"),
    "aa_element_id": np.dtype("object"),
    "aa_hashcode": np.dtype("object"),
    "aa_mid": np.dtype("object"),
    "aa_start_x_relative": np.dtype("int64"),
    "aa_end_x_relative": np.dtype("int64"),
    "aa_start_y_relative": np.dtype("int64"),
    "aa_end_y_relative": np.dtype("int64"),
    "aa_clickable": np.dtype("object"),
    "aa_context_clickable": np.dtype("object"),
    "aa_drawn": np.dtype("object"),
    "aa_enabled": np.dtype("object"),
    "aa_focusable": np.dtype("object"),
    "aa_long_clickable": np.dtype("object"),
    "aa_pflag_activated": np.dtype("object"),
    "aa_pflag_dirty_mask": np.dtype("object"),
    "aa_pflag_focused": np.dtype("object"),
    "aa_pflag_hovered": np.dtype("object"),
    "aa_pflag_invalidated": np.dtype("object"),
    "aa_pflag_is_root_namespace": np.dtype("object"),
    "aa_pflag_prepressed": np.dtype("object"),
    "aa_pflag_selected": np.dtype("object"),
    "aa_scrollbars_horizontal": np.dtype("object"),
    "aa_scrollbars_vertical": np.dtype("object"),
    "aa_visibility": np.dtype("object"),
    }
    list[str] columns_ui2 = [
    "aa_index",
    "aa_indent",
    "aa_text",
    "aa_resource_id",
    "aa_clazz",
    "aa_package",
    "aa_content_desc",
    "aa_checkable",
    "aa_checked",
    "aa_clickable",
    "aa_enabled",
    "aa_focusable",
    "aa_focused",
    "aa_scrollable",
    "aa_long_clickable",
    "aa_password",
    "aa_selected",
    "aa_visible_to_user",
    "aa_bounds",
    "aa_drawing_order",
    "aa_hint",
    "aa_display_id",
    "aa_line_index",
    "aa_children",
    "aa_parents",
    "aa_start_x",
    "aa_start_y",
    "aa_end_x",
    "aa_end_y",
    "aa_center_x",
    "aa_center_y",
    "aa_width",
    "aa_height",
    "aa_area",
    "aa_w_h_relation",
    ]

    list[str] columns_lcp = [
    "aa_Text",
    "aa_ContentDescription",
    "aa_StateDescription",
    "aa_ClassName",
    "aa_PackageName",
    "aa_Error",
    "aa_AccessNodeInfo",
    "aa_WindowId",
    "aa_WindowChanges",
    "aa_WindowChangeTypes",
    "aa_VirtualDescendantId",
    "aa_ViewIdResName",
    "aa_UniqueId",
    "aa_TraversalBefore",
    "aa_TraversalAfter",
    "aa_TooltipText",
    "aa_TimeStamp",
    "aa_TimeNow",
    "aa_SpeechStateChangeTypes",
    "aa_SourceWindowId",
    "aa_SourceNodeId",
    "aa_SourceDisplayId",
    "aa_Source",
    "aa_Sealed",
    "aa_Records",
    "aa_ParentNodeId",
    "aa_ParcelableData",
    "aa_MovementGranularities",
    "aa_HashCode",
    "aa_EventType",
    "aa_Actions",
    "aa_ContentChangeTypes",
    "aa_ConnectionId",
    "aa_ChildAccessibilityIds",
    "aa_BooleanProperties",
    "aa_BeforeText",
    "aa_Active",
    "aa_AccessibilityViewId",
    "aa_AccessibilityTool",
    "aa_BoundsInScreen",
    "aa_BoundsInParent",
    "aa_UnixTimeText",
    "aa_start_x_real",
    "aa_start_y_real",
    "aa_end_x_real",
    "aa_end_y_real",
    "aa_start_x",
    "aa_start_y",
    "aa_end_x",
    "aa_end_y",
    "aa_center_x",
    "aa_center_y",
    "aa_width",
    "aa_height",
    "aa_w_h_relation",
    "aa_area",
    "aa_parent_start_x_real",
    "aa_parent_start_y_real",
    "aa_parent_end_x_real",
    "aa_parent_end_y_real",
    "aa_parent_start_x",
    "aa_parent_start_y",
    "aa_parent_end_x",
    "aa_parent_end_y",
    "aa_parent_center_x",
    "aa_parent_center_y",
    "aa_parent_width",
    "aa_parent_height",
    "aa_parent_w_h_relation",
    "aa_parent_area",
    "aa_UnixTime",
    "aa_distance_from_start",
    "aa_size",
    "aa_Visible",
    "aa_Password",
    "aa_Selected",
    "aa_Scrollable",
    "aa_LongClickable",
    "aa_Loggable",
    "aa_IsTextSelectable",
    "aa_ImportantForAccessibility",
    "aa_Enabled",
    "aa_Empty",
    "aa_ContextClickable",
    "aa_ContentInvalid",
    "aa_FullScreen",
    "aa_Focused",
    "aa_Focusable",
    "aa_AccessibilityFocused",
    "aa_AccessibilityDataSensitive",
    "aa_Clickable",
    "aa_Checked",
    "aa_Checkable",
    ]
    list[str] columns_tesseract = [
    "aa_text",
    "aa_title",
    "aa_id",
    "aa_lang",
    "aa_clazz",
    "aa_tag",
    "aa_bbox",
    "aa_baseline",
    "aa_poly",
    "aa_x_bboxes",
    "aa_x_font",
    "aa_x_fsize",
    "aa_x_size",
    "aa_x_ascenders",
    "aa_x_descenders",
    "aa_x_wconf",
    "aa_x_confs",
    "aa_x_mpconf",
    "aa_line_conf",
    "aa_char_conf",
    "aa_ppageno",
    "aa_block_num",
    "aa_par_num",
    "aa_line_num",
    "aa_word_num",
    "aa_image",
    "aa_scan_res",
    "aa_rotate",
    "aa_x_line_bboxes",
    "aa_x_line_confs",
    "aa_x_text",
    "aa_line_index",
    "aa_children",
    "aa_parents",
    "aa_start_x",
    "aa_start_y",
    "aa_end_x",
    "aa_end_y",
    "aa_center_x",
    "aa_center_y",
    "aa_width",
    "aa_height",
    "aa_area",
    "aa_w_h_relation",
    ]
    object asciifunc = np.frompyfunc(ascii, 1, 1)
    object reprfunc = np.frompyfunc(repr, 1, 1)
    str ResetAll = "\033[0m"
    str LightRed = "\033[91m"
    str LightGreen = "\033[92m"
    str LightYellow = "\033[93m"
    str LightBlue = "\033[94m"
    str LightMagenta = "\033[95m"
    str LightCyan = "\033[96m"
    str White = "\033[97m"


#####################################################################################################################################
###################################################### C++ Stuff ####################################################################

cdef extern from "subprocstuff.hpp" nogil :
    void os_system(string &command)

cdef extern from "take_screenshot.hpp" nogil :
    vector[uint8_t] convert_screencap_c(string &cmd, int width, int height)


cdef extern from "cppsleep.hpp" nogil :
    void sleep_milliseconds(int milliseconds)

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

cdef extern from "subtitutestring.hpp" nogil :
    void replace_string_with_another(string &s, string &oldstr, string &newstr, int count)

cdef extern from "newhdbscan.hpp" nogil :
    ctypedef struct resultstruct:
        vector[double] original_data
        int label
        double membership_probability
        double outlier_score
        int outlier_id
    vector[resultstruct] calculate_hdbscan(vector[vector[double]] & dataset, int min_points, int min_cluster_size, string distance_metric)

################################################# START Screenshot ###############################################################

cdef Py_ssize_t calculate_flat_index_f(vector[Py_ssize_t]& nested_index,
vector[Py_ssize_t]& array_shape) noexcept nogil:
    cdef:
        Py_ssize_t wholeindex = nested_index[2]
        Py_ssize_t x,y,tmpda
    for y in range(2):
        tmpda = nested_index[y]
        for x in range(y + 1, 3):
            tmpda = tmpda * array_shape[x]
        wholeindex = wholeindex + tmpda
    return wholeindex


cdef int _get_part_of_image(
    vector[uint8_t]& flat_img,
    uint8_t[:] a4,
    vector[Py_ssize_t]& img_shape,
    Py_ssize_t start_x,
    Py_ssize_t end_x,
    Py_ssize_t start_y,
    Py_ssize_t end_y,
    Py_ssize_t channels,
) noexcept nogil:
    cdef:
        Py_ssize_t a4counter = 0
        Py_ssize_t x,y,z,flatidx
        vector[Py_ssize_t] tmptuple
    tmptuple.resize(3)
    for x in range(start_y, end_y):
        for y in range(start_x, end_x):
            for z in range(channels):
                tmptuple[0]=x
                tmptuple[1]=y
                tmptuple[2]=z
                flatidx = calculate_flat_index_f(tmptuple, img_shape)
                a4[a4counter] = flat_img[flatidx]
                a4counter += 1
    return 0

cdef get_part_of_image(
    vector[uint8_t]& flat_img,
    tuple[Py_ssize_t,Py_ssize_t,Py_ssize_t] img_shape,
    Py_ssize_t start_x,
    Py_ssize_t end_x,
    Py_ssize_t start_y,
    Py_ssize_t end_y,
    Py_ssize_t channels,
):
    cdef:
        np.ndarray a3 = np.zeros((end_y - start_y, end_x - start_x, channels),dtype=np.uint8)
        uint8_t[:] a4 = a3.ravel()
        vector[Py_ssize_t] img_shapevec
    img_shapevec.resize(3)
    img_shapevec[0]=img_shape[0]
    img_shapevec[1]=img_shape[1]
    img_shapevec[2]=img_shape[2]
    _get_part_of_image(
    flat_img=flat_img,
    a4=a4,
    img_shape=img_shapevec,
    start_x=start_x,
    end_x=end_x,
    start_y=start_y,
    end_y=end_y,
    channels=channels,
)
    return a3


cpdef take_screenshot(str cmd, int width, int height):
    cdef:
        vector[uint8_t] result
        string cmd2execute = convert_python_object_to_cpp_string(cmd)
    result=convert_screencap_c(cmd2execute, width, height)
    return result

cdef int convert_coord_to_int(object o):
    if isinstance(o,int):
        return int(o)
    if pdisna(o):
        return -1
    try:
        return int(o)
    except Exception:
        return -1

cdef (int,int,int,int) convert_to_c_tuple(object o, int width, int height):
    cdef:
        (int,int,int,int) result=(-1,-1,-1,-1)
    if len(o)!=4:
        return result
    result[0]=convert_coord_to_int(o[0])
    if result[0] < 0 or result[0] > width:
        return (-1,-1,-1,-1)
    result[1]=convert_coord_to_int(o[1])
    if result[1] < 0 or result[1] > height:
        return (-1,-1,-1,-1)
    result[2]=convert_coord_to_int(o[2])
    if result[2] < 0 or result[2] > width:
        return (-1,-1,-1,-1)
    result[3]=convert_coord_to_int(o[3])
    if result[3] < 0 or result[3] > height:
        return (-1,-1,-1,-1)
    if result[3]<=result[1]:
        return (-1,-1,-1,-1)
    if result[2]<=result[0]:
        return (-1,-1,-1,-1)
    return result

def write_numpy_array_to_ppm_pic(str path, uint8_t[:] flat_pic, int width, int height):
    cdef:
        Py_ssize_t i
        Py_ssize_t len_flat_pic=len(flat_pic)
        string cpp_path = convert_python_object_to_cpp_string(path)
        FILE *f
    f=fopen(cpp_path.c_str(),write_binary.c_str())
    if not f:
        return False
    fprintf(f, ppm_header.c_str(), width, height, 255)
    for i in range(len_flat_pic):
        fputc(flat_pic[i],f)
    fclose(f)
    return True

def get_part_of_screenshot(str cmd, int width, int height, list coords):
    cdef:
        string cmd2execute = convert_python_object_to_cpp_string(cmd)
        vector[uint8_t] flat_img=convert_screencap_c(cmd2execute, width, height)
        dict[object,tuple[int,int,int,int]] lookup_dict1={}
        dict[tuple[int,int,int,int],list] lookup_dict2={}
        dict[tuple[int,int,int,int],object] cropped_numpy_arrays={}
        tuple[Py_ssize_t,Py_ssize_t,Py_ssize_t] img_shape=(height,width,3)
        list[object] resultlist_images = []
        object empty_numpy_array=np.array([],dtype=np.uint8)
        Py_ssize_t coordindex

    for coordindex in range(len(coords)):
        lookup_dict1[coords[coordindex]]= convert_to_c_tuple(coords[coordindex],width,height)
        if lookup_dict1[coords[coordindex]] not in lookup_dict2:
            lookup_dict2[lookup_dict1[coords[coordindex]]]=[]
        lookup_dict2[lookup_dict1[coords[coordindex]]].append(coords[coordindex])

    for key in lookup_dict2:
        if key[0]==-1:
            cropped_numpy_arrays[key]=empty_numpy_array
            continue
        cropped_numpy_arrays[key]=get_part_of_image(
        flat_img=flat_img,
        img_shape=img_shape,
        start_x=key[0],
        end_x=key[2],
        start_y=key[1],
        end_y=key[3],
        channels=3,
    )
    for coordindex in range(len(coords)):
        for key, item in lookup_dict2.items():
            if coords[coordindex] in item:
                resultlist_images.append(cropped_numpy_arrays[key])
    return np.asarray(resultlist_images, dtype="object")


################################################# START Pandas Printer ####################################################################

@cython.nonecheck(True)
def pdp(
    object df,
    Py_ssize_t column_rep=70,
    Py_ssize_t max_lines=0,
    Py_ssize_t max_colwidth=300,
    Py_ssize_t ljust_space=2,
    str sep=" | ",
    bint vtm_escape=True,
):
    cdef:
        dict[Py_ssize_t, np.ndarray] stringdict= {}
        dict[Py_ssize_t, Py_ssize_t] stringlendict= {}
        list[str] df_columns, allcolumns_as_string
        list[str] colors2rotate=[
        LightRed,
        LightGreen,
        LightYellow,
        LightBlue,
        LightMagenta,
        LightCyan,
        White,
        ]
        Py_ssize_t i, len_a, len_df_columns, lenstr, counter, j, len_stringdict0, k, len_stringdict
        str stringtoprint, dashes, dashesrep
        np.ndarray a
    if vtm_escape:
        print('\033[12:2p')
    if len(df) > max_lines and max_lines > 0:
        a = df.iloc[:max_lines].reset_index(drop=False).T.__array__()
    else:
        a = df.iloc[:len(df)].reset_index(drop=False).T.__array__()
    try:
        df_columns = ["iloc"] + [str(x) for x in df.columns]
    except Exception:
        try:
            df_columns = ["iloc",str(df.name)]
        except Exception:
            df_columns = ["iloc",str(0)]
    len_a=len(a)
    for i in range(len_a):
        try:
            stringdict[i] = reprfunc(a[i]).astype("U")
        except Exception:
            stringdict[i] = asciifunc(a[i]).astype("U")
        stringlendict[i] = (stringdict[i].dtype.itemsize // 4) + ljust_space
    for i in range(len_a):
        lenstr = len(df_columns[i])
        if lenstr > stringlendict[i]:
            stringlendict[i] = lenstr + ljust_space
        if max_colwidth > 0:
            if stringlendict[i] > max_colwidth:
                stringlendict[i] = max_colwidth

    allcolumns_as_string = []
    len_df_columns=len(df_columns)
    for i in range(len_df_columns):
        stringtoprint = str(df_columns[i])[: stringlendict[i]].ljust(stringlendict[i])
        allcolumns_as_string.append(stringtoprint)
    allcolumns_as_string_str = sep.join(allcolumns_as_string) + sep
    dashes = "-" * (len(allcolumns_as_string_str) + 2)
    dashesrep = dashes + "\n" + allcolumns_as_string_str + "\n" + dashes
    counter = 0
    len_stringdict0 = len(stringdict[0])
    len_stringdict=len(stringdict)
    for j in range(len_stringdict0):
        if column_rep > 0:
            if counter % column_rep == 0:
                print(dashesrep)
        counter += 1
        for k in range(len_stringdict):
            print((
                colors2rotate[k % len(colors2rotate)] + stringdict[k][j][: stringlendict[k]].replace("\n",
            "\\n").replace("\r", "\\r").ljust(stringlendict[k]) + ResetAll
            ), end=sep)
        print()
    return ""

def print_col_width_len(df):
    try:
        pdp(
            pd.DataFrame(
                [df.shape[0], df.shape[1]], index=["rows", "columns"]
            ).T.rename(
                {0: "DataFrame"},
            ),
        )
    except Exception:
        pdp(
            pd.DataFrame([df.shape[0]], index=["rows"]).T.rename({0: "Series"}),
        )


def pandasprintcolor(self):
    pdp(pd.DataFrame(self.reset_index().__array__(), columns=['index']+[str(x) for x in self.columns],copy=False))
    print_col_width_len(self.__array__())

    return ""


def copy_func(f):
    g = lambda *args: f(*args)
    t = list(filter(lambda prop: not ("__" in prop), dir(f)))
    i = 0
    while i < len(t):
        setattr(g, t[i], getattr(f, t[i]))
        i += 1
    return g


def pandasprintcolor_s(self):
    return pandasprintcolor(self.to_frame())

def pandasindexcolor(self):
    pdp(pd.DataFrame(self.__array__()[: self.print_stop].reshape((-1, 1))))
    return ""


def reset_print_options():
    PandasObject.__str__ = copy_func(PandasObject.old__str__)
    PandasObject.__repr__ = copy_func(PandasObject.old__repr__)
    DataFrame.__repr__ = copy_func(DataFrame.old__repr__)
    DataFrame.__str__ = copy_func(DataFrame.old__str__)
    Series.__repr__ = copy_func(Series.old__repr__)
    Series.__str__ = copy_func(Series.old__str__)
    Index.__repr__ = copy_func(Index.old__repr__)
    Index.__str__ = copy_func(Index.old__str__)


def substitute_print_with_color_print(
    print_stop: int = 69, max_colwidth: int = 300, repeat_cols: int = 70
):
    if not hasattr(pd, "color_printer_active"):
        PandasObject.old__str__ = copy_func(PandasObject.__str__)
        PandasObject.old__repr__ = copy_func(PandasObject.__repr__)
        DataFrame.old__repr__ = copy_func(DataFrame.__repr__)
        DataFrame.old__str__ = copy_func(DataFrame.__str__)
        Series.old__repr__ = copy_func(Series.__repr__)
        Series.old__str__ = copy_func(Series.__str__)
        Index.old__repr__ = copy_func(Index.__repr__)
        Index.old__str__ = copy_func(Index.__str__)

    PandasObject.__str__ = lambda x: pandasprintcolor(x)
    PandasObject.__repr__ = lambda x: pandasprintcolor(x)
    PandasObject.print_stop = print_stop
    PandasObject.max_colwidth = max_colwidth
    PandasObject.repeat_cols = repeat_cols
    DataFrame.__repr__ = lambda x: pandasprintcolor(x)
    DataFrame.__str__ = lambda x: pandasprintcolor(x)
    DataFrame.print_stop = print_stop
    DataFrame.max_colwidth = max_colwidth
    DataFrame.repeat_cols = repeat_cols
    Series.__repr__ = lambda x: pandasprintcolor_s(x)
    Series.__str__ = lambda x: pandasprintcolor_s(x)
    Series.print_stop = print_stop
    Series.max_colwidth = max_colwidth
    Series.repeat_cols = repeat_cols
    Index.__repr__ = lambda x: pandasindexcolor(x)
    Index.__str__ = lambda x: pandasindexcolor(x)
    Index.print_stop = print_stop
    Index.max_colwidth = max_colwidth
    Index.repeat_cols = 10000000
    pd.color_printer_activate = substitute_print_with_color_print
    pd.color_printer_reset = reset_print_options
    pd.color_printer_active = True

def qq_ds_print_nolimit(self, **kwargs):
    try:
        pdp(
            pd.DataFrame(self.reset_index().__array__(), columns=['index']+[str(x) for x in self.columns],copy=False),
            max_lines=0,
            **kwargs,
        )
        print_col_width_len(self.__array__())
    except Exception:
        try:
            pdp(
                pd.DataFrame(self.reset_index().__array__(), columns=['index',self.name],copy=False),
                max_lines=0,
            )
        except Exception:
            pdp(
                pd.DataFrame(self.__array__(),copy=False),
                max_lines=0,
            )
        print_col_width_len(self.__array__())
    return ""


def qq_d_print_columns(self, **kwargs):
    pdp(
        pd.DataFrame(self.columns.__array__().reshape((-1, 1))),
        max_colwidth=0,
        max_lines=0,
        **kwargs,
    )
    return ""


def qq_ds_print_index(self, **kwargs):
    pdp(pd.DataFrame(self.index.__array__().reshape((-1, 1))),    max_lines=0, max_colwidth=0, **kwargs)
    return ""


def add_printer(overwrite_pandas_printer=False):

    PandasObject.ds_color_print_all = qq_ds_print_nolimit
    DataFrame.d_color_print_columns = qq_d_print_columns
    DataFrame.d_color_print_index = qq_ds_print_index
    if overwrite_pandas_printer:
        substitute_print_with_color_print()

################################################# END Pandas Printer ####################################################################

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


cdef int convert_to_int(object o, int nan_val=0):
    if isinstance(o,int):
        return o
    if pdisna(o):
        return nan_val
    try:
        return int(o)
    except Exception:
        return nan_val


cdef class InputClick:
    cdef:
        int x
        int y
        str cmd

    def __init__(self, object x, object y, cmd="/system/bin/input tap"):
        self.x = convert_to_int(x)
        self.y = convert_to_int(y)
        self.cmd = cmd

    def __call__(self, int offset_x=0, int offset_y=0):
        cdef:
            string space_key=<string>b" "
            string string_to_execute
            int int_offset_x=convert_to_int(offset_x)
            int int_offset_y=convert_to_int(offset_y)
            int final_x, final_y
            string cmd=convert_python_object_to_cpp_string(self.cmd)

        string_to_execute.reserve(cmd.size()+12)
        string_to_execute.append(cmd)
        string_to_execute.append(space_key)
        final_x=self.x+int_offset_x
        final_y=self.y+int_offset_y
        string_to_execute.append(to_string(final_x))
        string_to_execute.append(space_key)
        string_to_execute.append(to_string(final_y))
        os_system(string_to_execute)
        return string_to_execute

    def __str__(self):
        return "(offset_x=0, offset_y=0)"

    def __repr__(self):
        return self.__str__()


cdef class SendEventClick:
    cdef:
        int x
        int y
        str inputdev
        int inputdevmax
        int width
        int height
        str sendevent_path
        str shell
        str su
        int click_type
        dict kwargs
        double duration

    def __init__(
        self,
        object x,
        object y,
        str inputdev,
        int inputdevmax,
        int width,
        int height,
        str sendevent_path,
        str shell,
        str su,
        int click_type,
        object kwargs=None
    ):
        self.x = convert_to_int(x)
        self.y = convert_to_int(y)
        self.inputdev = inputdev
        self.inputdevmax = inputdevmax
        self.width = width
        self.height = height
        self.sendevent_path = sendevent_path
        self.shell = shell
        self.su = su
        self.click_type = click_type  # 1 - mouse, 0 - touch
        self.kwargs = kwargs if kwargs else std_kwargs_dict_popen

    def __call__(self, int offset_x=0, int offset_y=0, double duration=0.0, **kwargs):
        cdef:
            string command_start, command_end
            string REPLACE_XCOORD = to_string(self.x  + offset_x)
            string REPLACE_YCOORD = to_string(self.y +  offset_y)
            string REPLACE_INPUTDEVICE=convert_python_object_to_cpp_string(self.inputdev)
            string REPLACE_MAX = to_string(self.inputdevmax)
            string REPLACE_DISPLAYWIDTH = to_string(self.width)
            string REPLACE_DISPLAYHEIGHT = to_string(self.height)
            string SENDEVENTPATH = convert_python_object_to_cpp_string(self.sendevent_path)
            object p
            object pstdin

        command_start = (
            SHELL_SENDEVENT_ORIGINAL_BEGIN
            if self.click_type == 0
            else SHELL_SENDEVENT_MOUSE_CLICK_ORIGINAL_BEGIN
        )
        command_end = (
            SHELL_SENDEVENT_ORIGINAL_END
            if self.click_type == 0
            else SHELL_SENDEVENT_MOUSE_CLICK_ORIGINAL_END
        )
        replace_string_with_another(command_start, str_REPLACE_XCOORD, REPLACE_XCOORD, MAX_32BIT_INT_VALUE)
        replace_string_with_another(command_start, str_REPLACE_YCOORD, REPLACE_YCOORD, MAX_32BIT_INT_VALUE)
        replace_string_with_another(command_start, str_REPLACE_INPUTDEVICE, REPLACE_INPUTDEVICE, MAX_32BIT_INT_VALUE)
        replace_string_with_another(command_start, str_REPLACE_MAX, REPLACE_MAX, MAX_32BIT_INT_VALUE)
        replace_string_with_another(command_start, str_REPLACE_DISPLAYWIDTH, REPLACE_DISPLAYWIDTH, MAX_32BIT_INT_VALUE)
        replace_string_with_another(command_start, str_REPLACE_DISPLAYHEIGHT, REPLACE_DISPLAYHEIGHT, MAX_32BIT_INT_VALUE)
        replace_string_with_another(command_start, str_SENDEVENTPATH, SENDEVENTPATH, MAX_32BIT_INT_VALUE)

        replace_string_with_another(command_end, str_REPLACE_XCOORD, REPLACE_XCOORD, MAX_32BIT_INT_VALUE)
        replace_string_with_another(command_end, str_REPLACE_YCOORD, REPLACE_YCOORD, MAX_32BIT_INT_VALUE)
        replace_string_with_another(command_end, str_REPLACE_INPUTDEVICE, REPLACE_INPUTDEVICE, MAX_32BIT_INT_VALUE)
        replace_string_with_another(command_end, str_REPLACE_MAX, REPLACE_MAX, MAX_32BIT_INT_VALUE)
        replace_string_with_another(command_end, str_REPLACE_DISPLAYWIDTH, REPLACE_DISPLAYWIDTH, MAX_32BIT_INT_VALUE)
        replace_string_with_another(command_end, str_REPLACE_DISPLAYHEIGHT, REPLACE_DISPLAYHEIGHT, MAX_32BIT_INT_VALUE)
        replace_string_with_another(command_end, str_SENDEVENTPATH, SENDEVENTPATH, MAX_32BIT_INT_VALUE)
        command_start.append(str_NEWLINE)
        command_end.append(str_NEWLINE)
        p = subprocess_Popen(
            self.shell,
            **{**self.kwargs, **kwargs},
        )
        pstdin=p.stdin
        pstdin.write((self.su + "\n").encode("utf-8"))
        pstdin.flush()
        pstdin.write(bytes(command_start))
        pstdin.flush()
        if duration>0:
            sleep(duration)
        pstdin.write(bytes(command_end))
        pstdin.flush()
        pstdin.write(b"\nexit\n")
        pstdin.flush()
        pstdin.write(b"\nexit\n")
        pstdin.flush()
        pstdin.close()
        p.wait()

    def __str__(self):
        return "(offset_x=0, offset_y=0, duration=0.0)"

    def __repr__(self):
        return self.__str__()


cdef class MouseAction:
    cdef:
        int x
        int y
        str cmd
        int screen_width
        int screen_height
        str device
        dict kwargs

    def __init__(
        self,
        object x,
        object y,
        object cmd,
        object screen_width,
        object screen_height,
        object device,
        object kwargs=None,
    ):
        self.x = convert_to_int(x)
        self.y = convert_to_int(y)
        self.cmd = cmd
        self.screen_width = screen_width
        self.screen_height = screen_height
        self.device = device
        self.kwargs = kwargs if kwargs else std_kwargs_dict

    def __str__(self):
        return "(offset_x=0, offset_y=0, action=0, event_multiply=1,natural_movement=1,use_every_n_element=10,min_x_variation=0,max_x_variation=0,min_y_variation=0,max_y_variation=0,sleep_time=0,debug=0,print_device_info=0,**kwargs)"

    def __repr__(self):
        return self.__str__()

    def __call__(
        self,
        int offset_x=0,
        int offset_y=0,
        int action=0,
        int event_multiply=1,
        int natural_movement=1,
        int use_every_n_element=10,
        int min_x_variation=0,
        int max_x_variation=0,
        int min_y_variation=0,
        int max_y_variation=0,
        int sleep_time=0,
        int debug=0,
        int print_device_info=0,
        **kwargs,
    ):
        cdef:
            str str_cmd
        str_cmd = " ".join(
            (
                self.cmd,
                "--screen_width=" + str(self.screen_width),
                "--screen_height=" + str(self.screen_height),
                "--device=" + self.device,
                "--x=" + str(int(self.x) + int(offset_x)),
                "--y=" + str(int(self.y) + int(offset_y)),
                "--action=" + str(action),
                "--sleep_time=" + str(sleep_time),
                "--debug=" + str(debug),
                "--event_multiply=" + str(event_multiply),
                "--natural_movement=" + str(natural_movement),
                "--use_every_n_element=" + str(use_every_n_element),
                "--min_x_variation=" + str(min_x_variation),
                "--max_x_variation=" + str(max_x_variation),
                "--min_y_variation=" + str(min_y_variation),
                "--max_y_variation=" + str(max_y_variation),
                "--print_device_info=" + str(print_device_info),
            )
        )
        return subprocess_run(
            str_cmd,
            **{**self.kwargs, **kwargs},
        )



def add_events_to_dataframe(
    object df,
    bint add_input_tap=True,
    bint add_sendevent_mouse_click=True,
    bint add_sendevent_tap=True,
    bint add_mouse_action=True,
    str x_column="aa_center_x",
    str y_column="aa_center_y",
    str mouse_device="/dev/input/event5",
    str touch_device="/dev/input/event4",
    int touch_device_max=32767,
    int mouse_device_max=65535,
    str input_cmd="/system/bin/input tap",
    str sendevent_path="/system/bin/sendevent",
    int screen_height=1280,
    int screen_width=720,
    str mouse_action_exe="/data/data/com.termux/files/usr/bin/mouse_sendevent_android/a.out",
    str sh_exe="sh",
    str su_exe="su",
    object kwargs=None,
):
    if add_input_tap:
        df.loc[:,"aa_input_tap"] = df.apply(
            lambda x: InputClick(x[x_column], x[y_column], input_cmd),
            axis=1,
        )
    if add_sendevent_mouse_click:
        df.loc[:,"aa_sendevent_mouse_click"] = df.apply(
            lambda x: SendEventClick(
                x=x[x_column],
                y=x[y_column],
                inputdev=mouse_device,
                inputdevmax=mouse_device_max,
                width=screen_width,
                height=screen_height,
                sendevent_path=sendevent_path,
                shell=sh_exe,
                su=su_exe,
                click_type=1,
                kwargs=kwargs,
            ),
            axis=1,
        )
    if add_sendevent_tap:
        df.loc[:,"aa_sendevent_tap"] = df.apply(
            lambda x: SendEventClick(
                x=x[x_column],
                y=x[y_column],
                inputdev=touch_device,
                inputdevmax=touch_device_max,
                width=screen_width,
                height=screen_height,
                sendevent_path=sendevent_path,
                shell=sh_exe,
                su=su_exe,
                click_type=0,
                kwargs=kwargs,
            ),
            axis=1,
        )
    if add_mouse_action:
        df.loc[:,"aa_mouse_action"] = df.apply(
            lambda x: MouseAction(
                x=x[x_column],
                y=x[y_column],
                cmd=mouse_action_exe,
                screen_width=screen_width,
                screen_height=screen_height,
                device=mouse_device,
                kwargs=kwargs,
            ),
            axis=1,
        )

cdef object get_fragment_data(
    str android_fragment_parser_exe="/data/data/com.termux/files/usr/bin/android_fragment_parser/a.out",
    int timeout=30,
):
    cdef:
        object dff
    try:
        dff = read_csv(
            StringIO(
                (
                    b"".join(
                        subprocess_run(
                            android_fragment_parser_exe,
                            shell=True,
                            capture_output=True,
                            env=os_environ,
                            timeout=timeout,
                        ).stdout.splitlines(keepends=True)[1:]
                    )
                ).decode("utf-8", "backslashreplace")
            ),
            engine="python",
            on_bad_lines="warn",
            sep=",",
            na_filter=False,
            quoting=1,
            encoding_errors="backslashreplace",
            index_col=False,
            names=columns_fragments,
            dtype=dtypes_fragments,
        ).assign(aa_is_child=False)
        dff.loc[
            (~dff.aa_my_parent_ids.str.endswith(","))
            & (dff.aa_my_parent_ids.str.len() > 0),
            "aa_is_child",
        ] = True
        return dff
    except Exception:
        errwrite()
        return pd.DataFrame()


cdef class FragMentDumper:
    cdef:
        str android_fragment_parser_exe
        int timeout
        bint add_input_tap
        bint add_sendevent_mouse_click
        bint add_sendevent_tap
        bint add_mouse_action
        str x_column
        str y_column
        str mouse_device
        str touch_device
        int touch_device_max
        int mouse_device_max
        str input_cmd
        str sendevent_path
        int screen_height
        int screen_width
        str mouse_action_exe
        str sh_exe
        str su_exe
        object kwargs
    def __init__(
        self,
        str android_fragment_parser_exe="/data/data/com.termux/files/usr/bin/android_fragment_parser/a.out",
        int timeout=30,
        bint add_input_tap=True,
        bint add_sendevent_mouse_click=True,
        bint add_sendevent_tap=True,
        bint add_mouse_action=True,
        str x_column="aa_center_x",
        str y_column="aa_center_y",
        str mouse_device="/dev/input/event5",
        str touch_device="/dev/input/event4",
        int touch_device_max=32767,
        int mouse_device_max=65535,
        str input_cmd="/system/bin/input tap",
        str sendevent_path="/system/bin/sendevent",
        int screen_height=1280,
        int screen_width=720,
        str mouse_action_exe="/data/data/com.termux/files/usr/bin/mouse_sendevent_android/a.out",
        str sh_exe="sh",
        str su_exe="su",
        object kwargs=None,
    ):
        self.sh_exe = sh_exe
        self.su_exe = su_exe
        self.timeout = timeout
        self.add_input_tap = add_input_tap
        self.add_sendevent_mouse_click = add_sendevent_mouse_click
        self.add_sendevent_tap = add_sendevent_tap
        self.add_mouse_action = add_mouse_action
        self.x_column = x_column
        self.y_column = y_column
        self.mouse_device = mouse_device
        self.touch_device = touch_device
        self.touch_device_max = touch_device_max
        self.mouse_device_max = mouse_device_max
        self.input_cmd = input_cmd
        self.sendevent_path = sendevent_path
        self.screen_height = screen_height
        self.screen_width = screen_width
        self.mouse_action_exe = mouse_action_exe
        self.kwargs = kwargs
        self.android_fragment_parser_exe = android_fragment_parser_exe

    def get_df(
        self,
        bint with_screenshot=True,
        object add_input_tap=None,
        object add_sendevent_mouse_click=None,
        object add_sendevent_tap=None,
        object add_mouse_action=None,
        object x_column=None,
        object y_column=None,
        object mouse_device=None,
        object touch_device=None,
        object touch_device_max=None,
        object mouse_device_max=None,
        object input_cmd=None,
        object sendevent_path=None,
        object screen_height=None,
        object screen_width=None,
        object mouse_action_exe=None,
        object sh_exe=None,
        object su_exe=None,
        object kwargs=None,
        object timeout=None,
    ):
        cdef:
            object df
        df = get_fragment_data(
            android_fragment_parser_exe=self.android_fragment_parser_exe,
            timeout=timeout if timeout is not None else self.timeout,
        )
        try:
            add_events_to_dataframe(
                df,
                add_input_tap=add_input_tap
                if add_input_tap is not None
                else self.add_input_tap,
                add_sendevent_mouse_click=add_sendevent_mouse_click
                if add_sendevent_mouse_click is not None
                else self.add_sendevent_mouse_click,
                add_sendevent_tap=add_sendevent_tap
                if add_sendevent_tap is not None
                else self.add_sendevent_tap,
                add_mouse_action=add_mouse_action
                if add_mouse_action is not None
                else self.add_mouse_action,
                x_column=x_column if x_column is not None else self.x_column,
                y_column=y_column if y_column is not None else self.y_column,
                mouse_device=mouse_device
                if mouse_device is not None
                else self.mouse_device,
                touch_device=touch_device
                if touch_device is not None
                else self.touch_device,
                touch_device_max=touch_device_max
                if touch_device_max is not None
                else self.touch_device_max,
                mouse_device_max=mouse_device_max
                if mouse_device_max is not None
                else self.mouse_device_max,
                input_cmd=input_cmd if input_cmd is not None else self.input_cmd,
                sendevent_path=sendevent_path
                if sendevent_path is not None
                else self.sendevent_path,
                screen_height=screen_height
                if screen_height is not None
                else self.screen_height,
                screen_width=screen_width
                if screen_width is not None
                else self.screen_width,
                mouse_action_exe=mouse_action_exe
                if mouse_action_exe is not None
                else self.mouse_action_exe,
                sh_exe=sh_exe if sh_exe is not None else self.sh_exe,
                su_exe=su_exe if su_exe is not None else self.su_exe,
                kwargs=kwargs if kwargs is not None else self.kwargs,
            )
        except Exception:
            errwrite()
        if with_screenshot:
            df.loc[:, "aa_screenshot"] = get_part_of_screenshot(cmd="screencap", width=self.screen_width, height=self.screen_height, coords=list(zip(df["aa_start_x"], df["aa_start_y"], df["aa_end_x"], df["aa_end_y"])))
        return df


cdef class LcpParser:
    cdef:
        CySubProc p
        str cmdline
        int deque_size
        bint add_input_tap
        bint add_sendevent_mouse_click
        bint add_sendevent_tap
        bint add_mouse_action
        str x_column
        str y_column
        str mouse_device
        str touch_device
        int touch_device_max
        int mouse_device_max
        str input_cmd
        str sendevent_path
        int screen_height
        int screen_width
        str mouse_action_exe
        str sh_exe
        str su_exe
        object kwargs
        str system_bin

    def __init__(
        self,
        str cmdline=r"/data/data/com.termux/files/usr/bin/lcp/a.out",
        int deque_size=40960,
        bint add_input_tap=True,
        bint add_sendevent_mouse_click=True,
        bint add_sendevent_tap=True,
        bint add_mouse_action=True,
        str x_column="aa_center_x",
        str y_column="aa_center_y",
        str mouse_device="/dev/input/event5",
        str touch_device="/dev/input/event4",
        int touch_device_max=32767,
        int mouse_device_max=65535,
        str input_cmd="/system/bin/input tap",
        str sendevent_path="/system/bin/sendevent",
        int screen_height=1280,
        int screen_width=720,
        str mouse_action_exe="/data/data/com.termux/files/usr/bin/mouse_sendevent_android/a.out",
        str sh_exe="/bin/sh",
        str su_exe="su",
        object kwargs=None,
        str system_bin="/system/bin/",
        bint print_stdout=False,
        bint print_stderr=False
    ):
        self.cmdline = cmdline
        self.deque_size = deque_size
        self.p = CySubProc(
                shell_command=sh_exe,
                buffer_size=deque_size,
                stdout_max_len=deque_size,
                stderr_max_len=deque_size,
                exit_command=b"exit",
                print_stdout=print_stdout,
                print_stderr=print_stderr,
        )
        self.p.start_shell()
        self.add_input_tap = add_input_tap
        self.add_sendevent_mouse_click = add_sendevent_mouse_click
        self.add_sendevent_tap = add_sendevent_tap
        self.add_mouse_action = add_mouse_action
        self.x_column = x_column
        self.y_column = y_column
        self.mouse_device = mouse_device
        self.touch_device = touch_device
        self.touch_device_max = touch_device_max
        self.mouse_device_max = mouse_device_max
        self.input_cmd = input_cmd
        self.sendevent_path = sendevent_path
        self.screen_height = screen_height
        self.screen_width = screen_width
        self.mouse_action_exe = mouse_action_exe
        self.sh_exe = sh_exe
        self.su_exe = su_exe
        self.kwargs = kwargs
        self.system_bin = system_bin

    def start_server(self):
        self.p.stdin_write(self.cmdline)
        return self

    def stop_server(self):
        cdef:
            bytes sukill,sukill2,killcmd1,killcmd2,killcmd3
            object p
            object pstdin
        sukill = rf"""{self.su_exe} -c 'top -b -n1 | grep -F "stty raw" | grep -v "grep -F" | awk '\''{{print $1}}'\'' | awk '\''{{$1=$1}}1'\'' | awk '\''{{print "kill -9 "$1 }}'\'' | sh'""".encode()
        subprocess_run(
            self.sh_exe,
            input=sukill,
        )
        p = subprocess_Popen(
            self.sh_exe,
            shell=True,
            env=os_environ,
            stdin=-1,
        )
        pstdin=p.stdin
        sukill2 = rf"""{self.su_exe} -c 'top -b -n1 | grep -F " a.out" | grep -v "grep -F" | awk '\''{{print $1}}'\'' | awk '\''{{$1=$1}}1'\'' | awk '\''{{print "kill -9 "$1 }}'\'' | sh'""".encode()
        subprocess_run(
            self.sh_exe,
            input=sukill2,
        )
        sleep_milliseconds(100)
        killcmd1 = r"""top -b -n1 | grep -F "stty raw" | grep -v "grep -F" | awk '{print $1}' | awk '{$1=$1}1' | awk '{print "kill -9 "$1 }' | sh""".encode()
        killcmd2 = rf"""{self.system_bin}top -b -n1 | {self.system_bin}grep -F 'stty raw' | {self.system_bin}grep -v "grep -F" | {self.system_bin}awk '{{system("{self.system_bin}kill -9 "$1)}}'""".encode()
        killcmd3 = rf"""{self.system_bin}top -b -n1 | {self.system_bin}grep -F 'dividers' | {self.system_bin}grep -v "grep -F" | {self.system_bin}awk '{{system("{self.system_bin}kill -9 "$1)}}'""".encode()
        pstdin.write(self.su_exe.encode() + b"\n")
        pstdin.flush()
        sleep_milliseconds(100)
        pstdin.write(killcmd1 + b"\n")
        pstdin.flush()
        sleep_milliseconds(100)
        pstdin.write(killcmd2 + b"\n")
        pstdin.flush()
        sleep_milliseconds(100)
        pstdin.write(killcmd3 + b"\n")
        pstdin.flush()
        pstdin.close()
        p.wait()
        subprocess_run(
            self.sh_exe,
            input=sukill,
        )


    def get_df(
        self,
        bint with_screenshot=True,
        bint drop_duplicates=True,
        object add_input_tap=None,
        object add_sendevent_mouse_click=None,
        object add_sendevent_tap=None,
        object add_mouse_action=None,
        object x_column=None,
        object y_column=None,
        object mouse_device=None,
        object touch_device=None,
        object touch_device_max=None,
        object mouse_device_max=None,
        object input_cmd=None,
        object sendevent_path=None,
        object screen_height=None,
        object screen_width=None,
        object mouse_action_exe=None,
        object sh_exe=None,
        object su_exe=None,
        object kwargs=None,

    ):
        cdef:
            object df
            bytes bytes_stdout = self.p.get_stdout()
        try:
            df = pd.read_csv(
                StringIO(bytes_stdout.strip().decode("utf-8", "backslashreplace")),
                engine="python",
                sep=",",
                index_col=False,
                names=columns_lcp,
                na_filter=False,
                quoting=1,
                encoding_errors="backslashreplace",
                on_bad_lines="warn",
            )
            if drop_duplicates:
                df=df.sort_values(by=["aa_UnixTime"], ascending=False).drop_duplicates(
                subset=[
                    "aa_start_x_real",
                    "aa_start_y_real",
                    "aa_end_x_real",
                    "aa_end_y_real",
                    "aa_start_x",
                    "aa_start_y",
                    "aa_end_x",
                    "aa_end_y",
                    "aa_center_x",
                    "aa_center_y",
                    "aa_width",
                    "aa_height",
                    "aa_w_h_relation",
                    "aa_area",
                ],
                keep="first",
            ).reset_index(drop=True)
        except Exception:
            errwrite()
            return pd.DataFrame()
        try:
            add_events_to_dataframe(
                    df,
                    add_input_tap=add_input_tap
                    if add_input_tap is not None
                    else self.add_input_tap,
                    add_sendevent_mouse_click=add_sendevent_mouse_click
                    if add_sendevent_mouse_click is not None
                    else self.add_sendevent_mouse_click,
                    add_sendevent_tap=add_sendevent_tap
                    if add_sendevent_tap is not None
                    else self.add_sendevent_tap,
                    add_mouse_action=add_mouse_action
                    if add_mouse_action is not None
                    else self.add_mouse_action,
                    x_column=x_column if x_column is not None else self.x_column,
                    y_column=y_column if y_column is not None else self.y_column,
                    mouse_device=mouse_device
                    if mouse_device is not None
                    else self.mouse_device,
                    touch_device=touch_device
                    if touch_device is not None
                    else self.touch_device,
                    touch_device_max=touch_device_max
                    if touch_device_max is not None
                    else self.touch_device_max,
                    mouse_device_max=mouse_device_max
                    if mouse_device_max is not None
                    else self.mouse_device_max,
                    input_cmd=input_cmd if input_cmd is not None else self.input_cmd,
                    sendevent_path=sendevent_path
                    if sendevent_path is not None
                    else self.sendevent_path,
                    screen_height=screen_height
                    if screen_height is not None
                    else self.screen_height,
                    screen_width=screen_width
                    if screen_width is not None
                    else self.screen_width,
                    mouse_action_exe=mouse_action_exe
                    if mouse_action_exe is not None
                    else self.mouse_action_exe,
                    sh_exe=sh_exe if sh_exe is not None else self.sh_exe,
                    su_exe=su_exe if su_exe is not None else self.su_exe,
                    kwargs=kwargs if kwargs is not None else self.kwargs,
                )
        except Exception:
            errwrite()
        if with_screenshot:
            df.loc[:, "aa_screenshot"] = get_part_of_screenshot(cmd="screencap", width=self.screen_width, height=self.screen_height, coords=list(zip(df["aa_start_x"], df["aa_start_y"], df["aa_end_x"], df["aa_end_y"])))
        return df


    def clear_deque(self):
        cdef:
            bytes _ = self.p.get_stdout()
        pass

def apply_literal_eval_to_tuple(object x):
    cdef:
        object result
    if not x:
        return ()
    try:
        if x in cache_apply_literal_eval_to_tuple:
            return cache_apply_literal_eval_to_tuple[x]
    except Exception:
        return ()
    try:
        result=literal_eval(x)
    except Exception:
        result=()
    cache_apply_literal_eval_to_tuple[x]=result
    return result


cdef object get_ui2_data(
    str csv_parser_exe="/data/data/com.termux/files/usr/bin/uiautomator2tocsv/a.out",
    int timeout=30,
):
    cdef:
        object dff
    try:
        dff = read_csv(
            StringIO(
                (
                    b"".join(
                        subprocess_run(
                            csv_parser_exe,
                            shell=False,
                            capture_output=True,
                            env=os_environ,
                            timeout=timeout,
                        ).stdout.splitlines(keepends=True)[1:]
                    )
                ).decode("utf-8", "backslashreplace")
            ),
            engine="python",
            on_bad_lines="warn",
            sep=",",
            na_filter=False,
            quoting=1,
            encoding_errors="backslashreplace",
            index_col=False,
            names=columns_ui2,
        )

        dff.loc[:, "aa_children"] = dff.loc[:, "aa_children"].apply(
            apply_literal_eval_to_tuple
        )
        dff.loc[:, "aa_parents"] = dff.loc[:, "aa_parents"].apply(
            apply_literal_eval_to_tuple
        )
        return dff
    except Exception:
        errwrite()
        return pd.DataFrame()



cdef class UiAutomator2:
    cdef:
        str sh_exe
        str su_exe
        str system_bin
        str download_link1
        str download_link2
        str save_path1
        str save_path2
        str csv_parser_exe
        int timeout
        bint add_input_tap
        bint add_sendevent_mouse_click
        bint add_sendevent_tap
        bint add_mouse_action
        str x_column
        str y_column
        str mouse_device
        str touch_device
        int touch_device_max
        int mouse_device_max
        str input_cmd
        str sendevent_path
        int screen_height
        int screen_width
        str mouse_action_exe
        dict kwargs
        FILE* thread

    def __init__(
        self,
        str sh_exe="/bin/sh",
        str su_exe="su",
        str system_bin="/system/bin/",
        str download_link1="https://github.com/hansalemaos/uiautomator2tocsv/raw/refs/heads/main/app-uiautomator-test.apk",
        str download_link2="https://github.com/hansalemaos/uiautomator2tocsv/raw/refs/heads/main/app-uiautomator.apk",
        str save_path1="/sdcard/app-uiautomator-test.apk",
        str save_path2="/sdcard/app-uiautomator.apk",
        str csv_parser_exe="/data/data/com.termux/files/usr/bin/uiautomator2tocsv/a.out",
        int timeout=30,
        bint add_input_tap=True,
        bint add_sendevent_mouse_click=True,
        bint add_sendevent_tap=True,
        bint add_mouse_action=True,
        str x_column="aa_center_x",
        str y_column="aa_center_y",
        str mouse_device="/dev/input/event5",
        str touch_device="/dev/input/event4",
        int touch_device_max=32767,
        int mouse_device_max=65535,
        str input_cmd="/system/bin/input tap",
        str sendevent_path="/system/bin/sendevent",
        int screen_height=1280,
        int screen_width=720,
        str mouse_action_exe="/data/data/com.termux/files/usr/bin/mouse_sendevent_android/a.out",
        object kwargs=None,
    ):
        self.sh_exe = sh_exe
        self.su_exe = su_exe
        self.download_link1 = download_link1
        self.download_link2 = download_link2
        self.save_path1 = save_path1
        self.save_path2 = save_path2
        self.system_bin = system_bin
        self.thread = NULL
        self.csv_parser_exe = csv_parser_exe
        self.timeout = timeout
        self.add_input_tap = add_input_tap
        self.add_sendevent_mouse_click = add_sendevent_mouse_click
        self.add_sendevent_tap = add_sendevent_tap
        self.add_mouse_action = add_mouse_action
        self.x_column = x_column
        self.y_column = y_column
        self.mouse_device = mouse_device
        self.touch_device = touch_device
        self.touch_device_max = touch_device_max
        self.mouse_device_max = mouse_device_max
        self.input_cmd = input_cmd
        self.sendevent_path = sendevent_path
        self.screen_height = screen_height
        self.screen_width = screen_width
        self.mouse_action_exe = mouse_action_exe
        self.kwargs = {} if not kwargs else kwargs

    def download_apks(self):
        with requests.get(self.download_link1) as r:
            if r.status_code == 200:
                with open(self.save_path1, "wb") as f:
                    f.write(r.content)
            else:
                raise ValueError("Failed to download app-uiautomator-test.apk")
        with requests.get(self.download_link2) as r:
            if r.status_code == 200:
                with open(self.save_path2, "wb") as f:
                    f.write(r.content)
            else:
                raise ValueError("Failed to download app-uiautomator.apk")

    def install_apks(self):
        subprocess_run(
            self.system_bin + "pm install -g " + self.save_path1,
            shell=True,
            env=os_environ,
        )
        subprocess_run(
            self.system_bin + "pm install -g " + self.save_path2,
            shell=True,
            env=os_environ,
        )

    def start_server(self):
        cdef:
            bytes cmd2executepystring=(self.system_bin + "am instrument -w -r -e debug false -e class com.github.uiautomator.stub.Stub com.github.uiautomator.test/androidx.test.runner.AndroidJUnitRunner").encode()
            string cmd2execute = <string>cmd2executepystring
            string read_mode=<string>b"r"
        self.thread = popen(cmd2execute.c_str(), read_mode.c_str())

    def stop_server(self):
        cdef:
            object p
            object pstdin
            bytes cmd2run = ("""SYSTEM_BINtop -b -n1 | SYSTEM_BINgrep -F 'com.github.uiautomator.test/androidx.test.runner.AndroidJUnitRunner' | SYSTEM_BINgrep -v "grep" | SYSTEM_BINawk '{system("SYSTEM_BINkill -9 "$1)}'\n""".replace(
            "SYSTEM_BIN", self.system_bin
        )).encode("utf-8")
        p = subprocess_Popen(
            self.sh_exe,
            **{
                **self.kwargs,
                **dict(
                    stdin=-1,
                    stdout=-3,
                    stderr=-3,
                    env=os_environ,
                    shell=True,
                ),
            },
        )
        pstdin=p.stdin
        pstdin.write(self.su_exe.encode("utf-8") + b"\n")
        pstdin.flush()
        pstdin.write(cmd2run)
        pstdin.flush()
        pstdin.write(b"\nexit\n")
        pstdin.flush()
        pstdin.write(b"\nexit\n")
        pstdin.flush()
        pstdin.close()
        p.wait()
        if (self.thread):
            pclose(self.thread)

    def get_df(
        self,
        bint with_screenshot=True,
        object add_input_tap=None,
        object add_sendevent_mouse_click=None,
        object add_sendevent_tap=None,
        object add_mouse_action=None,
        object x_column=None,
        object y_column=None,
        object mouse_device=None,
        object touch_device=None,
        object touch_device_max=None,
        object mouse_device_max=None,
        object input_cmd=None,
        object sendevent_path=None,
        object screen_height=None,
        object screen_width=None,
        object mouse_action_exe=None,
        object sh_exe=None,
        object su_exe=None,
        object kwargs=None,
        object timeout=None,
    ):
        cdef:
            object df
        df = get_ui2_data(
            csv_parser_exe=self.csv_parser_exe,
            timeout=timeout if timeout is not None else self.timeout,
        )
        if df.empty:
            return df
        try:
            add_events_to_dataframe(
            df,
            add_input_tap=add_input_tap
            if add_input_tap is not None
            else self.add_input_tap,
            add_sendevent_mouse_click=add_sendevent_mouse_click
            if add_sendevent_mouse_click is not None
            else self.add_sendevent_mouse_click,
            add_sendevent_tap=add_sendevent_tap
            if add_sendevent_tap is not None
            else self.add_sendevent_tap,
            add_mouse_action=add_mouse_action
            if add_mouse_action is not None
            else self.add_mouse_action,
            x_column=x_column if x_column is not None else self.x_column,
            y_column=y_column if y_column is not None else self.y_column,
            mouse_device=mouse_device
            if mouse_device is not None
            else self.mouse_device,
            touch_device=touch_device
            if touch_device is not None
            else self.touch_device,
            touch_device_max=touch_device_max
            if touch_device_max is not None
            else self.touch_device_max,
            mouse_device_max=mouse_device_max
            if mouse_device_max is not None
            else self.mouse_device_max,
            input_cmd=input_cmd if input_cmd is not None else self.input_cmd,
            sendevent_path=sendevent_path
            if sendevent_path is not None
            else self.sendevent_path,
            screen_height=screen_height
            if screen_height is not None
            else self.screen_height,
            screen_width=screen_width
            if screen_width is not None
            else self.screen_width,
            mouse_action_exe=mouse_action_exe
            if mouse_action_exe is not None
            else self.mouse_action_exe,
            sh_exe=sh_exe if sh_exe is not None else self.sh_exe,
            su_exe=su_exe if su_exe is not None else self.su_exe,
            kwargs=kwargs if kwargs is not None else self.kwargs,
        )
        except Exception:
            errwrite()
        if with_screenshot:
            df.loc[:, "aa_screenshot"] = get_part_of_screenshot(cmd="screencap", width=self.screen_width, height=self.screen_height, coords=list(zip(df["aa_start_x"], df["aa_start_y"], df["aa_end_x"], df["aa_end_y"])))
        return df

cdef str _tesseract_command_builder(
    object exe_path=None,
    object width=None,
    object height=None,
    object tessdata=None,
    object path_screencap=None,
    object path_outpic=None,
    object path_outpic_filtered=None,
    object path_outhorc=None,
    object path_exe_tesseract=None,
    object path_exe_imagemagick=None,
    object tesseract_args=None,
    object imagemagick_args=None,
    object delete_outpic=None,
    object delete_outpic_filtered=None,
    object delete_outhorc=None,
):
    cdef:
        object my_args=(exe_path,width,height,tessdata,path_screencap,
        path_outpic,path_outpic_filtered,path_outhorc,path_exe_tesseract,
        path_exe_imagemagick,tesseract_args,imagemagick_args,delete_outpic,
        delete_outpic_filtered,delete_outhorc)
        list[str] all_args
        str return_cmd
    if my_args in cache_tesseract:
        return cache_tesseract[my_args]

    all_args = []
    if exe_path is not None:
        all_args.append(exe_path)
    if width is not None:
        all_args.append(f"--width={width}")
    if height is not None:
        all_args.append(f"--height={height}")
    if tessdata is not None:
        all_args.append(f"--tessdata={tessdata}")
    if path_screencap is not None:
        all_args.append(f"--path_screencap={path_screencap}")
    if path_outpic is not None:
        all_args.append(f"--path_outpic={path_outpic}")
    if path_outpic_filtered is not None:
        all_args.append(f"--path_outpic_filtered={path_outpic_filtered}")
    if path_outhorc is not None:
        all_args.append(f"--path_outhorc={path_outhorc}")
    if path_exe_tesseract is not None:
        all_args.append(f"--path_exe_tesseract={path_exe_tesseract}")
    if path_exe_imagemagick is not None:
        all_args.append(f"--path_exe_imagemagick={path_exe_imagemagick}")
    if tesseract_args is not None:
        all_args.append(f"--tesseract_args={tesseract_args}")
    if imagemagick_args is not None:
        all_args.append(f"--imagemagick_args={imagemagick_args}")
    if delete_outpic is not None:
        all_args.append(f"--delete_outpic={delete_outpic}")
    if delete_outpic_filtered is not None:
        all_args.append(f"--delete_outpic_filtered={delete_outpic_filtered}")
    if delete_outhorc is not None:
        all_args.append(f"--delete_outhorc={delete_outhorc}")
    return_cmd=" ".join(all_args)
    cache_tesseract[my_args]=return_cmd
    return return_cmd

cdef bint check_vec_equal(vector[Py_ssize_t]& v1,vector[Py_ssize_t]& v2):
    cdef:
        Py_ssize_t i
    if v1.size()!=v2.size():
        return False
    for i in range(v1.size()):
        if v1[i]!=v2[i]:
            return False
    return True

cdef list[list[Py_ssize_t]] _tesser_group_words(
    object df,
    Py_ssize_t limit_x,
    object col_start_x="aa_start_x",
    object col_end_x="aa_end_x",
    object col_start_y="aa_start_y",
    object col_end_y="aa_end_y",
):
    cdef:
        np.ndarray a_start_x_full = df[col_start_x].astype(np.int64).__array__() - limit_x
        np.ndarray a_start_y_full = df[col_start_y].astype(np.int64).__array__()
        np.ndarray a_end_x_full = df[col_end_x].astype(np.int64).__array__() + limit_x
        np.ndarray a_end_y_full = df[col_end_y].astype(np.int64).__array__()
        int64_t[:] a_start_x=a_start_x_full
        int64_t[:] a_start_y=a_start_y_full
        int64_t[:] a_end_x=a_end_x_full
        int64_t[:] a_end_y=a_end_y_full
        Py_ssize_t len_startx = a_start_x.shape[0]
        Py_ssize_t i,j,k, inters,inter
        vector[vector[Py_ssize_t]] intersecting
        bint invector
        vector[Py_ssize_t] last_values_size, now_value_size
        dict[Py_ssize_t,set[Py_ssize_t]] intersecting_dict = {}
        list[list[Py_ssize_t]] groups = []
        list[Py_ssize_t] h

    intersecting.reserve(len_startx)
    for i in range(len_startx):
        intersecting.emplace_back()
        for j in range(len_startx):
            if not (
                a_end_x[i] < a_start_x[j]
                or a_start_x[i] > a_end_x[j]
                or a_end_y[i] < a_start_y[j]
                or a_start_y[i] > a_end_y[j]
            ):
                if intersecting[intersecting.size() - 1].empty():
                    intersecting[intersecting.size() - 1].emplace_back(j)
                    continue
                invector=False
                for k in range(intersecting[intersecting.size() - 1].size()):
                    if intersecting[intersecting.size() - 1][k]==j:
                        invector=True
                        break
                if not invector:
                    intersecting[intersecting.size() - 1].emplace_back(j)


    for inters in range(intersecting.size()):
        for inter in range(intersecting[inters].size()):
            if intersecting[inters][inter] not in intersecting_dict:
                intersecting_dict[intersecting[inters][inter]] = set()
            intersecting_dict[intersecting[inters][inter]].update((intersecting[inters]))

    for item in intersecting_dict.values():
        now_value_size.emplace_back(len(item))
    while check_vec_equal(last_values_size,now_value_size):
        last_values_size.clear()
        for j in range(now_value_size.size()):
            last_values_size.emplace_back(now_value_size[j])
        now_value_size.clear()
        for key in intersecting_dict:
            for key2 in intersecting_dict[key]:
                intersecting_dict[key2].update(intersecting_dict[key])

        for item in intersecting_dict.values():
            now_value_size.emplace_back(len(item))

    for value in intersecting_dict.values():
        h=sorted(value)
        if h not in groups:
            groups.append(h)
    return groups

cdef object tesser_group_words(
    object df,
    Py_ssize_t limit_x = 20,
    object col_start_x = "aa_start_x",
    object col_end_x = "aa_end_x",
    object col_start_y = "aa_start_y",
    object col_end_y = "aa_end_y",
    object col_text = "aa_text",
):
    cdef:
        object df2
        list[list[Py_ssize_t]] iloc_groups
        list[list[Py_ssize_t]] loc_groups = []
        list[str] text_data = []
        Py_ssize_t linecounter,group,text_iloc,item

    df2 = df.loc[
        (df[col_text] != "")
        & (~df[col_start_x].isna())
        & (~df[col_end_x].isna())
        & (~df[col_start_y].isna())
        & (~df[col_end_y].isna())
    ]
    iloc_groups = _tesser_group_words(
        df=df2,
        limit_x=limit_x,
        col_start_x=col_start_x,
        col_end_x=col_end_x,
        col_start_y=col_start_y,
        col_end_y=col_end_y,
    )
    text_iloc = df2.columns.to_list().index("aa_text")
    df.insert(0, column="aa_text_group", value=-1)
    df.insert(0, column="aa_text_line", value="")
    linecounter = 0
    for group in range(len(iloc_groups)):
        loc_groups.append([])
        for item in range(len(iloc_groups[group])):
            loc_groups[len(loc_groups) - 1].append(df2.index[iloc_groups[group][item]])
            text_data.append(df2.iat[iloc_groups[group][item], text_iloc])
        df.loc[loc_groups[len(loc_groups) - 1], "aa_text_line"] = " ".join(text_data)
        df.loc[loc_groups[len(loc_groups) - 1], "aa_text_group"] = linecounter
        linecounter += 1
        text_data.clear()
    df.rename(columns={"aa_text": "aa_word"}, inplace=True)
    return df.rename(columns={"aa_text_line": "aa_text"}, inplace=False)

cdef class Screencap2Tesseract:
    cdef:
        str exe_path
        int timeout
        bint add_input_tap
        bint add_sendevent_mouse_click
        bint add_sendevent_tap
        bint add_mouse_action
        str x_column
        str y_column
        str mouse_device
        str touch_device
        int touch_device_max
        int mouse_device_max
        str input_cmd
        str sendevent_path
        int screen_height
        int screen_width
        str mouse_action_exe
        str sh_exe
        str su_exe
        dict kwargs
        str system_bin
        str tessdata
        str path_screencap
        str path_exe_tesseract
        str path_exe_imagemagick
        str tesseract_args
        object imagemagick_args
        str path_outpic
    def __init__(
        self,
        str exe_path="/data/data/com.termux/files/usr/bin/hocr2csv/a.out",
        int timeout=30,
        bint add_input_tap=True,
        bint add_sendevent_mouse_click=True,
        bint add_sendevent_tap=True,
        bint add_mouse_action=True,
        str x_column="aa_center_x",
        str y_column="aa_center_y",
        str mouse_device="/dev/input/event5",
        str touch_device="/dev/input/event4",
        int touch_device_max=32767,
        int mouse_device_max=65535,
        str input_cmd="/system/bin/input tap",
        str sendevent_path="/system/bin/sendevent",
        int screen_height=768,
        int screen_width=1024,
        str mouse_action_exe="/data/data/com.termux/files/usr/bin/mouse_sendevent_android/a.out",
        str sh_exe="sh",
        str su_exe="su",
        object kwargs=None,
        str system_bin="/system/bin/",
        str tessdata="/data/data/com.termux/files/home/tessdata_fast",
        str path_screencap="screencap",
        str path_exe_tesseract="/data/data/com.termux/files/usr/bin/tesseract",
        str path_exe_imagemagick="/data/data/com.termux/files/usr/bin/magick",
        str tesseract_args='"-l por+eng --oem 3"',
        object imagemagick_args=None,
        str path_outpic="/sdcard/screenshot.ppm"
    ):
        self.exe_path = exe_path
        self.timeout = timeout
        self.add_input_tap = add_input_tap
        self.add_sendevent_mouse_click = add_sendevent_mouse_click
        self.add_sendevent_tap = add_sendevent_tap
        self.add_mouse_action = add_mouse_action
        self.x_column = x_column
        self.y_column = y_column
        self.mouse_device = mouse_device
        self.touch_device = touch_device
        self.touch_device_max = touch_device_max
        self.mouse_device_max = mouse_device_max
        self.input_cmd = input_cmd
        self.sendevent_path = sendevent_path
        self.screen_height = screen_height
        self.screen_width = screen_width
        self.mouse_action_exe = mouse_action_exe
        self.sh_exe = sh_exe
        self.su_exe = su_exe
        self.kwargs = kwargs if kwargs else {}
        self.system_bin = system_bin
        self.tessdata = tessdata
        self.path_screencap = path_screencap
        self.path_exe_tesseract = path_exe_tesseract
        self.path_exe_imagemagick = path_exe_imagemagick
        self.tesseract_args = tesseract_args
        self.imagemagick_args = imagemagick_args
        self.path_outpic=path_outpic

    def get_df(
        self,
        bint with_screenshot=True,
        Py_ssize_t word_group_limit=20,
        object add_input_tap=None,
        object add_sendevent_mouse_click=None,
        object add_sendevent_tap=None,
        object add_mouse_action=None,
        object x_column=None,
        object y_column=None,
        object mouse_device=None,
        object touch_device=None,
        object touch_device_max=None,
        object mouse_device_max=None,
        object input_cmd=None,
        object sendevent_path=None,
        object screen_height=None,
        object screen_width=None,
        object mouse_action_exe=None,
        object sh_exe=None,
        object su_exe=None,
        object kwargs=None,
        object timeout=None,
        object tessdata=None,
        object tesseract_args=None,
        object imagemagick_args=None,
        object path_outpic=None,
    ):
        cdef:
            str tesseract_cmd
            object df
        tesseract_cmd = _tesseract_command_builder(
            exe_path=self.exe_path,
            width=self.screen_width,
            height=self.screen_height,
            tessdata=tessdata if tessdata is not None else self.tessdata,
            path_screencap=self.path_screencap,
            path_outpic=path_outpic if path_outpic is not None else self.path_outpic,
            path_outpic_filtered=None,
            path_outhorc=None,
            path_exe_tesseract=self.path_exe_tesseract,
            path_exe_imagemagick=self.path_exe_imagemagick,
            tesseract_args=tesseract_args if tesseract_args is not None else self.tesseract_args,
            imagemagick_args=imagemagick_args if imagemagick_args is not None else self.imagemagick_args,
            delete_outpic=None,
            delete_outpic_filtered=None,
            delete_outhorc=None,
        )
        try:
            df = read_csv(
            StringIO(
                (
                    b"\n".join(
                        (
                            subprocess_run(
                                tesseract_cmd,
                                shell=True,
                                capture_output=True,
                                env=os_environ,
                                timeout=timeout
                                if timeout is not None
                                else self.timeout,
                            )
                        ).stdout.splitlines()[1:]
                    )
                ).decode("utf-8", "backslashreplace")
            ),
            engine="python",
            on_bad_lines="warn",
            sep=",",
            na_filter=False,
            quoting=1,
            encoding_errors="backslashreplace",
            index_col=False,
            names=columns_tesseract,
        )
        except Exception:
            errwrite()
            return pd.DataFrame()
        df=tesser_group_words(
            df=df,
            limit_x = word_group_limit,
            col_start_x = "aa_start_x",
            col_end_x = "aa_end_x",
            col_start_y = "aa_start_y",
            col_end_y = "aa_end_y",
            col_text = "aa_text",
        )
        try:
            if "aa_children" in df.columns:
                df.loc[:, "aa_children"] = df.loc[:, "aa_children"].apply(
                apply_literal_eval_to_tuple
                )
            if "aa_parents" in df.columns:
                df.loc[:, "aa_parents"] = df.loc[:, "aa_parents"].apply(
                apply_literal_eval_to_tuple
                )
            add_events_to_dataframe(
            df,
            add_input_tap=add_input_tap
            if add_input_tap is not None
            else self.add_input_tap,
            add_sendevent_mouse_click=add_sendevent_mouse_click
            if add_sendevent_mouse_click is not None
            else self.add_sendevent_mouse_click,
            add_sendevent_tap=add_sendevent_tap
            if add_sendevent_tap is not None
            else self.add_sendevent_tap,
            add_mouse_action=add_mouse_action
            if add_mouse_action is not None
            else self.add_mouse_action,
            x_column=x_column if x_column is not None else self.x_column,
            y_column=y_column if y_column is not None else self.y_column,
            mouse_device=mouse_device
            if mouse_device is not None
            else self.mouse_device,
            touch_device=touch_device
            if touch_device is not None
            else self.touch_device,
            touch_device_max=touch_device_max
            if touch_device_max is not None
            else self.touch_device_max,
            mouse_device_max=mouse_device_max
            if mouse_device_max is not None
            else self.mouse_device_max,
            input_cmd=input_cmd if input_cmd is not None else self.input_cmd,
            sendevent_path=sendevent_path
            if sendevent_path is not None
            else self.sendevent_path,
            screen_height=screen_height
            if screen_height is not None
            else self.screen_height,
            screen_width=screen_width
            if screen_width is not None
            else self.screen_width,
            mouse_action_exe=mouse_action_exe
            if mouse_action_exe is not None
            else self.mouse_action_exe,
            sh_exe=sh_exe if sh_exe is not None else self.sh_exe,
            su_exe=su_exe if su_exe is not None else self.su_exe,
            kwargs=kwargs if kwargs is not None else self.kwargs,
            )
        except Exception:
            errwrite()
        if with_screenshot:
            df.loc[:, "aa_screenshot"] = get_part_of_screenshot(cmd="screencap", width=self.screen_width, height=self.screen_height, coords=list(zip(df["aa_start_x"], df["aa_start_y"], df["aa_end_x"], df["aa_end_y"])))
        return df

cdef class UiAutomatorClassic:
    cdef:
        str uiautomator_parser
        int timeout
        bint add_input_tap
        bint add_sendevent_mouse_click
        bint add_sendevent_tap
        bint add_mouse_action
        str x_column
        str y_column
        str mouse_device
        str touch_device
        int touch_device_max
        int mouse_device_max
        str input_cmd
        str sendevent_path
        int screen_height
        int screen_width
        str mouse_action_exe
        str sh_exe
        str su_exe
        dict kwargs
        str system_bin
        str dump_path
    def __init__(
        self,
        str uiautomator_parser="/data/data/com.termux/files/usr/bin/uiautomator_dump_to_csv/a.out",
        int timeout=30,
        bint add_input_tap=True,
        bint add_sendevent_mouse_click=True,
        bint add_sendevent_tap=True,
        bint add_mouse_action=True,
        str x_column="aa_center_x",
        str y_column="aa_center_y",
        str mouse_device="/dev/input/event5",
        str touch_device="/dev/input/event4",
        int touch_device_max=32767,
        int mouse_device_max=65535,
        str input_cmd="/system/bin/input tap",
        str sendevent_path="/system/bin/sendevent",
        int screen_height=768,
        int screen_width=1024,
        str mouse_action_exe="/data/data/com.termux/files/usr/bin/mouse_sendevent_android/a.out",
        str sh_exe="sh",
        str su_exe="su",
        object kwargs=None,
        str system_bin="/system/bin/",
        str dump_path="/sdcard/window_dump.xml",
    ):
        self.uiautomator_parser = uiautomator_parser
        self.timeout = timeout
        self.add_input_tap = add_input_tap
        self.add_sendevent_mouse_click = add_sendevent_mouse_click
        self.add_sendevent_tap = add_sendevent_tap
        self.add_mouse_action = add_mouse_action
        self.x_column = x_column
        self.y_column = y_column
        self.mouse_device = mouse_device
        self.touch_device = touch_device
        self.touch_device_max = touch_device_max
        self.mouse_device_max = mouse_device_max
        self.input_cmd = input_cmd
        self.sendevent_path = sendevent_path
        self.screen_height = screen_height
        self.screen_width = screen_width
        self.mouse_action_exe = mouse_action_exe
        self.sh_exe = sh_exe
        self.su_exe = su_exe
        self.kwargs = kwargs if kwargs else {}
        self.system_bin = system_bin
        self.dump_path = dump_path

    def get_df(
        self,
        bint with_screenshot=True,
        object add_input_tap=None,
        object add_sendevent_mouse_click=None,
        object add_sendevent_tap=None,
        object add_mouse_action=None,
        object x_column=None,
        object y_column=None,
        object mouse_device=None,
        object touch_device=None,
        object touch_device_max=None,
        object mouse_device_max=None,
        object input_cmd=None,
        object sendevent_path=None,
        object screen_height=None,
        object screen_width=None,
        object mouse_action_exe=None,
        object sh_exe=None,
        object su_exe=None,
        object kwargs=None,
        object dump_path=None,
        object timeout=None,
    ):
        cdef:
            object p, df
        try:
            subprocess_run(
                rf"{self.system_bin}rm -f {dump_path};{self.system_bin}uiautomator dump {dump_path}",
                shell=True,
                env=os_environ,
                timeout=timeout,
            )
            p = subprocess_run(
                rf"{self.uiautomator_parser} {dump_path}",
                shell=True,
                env=os_environ,
                timeout=timeout,
                capture_output=True,
            )
            df = read_csv(
                StringIO(p.stdout.decode("utf-8")),
                engine="python",
                on_bad_lines="warn",
                encoding="utf-8",
                sep=",",
                quoting=1,
                na_filter=False,
                encoding_errors="backslashreplace",
                index_col=False,
                header=0,
            )
        except Exception:
            errwrite()
            return pd.DataFrame()
        try:
            add_events_to_dataframe(
            df,
            add_input_tap=add_input_tap
            if add_input_tap is not None
            else self.add_input_tap,
            add_sendevent_mouse_click=add_sendevent_mouse_click
            if add_sendevent_mouse_click is not None
            else self.add_sendevent_mouse_click,
            add_sendevent_tap=add_sendevent_tap
            if add_sendevent_tap is not None
            else self.add_sendevent_tap,
            add_mouse_action=add_mouse_action
            if add_mouse_action is not None
            else self.add_mouse_action,
            x_column=x_column if x_column is not None else self.x_column,
            y_column=y_column if y_column is not None else self.y_column,
            mouse_device=mouse_device
            if mouse_device is not None
            else self.mouse_device,
            touch_device=touch_device
            if touch_device is not None
            else self.touch_device,
            touch_device_max=touch_device_max
            if touch_device_max is not None
            else self.touch_device_max,
            mouse_device_max=mouse_device_max
            if mouse_device_max is not None
            else self.mouse_device_max,
            input_cmd=input_cmd if input_cmd is not None else self.input_cmd,
            sendevent_path=sendevent_path
            if sendevent_path is not None
            else self.sendevent_path,
            screen_height=screen_height
            if screen_height is not None
            else self.screen_height,
            screen_width=screen_width
            if screen_width is not None
            else self.screen_width,
            mouse_action_exe=mouse_action_exe
            if mouse_action_exe is not None
            else self.mouse_action_exe,
            sh_exe=sh_exe if sh_exe is not None else self.sh_exe,
            su_exe=su_exe if su_exe is not None else self.su_exe,
            kwargs=kwargs if kwargs is not None else self.kwargs,
        )
        except Exception:
            errwrite()
        if with_screenshot:
            df.loc[:, "aa_screenshot"] = get_part_of_screenshot(cmd="screencap", width=self.screen_width, height=self.screen_height, coords=list(zip(df["aa_start_x"], df["aa_start_y"], df["aa_end_x"], df["aa_end_y"])))
        return df

cdef class UiAutomatorClassicWithCPULimit:
    cdef:
        int cpu_limit
        str uiautomator_parser
        int timeout
        bint add_input_tap
        bint add_sendevent_mouse_click
        bint add_sendevent_tap
        bint add_mouse_action
        str x_column
        str y_column
        str mouse_device
        str touch_device
        int touch_device_max
        int mouse_device_max
        str input_cmd
        str sendevent_path
        int screen_height
        int screen_width
        str mouse_action_exe
        str sh_exe
        str su_exe
        dict kwargs
        str system_bin
        str dump_path
    def __init__(
        self,
        int cpu_limit=5,
        str uiautomator_parser="/data/data/com.termux/files/usr/bin/uiautomator_dump_without_could_not_detect_idle_state/a.out",
        int timeout=30,
        bint add_input_tap=True,
        bint add_sendevent_mouse_click=True,
        bint add_sendevent_tap=True,
        bint add_mouse_action=True,
        str x_column="aa_center_x",
        str y_column="aa_center_y",
        str mouse_device="/dev/input/event5",
        str touch_device="/dev/input/event4",
        int touch_device_max=32767,
        int mouse_device_max=65535,
        str input_cmd="/system/bin/input tap",
        str sendevent_path="/system/bin/sendevent",
        int screen_height=1280,
        int screen_width=720,
        str mouse_action_exe="/data/data/com.termux/files/usr/bin/mouse_sendevent_android/a.out",
        str sh_exe="sh",
        str su_exe="su",
        object kwargs=None,
        str system_bin="/system/bin/",
        str dump_path="/sdcard/window_dump.xml",
    ):
        self.uiautomator_parser = uiautomator_parser
        self.timeout = timeout
        self.add_input_tap = add_input_tap
        self.add_sendevent_mouse_click = add_sendevent_mouse_click
        self.add_sendevent_tap = add_sendevent_tap
        self.add_mouse_action = add_mouse_action
        self.x_column = x_column
        self.y_column = y_column
        self.mouse_device = mouse_device
        self.touch_device = touch_device
        self.touch_device_max = touch_device_max
        self.mouse_device_max = mouse_device_max
        self.input_cmd = input_cmd
        self.sendevent_path = sendevent_path
        self.screen_height = screen_height
        self.screen_width = screen_width
        self.mouse_action_exe = mouse_action_exe
        self.sh_exe = sh_exe
        self.su_exe = su_exe
        self.kwargs = kwargs if kwargs else {}
        self.system_bin = system_bin
        self.dump_path = dump_path
        self.cpu_limit = cpu_limit

    def get_df(
        self,
        bint with_screenshot=True,
        object cpu_limit=None,
        object add_input_tap=None,
        object add_sendevent_mouse_click=None,
        object add_sendevent_tap=None,
        object add_mouse_action=None,
        object x_column=None,
        object y_column=None,
        object mouse_device=None,
        object touch_device=None,
        object touch_device_max=None,
        object mouse_device_max=None,
        object input_cmd=None,
        object sendevent_path=None,
        object screen_height=None,
        object screen_width=None,
        object mouse_action_exe=None,
        object sh_exe=None,
        object su_exe=None,
        object kwargs=None,
        object timeout=None,
    ):
        cdef:
            object p,df
            str string_to_parse
            list[str] splitted_lines
        try:
            p = subprocess_run(
                rf"{self.uiautomator_parser} {cpu_limit if cpu_limit is not None else self.cpu_limit}",
                shell=True,
                env=os_environ,
                timeout=timeout if timeout is not None else self.timeout,
                capture_output=True,
            )
            string_to_parse=p.stdout.decode("utf-8")
            splitted_lines=string_to_parse.strip().splitlines()
            if len(splitted_lines)>0:
                string_to_parse=('\n'.join(splitted_lines[1:])).strip()
            df = read_csv(
                StringIO(string_to_parse),
                engine="python",
                on_bad_lines="warn",
                encoding="utf-8",
                sep=",",
                quoting=1,
                encoding_errors="backslashreplace",
                index_col=False,
                na_filter=False,
                header=0,
            )
        except Exception:
            errwrite()
            return pd.DataFrame()

        try:
            add_events_to_dataframe(
                df,
                add_input_tap=add_input_tap
                if add_input_tap is not None
                else self.add_input_tap,
                add_sendevent_mouse_click=add_sendevent_mouse_click
                if add_sendevent_mouse_click is not None
                else self.add_sendevent_mouse_click,
                add_sendevent_tap=add_sendevent_tap
                if add_sendevent_tap is not None
                else self.add_sendevent_tap,
                add_mouse_action=add_mouse_action
                if add_mouse_action is not None
                else self.add_mouse_action,
                x_column=x_column if x_column is not None else self.x_column,
                y_column=y_column if y_column is not None else self.y_column,
                mouse_device=mouse_device
                if mouse_device is not None
                else self.mouse_device,
                touch_device=touch_device
                if touch_device is not None
                else self.touch_device,
                touch_device_max=touch_device_max
                if touch_device_max is not None
                else self.touch_device_max,
                mouse_device_max=mouse_device_max
                if mouse_device_max is not None
                else self.mouse_device_max,
                input_cmd=input_cmd if input_cmd is not None else self.input_cmd,
                sendevent_path=sendevent_path
                if sendevent_path is not None
                else self.sendevent_path,
                screen_height=screen_height
                if screen_height is not None
                else self.screen_height,
                screen_width=screen_width
                if screen_width is not None
                else self.screen_width,
                mouse_action_exe=mouse_action_exe
                if mouse_action_exe is not None
                else self.mouse_action_exe,
                sh_exe=sh_exe if sh_exe is not None else self.sh_exe,
                su_exe=su_exe if su_exe is not None else self.su_exe,
                kwargs=kwargs if kwargs is not None else self.kwargs,
            )
        except Exception:
            errwrite()
        if with_screenshot:
            df.loc[:, "aa_screenshot"] = get_part_of_screenshot(cmd="screencap", width=self.screen_width, height=self.screen_height, coords=list(zip(df["aa_start_x"], df["aa_start_y"], df["aa_end_x"], df["aa_end_y"])))
        return df


cdef vec_rgbxycount search_colors_rgb_with_count(Py_ssize_t start_x, Py_ssize_t start_y, uint8_t[:,:,:] image, uint8_t[:,:] colors) noexcept nogil:
    cdef:
        vec_rgbxycount results
        Py_ssize_t i,j, k
        Py_ssize_t color_count
    for k in range(colors.shape[0]):
        color_count=0
        for i in range(image.shape[0]):
            for j in range(image.shape[1]):
                if colors[k][0]==image[i][j][2] and colors[k][1]==image[i][j][1] and colors[k][2]==image[i][j][0]:
                    results.emplace_back(color_rgb_with_coords_and_count(start_x+j,start_y+i,0,colors[k][0],colors[k][1],colors[k][2]))
                    color_count+=1
        if color_count==0:
            continue
        for i in range(results.size()-1, <Py_ssize_t>results.size()-color_count-1,-1):
            results[i].count=color_count
    return results

def search_for_colors_in_elements(
    object df,
    uint8_t[:,:] colors,
    str result_column="aa_colorsearch",
    str screenshot_column="aa_screenshot",
    str start_x="aa_start_x",
    str start_y="aa_start_y",
    str end_x="aa_end_x",
    str end_y="aa_end_y",
    ):
    cdef:
        list allresults = []
        dict alreadydone = {}
        object indextuple,item
        object allresults_append=allresults.append
    for _, item in df.iterrows():
        if not np.any(item[screenshot_column]):
            allresults_append([])
            continue
        indextuple = (
            item[start_x],
            item[start_y],
            item[end_x],
            item[end_y],
        )
        if indextuple in alreadydone:
            allresults_append(alreadydone[indextuple])
            continue
        alreadydone[indextuple] = search_colors_rgb_with_count(
            start_x=item[start_x],
            start_y=item[start_y],
            image=item[screenshot_column],
            colors=colors,
        )
        allresults_append(alreadydone[indextuple])

    df.loc[:,result_column] = np.asarray(allresults, dtype="object")


def py_calculate_hdbscan(object data,int min_points, int min_cluster_size):
    cdef:
        Py_ssize_t len_data=len(data)
        Py_ssize_t sub_len_data
        Py_ssize_t i, j
        vector[vector[double]] dataset
        double subdata
    if not len_data:
        return []
    sub_len_data=len(data[0])
    if not sub_len_data:
        return []
    dataset.reserve(len_data)
    for i in range(len_data):
        dataset.emplace_back()
        for j in range(sub_len_data):
            subdata=<double>(data[i][j])
            dataset.back().emplace_back(subdata)
    return (calculate_hdbscan(dataset,min_points,min_cluster_size,cpp_distance_metric))


cdef list parsedata(
    bytes sbytes,
):
    cdef:
        list resultlist = []
        object restofstringasbytes = BytesIO(sbytes)
        object restofstringasbytes_read=restofstringasbytes.read
        int ordnextbyte
        object nextbyte
    while nextbyte := restofstringasbytes_read(1):
        with contextlib_suppress(Exception):
            ordnextbyte = ord(nextbyte)
            if ordnextbyte == SIG_STRING:
                bytes2convert2 = restofstringasbytes_read(2)
                bytes2convert = restofstringasbytes_read(
                    bytes2convert2[len(bytes2convert2) - 1]
                )
                resultlist.append(bytes2convert.decode("utf-8", errors="ignore"))
            elif ordnextbyte == SIG_SHORT:
                bytes2convert = restofstringasbytes_read(2)
                resultlist.append( STRUCT_UNPACK_SIG_SHORT(bytes2convert)[0])
            elif ordnextbyte == SIG_BOOLEAN:
                bytes2convert = restofstringasbytes_read(1)
                resultlist.append( STRUCT_UNPACK_SIG_BOOLEAN(bytes2convert)[0])

            elif ordnextbyte == SIG_BYTE:
                bytes2convert = restofstringasbytes_read(1)
                resultlist.append(STRUCT_UNPACK_SIG_BYTE(bytes2convert)[0])

            elif ordnextbyte == SIG_INT:
                bytes2convert = restofstringasbytes_read(4)
                resultlist.append( STRUCT_UNPACK_SIG_INT(bytes2convert)[0])

            elif ordnextbyte == SIG_FLOAT:
                bytes2convert = restofstringasbytes_read(4)
                resultlist.append(STRUCT_UNPACK_SIG_FLOAT(bytes2convert)[0])

            elif ordnextbyte == SIG_DOUBLE:
                bytes2convert = restofstringasbytes_read(8)
                resultlist.append(STRUCT_UNPACK_SIG_DOUBLE(bytes2convert)[0])

            elif ordnextbyte == SIG_LONG:
                bytes2convert = restofstringasbytes_read(8)
                resultlist.append(STRUCT_UNPACK_SIG_LONG(bytes2convert)[0])

    return resultlist

cdef list[tuple] extract_files_from_zip(object zipfilepath):
    cdef:
        bytes data=b""
        object ioby
        list[tuple] single_files_extracted
        Py_ssize_t len_single_files, single_file_index
    if isinstance(zipfilepath, str) and os.path.exists(zipfilepath):
        with open(zipfilepath, "rb") as f:
            data = f.read()
    else:
        data = zipfilepath
    ioby = BytesIO(data)
    single_files_extracted = []
    with zipfile.ZipFile(ioby, "r") as zip_ref:
        single_files = zip_ref.namelist()
        len_single_files = len(single_files)
        for single_file_index in range(len_single_files):
            with contextlib_suppress(Exception):
                single_files_extracted.append(
                    (
                        single_files[single_file_index],
                        zip_ref.read(single_files[single_file_index]),
                    )
                )
    return single_files_extracted

def parse_window_elements_to_list(
    object dump_cmd='cmd window dump-visible-window-views',
    **kwargs
):
    cdef:
        bytes zipfilepath
        list[tuple] zipname_zipdata
        Py_ssize_t zip_index
        list result_dicts
    zipfilepath=subprocess_run(dump_cmd,**{**kwargs,**{'capture_output':True}}).stdout
    zipname_zipdata = extract_files_from_zip(zipfilepath)
    result_dicts=[]
    for zip_index in range(len(zipname_zipdata)):
        with contextlib_suppress(Exception):
            result_dicts.append([parsedata(sbytes=zipname_zipdata[zip_index][1]),zipname_zipdata[zip_index][0]])
    return result_dicts

cdef class WindowDumper:
    cdef:
        str android_fragment_parser_exe
        str android_window_parser_cmd
        int timeout
        bint add_input_tap
        bint add_sendevent_mouse_click
        bint add_sendevent_tap
        bint add_mouse_action
        str x_column
        str y_column
        str mouse_device
        str touch_device
        int touch_device_max
        int mouse_device_max
        str input_cmd
        str sendevent_path
        int screen_height
        int screen_width
        str mouse_action_exe
        str sh_exe
        str su_exe
        object kwargs
    def __init__(
        self,
        str android_fragment_parser_exe,
        str android_window_parser_cmd,
        int timeout=30,
        bint add_input_tap=True,
        bint add_sendevent_mouse_click=True,
        bint add_sendevent_tap=True,
        bint add_mouse_action=True,
        str x_column="aa_center_x",
        str y_column="aa_center_y",
        str mouse_device="/dev/input/event5",
        str touch_device="/dev/input/event4",
        int touch_device_max=32767,
        int mouse_device_max=65535,
        str input_cmd="/system/bin/input tap",
        str sendevent_path="/system/bin/sendevent",
        int screen_height=1280,
        int screen_width=720,
        str mouse_action_exe="/data/data/com.termux/files/usr/bin/mouse_sendevent_android/a.out",
        str sh_exe="sh",
        str su_exe="su",
        object kwargs=None,
    ):
        self.android_fragment_parser_exe = android_fragment_parser_exe
        self.sh_exe = sh_exe
        self.su_exe = su_exe
        self.timeout = timeout
        self.add_input_tap = add_input_tap
        self.add_sendevent_mouse_click = add_sendevent_mouse_click
        self.add_sendevent_tap = add_sendevent_tap
        self.add_mouse_action = add_mouse_action
        self.x_column = x_column
        self.y_column = y_column
        self.mouse_device = mouse_device
        self.touch_device = touch_device
        self.touch_device_max = touch_device_max
        self.mouse_device_max = mouse_device_max
        self.input_cmd = input_cmd
        self.sendevent_path = sendevent_path
        self.screen_height = screen_height
        self.screen_width = screen_width
        self.mouse_action_exe = mouse_action_exe
        self.kwargs = kwargs
        self.android_window_parser_cmd = android_window_parser_cmd

    @cython.nonecheck(True)
    @cython.boundscheck(True)
    @cython.wraparound(True)
    @cython.initializedcheck(True)
    @cython.nonecheck(True)
    def get_df(
        self,
        bint with_screenshot=True,
        object add_input_tap=None,
        object add_sendevent_mouse_click=None,
        object add_sendevent_tap=None,
        object add_mouse_action=None,
        object x_column=None,
        object y_column=None,
        object mouse_device=None,
        object touch_device=None,
        object touch_device_max=None,
        object mouse_device_max=None,
        object input_cmd=None,
        object sendevent_path=None,
        object screen_height=None,
        object screen_width=None,
        object mouse_action_exe=None,
        object sh_exe=None,
        object su_exe=None,
        object kwargs=None,
        object timeout=None,
    ):

        cdef:
            object df2,q,df1
            Py_ssize_t qidx,counter,last_index_alldata,mydata,each_key,i,j
            dict mappingdict,mapping_dict,rename_dict
            str newkey
            set allpossible_keys_set
            list aa_start_x, aa_start_y,aa_end_x,aa_end_y,aa_center_x,aa_center_y,alldfs,allpossible_keys,iti,alldata,allmydata
            np.ndarray hashcodes_df1_full, hashcodes_df2_full
            int64_t[:] hashcodes_df1,hashcodes_df2
            bint isgood
        df2=get_fragment_data(
        android_fragment_parser_exe=self.android_fragment_parser_exe,
        timeout=timeout if timeout else self.timeout,
        ).drop_duplicates(
            subset=["aa_hashcode_int"], keep="first"
        )
        q = parse_window_elements_to_list(
            dump_cmd=self.android_window_parser_cmd,
            shell=True,
            timeout=timeout if timeout else self.timeout,
            env=os_environ
            )
        alldfs = []
        for qidx in range(len(q)):
            with contextlib_suppress(Exception):
                iti = q[qidx][0]
                itiname = q[qidx][1]
                propindex = iti.index("propertyIndex")
                mappingdata = iti[propindex : len(iti) - 1][1:]
                mappingdict = {
                    k: v
                    for k, v in sorted(
                        dict(zip(mappingdata[::2], mappingdata[1::2])).items(),
                        key=lambda item: item[0],
                    )
                }
                counter = 0
                iti2 = iti[: propindex - 1]
                alldata = [[[]]]
                last_index_alldata = 0
                for qq in iti2:
                    if qq == "END":
                        counter = 0
                        alldata.append("END")
                        alldata.append([[]])
                    else:
                        if counter % 2 == 0 and qq != 0:
                            mykey = mappingdict.get(qq, None)
                            if mykey is None:
                                last_index_alldata = len(alldata[len(alldata) - 1]) - 1
                                alldata[len(alldata) - 1][last_index_alldata].append(qq)
                            else:
                                alldata[len(alldata) - 1].append([mykey])
                        elif counter % 2 == 1:
                            last_index_alldata = len(alldata[len(alldata) - 1]) - 1
                            alldata[len(alldata) - 1][last_index_alldata].append(qq)
                        if counter % 2 == 0 and qq == 0:
                            alldata.append([])
                            continue
                        counter += 1

                allmydata = []
                for aa in alldata:
                    if aa == "END":
                        continue
                    else:
                        if aa:
                            aa2 = [x for x in aa if x]
                            if not aa2:
                                continue
                            if len(aa2) > 1 and aa2[-1][0].startswith("meta:__child__"):
                                allmydata.append(aa2[: len(aa2) - 1])
                                allmydata.append(aa2[len(aa2) - 1])
                            else:
                                allmydata.append(aa2)
                newkey = "-1"
                mapping_dict = {}
                mapping_dict[newkey] = []
                allpossible_keys_set = set()
                for mydata in range(len(allmydata)):
                    if (
                        allmydata[mydata]
                        and isinstance(allmydata[mydata][0], str)
                        and allmydata[mydata][0].startswith("meta:__child__")
                        and len(allmydata[mydata]) > 2
                    ):
                        newkey = hex(allmydata[mydata][4])[2:]
                        mapping_dict[newkey] = []
                        allpossible_keys_set.add("CHILD_META")
                        mapping_dict[newkey].append(("CHILD_META", tuple(allmydata[mydata])))
                        mapping_dict[newkey].append(("aa_hashcode_int", allmydata[mydata][4]))
                    else:
                        mapping_dict[newkey].extend(
                            (tuple(x) if len(x) == 2 else (x[0], tuple(x[1:])) for x in allmydata[mydata])
                        )
                for values in mapping_dict.values():
                    for value in values:
                        allpossible_keys_set.add(value[0])
                allpossible_keys = sorted(allpossible_keys_set)
                for key in mapping_dict:
                    mapping_dict[key] = dict(mapping_dict[key])
                    for each_key in range(len(allpossible_keys)):
                        if allpossible_keys[each_key] not in mapping_dict[key]:
                            mapping_dict[key][allpossible_keys[each_key]] = None
                df1 = pd.DataFrame.from_dict(mapping_dict, orient="index")
                hashcodes_df1_full = df1["aa_hashcode_int"].fillna(-1).astype(np.int64).__array__()
                hashcodes_df2_full = df2["aa_hashcode_int"].astype(np.int64).__array__()
                hashcodes_df1=hashcodes_df1_full
                hashcodes_df2=hashcodes_df2_full
                aa_start_x = []
                aa_start_y = []
                aa_end_x = []
                aa_end_y = []
                aa_center_x = []
                aa_center_y = []
                isgood = False
                for j in range(len(hashcodes_df1)):
                    for i in range(len(hashcodes_df2)):
                        if hashcodes_df2[i] == hashcodes_df1[j]:
                            aa_start_x.append(df2["aa_start_x"].iloc[i])
                            aa_start_y.append(df2["aa_start_y"].iloc[i])
                            aa_end_x.append(df2["aa_end_x"].iloc[i])
                            aa_end_y.append(df2["aa_end_y"].iloc[i])
                            aa_center_x.append(df2["aa_center_x"].iloc[i])
                            aa_center_y.append(df2["aa_center_y"].iloc[i])
                            isgood = True
                            break
                    else:
                        aa_start_x.append(-1)
                        aa_start_y.append(-1)
                        aa_end_x.append(-1)
                        aa_end_y.append(-1)
                        aa_center_x.append(-1)
                        aa_center_y.append(-1)

                if not isgood:
                    continue
                rename_dict = {x: "aa_" + x.replace(":", "_") for x in df1.columns}
                df1 = df1.rename(columns=rename_dict, inplace=False)
                df1.loc[:, "aa_start_x"] = aa_start_x
                df1.loc[:, "aa_start_y"] = aa_start_y
                df1.loc[:, "aa_end_x"] = aa_end_x
                df1.loc[:, "aa_end_y"] = aa_end_y
                df1.loc[:, "aa_center_x"] = aa_center_x
                df1.loc[:, "aa_center_y"] = aa_center_y
                df1.loc[:, "aa_window_name"] = itiname
                alldfs.append(df1)
                break
        try:
            if len(alldfs)>0:
                df=alldfs[0]
            else:
                return pd.DataFrame()
            df["aa_hashcode_hex"]=df.index.__array__().copy()
            df=df.reset_index(drop=True)
            add_events_to_dataframe(
                df,
                add_input_tap=add_input_tap
                if add_input_tap is not None
                else self.add_input_tap,
                add_sendevent_mouse_click=add_sendevent_mouse_click
                if add_sendevent_mouse_click is not None
                else self.add_sendevent_mouse_click,
                add_sendevent_tap=add_sendevent_tap
                if add_sendevent_tap is not None
                else self.add_sendevent_tap,
                add_mouse_action=add_mouse_action
                if add_mouse_action is not None
                else self.add_mouse_action,
                x_column=x_column if x_column is not None else self.x_column,
                y_column=y_column if y_column is not None else self.y_column,
                mouse_device=mouse_device
                if mouse_device is not None
                else self.mouse_device,
                touch_device=touch_device
                if touch_device is not None
                else self.touch_device,
                touch_device_max=touch_device_max
                if touch_device_max is not None
                else self.touch_device_max,
                mouse_device_max=mouse_device_max
                if mouse_device_max is not None
                else self.mouse_device_max,
                input_cmd=input_cmd if input_cmd is not None else self.input_cmd,
                sendevent_path=sendevent_path
                if sendevent_path is not None
                else self.sendevent_path,
                screen_height=screen_height
                if screen_height is not None
                else self.screen_height,
                screen_width=screen_width
                if screen_width is not None
                else self.screen_width,
                mouse_action_exe=mouse_action_exe
                if mouse_action_exe is not None
                else self.mouse_action_exe,
                sh_exe=sh_exe if sh_exe is not None else self.sh_exe,
                su_exe=su_exe if su_exe is not None else self.su_exe,
                kwargs=kwargs if kwargs is not None else self.kwargs,
            )
        except Exception:
            errwrite()
        if with_screenshot:
            df.loc[:, "aa_screenshot"] = get_part_of_screenshot(cmd="screencap", width=self.screen_width, height=self.screen_height, coords=list(zip(df["aa_start_x"], df["aa_start_y"], df["aa_end_x"], df["aa_end_y"])))
        return df
