
from libcpp.string cimport string
from struct import pack as structpack
cimport numpy as np
import numpy as np
from zlib import compress as zlib_compress
from zlib import crc32 as zlib_crc32
from unicodedata import name as unicodedata_name
from time import sleep as timesleep
from string import printable as string_printable
from random import randint as random_randint
from os import environ as os_environ
from subprocess import run as subprocess_run
import cython
cimport cython

cdef extern from "subprocstuff.hpp" nogil :
    void os_system(string &command)

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

@cython.final
cdef class KeyCodePresser:
    cdef:
        str system_bin_path

    def __init__(self, system_bin: str):
        self.system_bin_path =  convert_python_object_to_cpp_string(system_bin)

    cdef _press(self, string cmd):
        cdef:
            string cmd2execute = self.system_bin_path
        cmd2execute.append(cmd)
        os_system(cmd2execute)

    def long_press_KEYCODE_SOFT_LEFT(self):
        return self._press(<string>b"input keyevent --longpress 1")

    def short_press_KEYCODE_SOFT_LEFT(self):
        return self._press(<string>b"input keyevent 1")

    def long_press_KEYCODE_SOFT_RIGHT(self):
        return self._press(<string>b"input keyevent --longpress 2")

    def short_press_KEYCODE_SOFT_RIGHT(self):
        return self._press(<string>b"input keyevent 2")

    def long_press_KEYCODE_HOME(self):
        return self._press(<string>b"input keyevent --longpress 3")

    def short_press_KEYCODE_HOME(self):
        return self._press(<string>b"input keyevent 3")

    def long_press_KEYCODE_BACK(self):
        return self._press(<string>b"input keyevent --longpress 4")

    def short_press_KEYCODE_BACK(self):
        return self._press(<string>b"input keyevent 4")

    def long_press_KEYCODE_CALL(self):
        return self._press(<string>b"input keyevent --longpress 5")

    def short_press_KEYCODE_CALL(self):
        return self._press(<string>b"input keyevent 5")

    def long_press_KEYCODE_ENDCALL(self):
        return self._press(<string>b"input keyevent --longpress 6")

    def short_press_KEYCODE_ENDCALL(self):
        return self._press(<string>b"input keyevent 6")

    def long_press_KEYCODE_0(self):
        return self._press(<string>b"input keyevent --longpress 7")

    def short_press_KEYCODE_0(self):
        return self._press(<string>b"input keyevent 7")

    def long_press_KEYCODE_1(self):
        return self._press(<string>b"input keyevent --longpress 8")

    def short_press_KEYCODE_1(self):
        return self._press(<string>b"input keyevent 8")

    def long_press_KEYCODE_2(self):
        return self._press(<string>b"input keyevent --longpress 9")

    def short_press_KEYCODE_2(self):
        return self._press(<string>b"input keyevent 9")

    def long_press_KEYCODE_3(self):
        return self._press(<string>b"input keyevent --longpress 10")

    def short_press_KEYCODE_3(self):
        return self._press(<string>b"input keyevent 10")

    def long_press_KEYCODE_4(self):
        return self._press(<string>b"input keyevent --longpress 11")

    def short_press_KEYCODE_4(self):
        return self._press(<string>b"input keyevent 11")

    def long_press_KEYCODE_5(self):
        return self._press(<string>b"input keyevent --longpress 12")

    def short_press_KEYCODE_5(self):
        return self._press(<string>b"input keyevent 12")

    def long_press_KEYCODE_6(self):
        return self._press(<string>b"input keyevent --longpress 13")

    def short_press_KEYCODE_6(self):
        return self._press(<string>b"input keyevent 13")

    def long_press_KEYCODE_7(self):
        return self._press(<string>b"input keyevent --longpress 14")

    def short_press_KEYCODE_7(self):
        return self._press(<string>b"input keyevent 14")

    def long_press_KEYCODE_8(self):
        return self._press(<string>b"input keyevent --longpress 15")

    def short_press_KEYCODE_8(self):
        return self._press(<string>b"input keyevent 15")

    def long_press_KEYCODE_9(self):
        return self._press(<string>b"input keyevent --longpress 16")

    def short_press_KEYCODE_9(self):
        return self._press(<string>b"input keyevent 16")

    def long_press_KEYCODE_STAR(self):
        return self._press(<string>b"input keyevent --longpress 17")

    def short_press_KEYCODE_STAR(self):
        return self._press(<string>b"input keyevent 17")

    def long_press_KEYCODE_POUND(self):
        return self._press(<string>b"input keyevent --longpress 18")

    def short_press_KEYCODE_POUND(self):
        return self._press(<string>b"input keyevent 18")

    def long_press_KEYCODE_DPAD_UP(self):
        return self._press(<string>b"input keyevent --longpress 19")

    def short_press_KEYCODE_DPAD_UP(self):
        return self._press(<string>b"input keyevent 19")

    def long_press_KEYCODE_DPAD_DOWN(self):
        return self._press(<string>b"input keyevent --longpress 20")

    def short_press_KEYCODE_DPAD_DOWN(self):
        return self._press(<string>b"input keyevent 20")

    def long_press_KEYCODE_DPAD_LEFT(self):
        return self._press(<string>b"input keyevent --longpress 21")

    def short_press_KEYCODE_DPAD_LEFT(self):
        return self._press(<string>b"input keyevent 21")

    def long_press_KEYCODE_DPAD_RIGHT(self):
        return self._press(<string>b"input keyevent --longpress 22")

    def short_press_KEYCODE_DPAD_RIGHT(self):
        return self._press(<string>b"input keyevent 22")

    def long_press_KEYCODE_DPAD_CENTER(self):
        return self._press(<string>b"input keyevent --longpress 23")

    def short_press_KEYCODE_DPAD_CENTER(self):
        return self._press(<string>b"input keyevent 23")

    def long_press_KEYCODE_VOLUME_UP(self):
        return self._press(<string>b"input keyevent --longpress 24")

    def short_press_KEYCODE_VOLUME_UP(self):
        return self._press(<string>b"input keyevent 24")

    def long_press_KEYCODE_VOLUME_DOWN(self):
        return self._press(<string>b"input keyevent --longpress 25")

    def short_press_KEYCODE_VOLUME_DOWN(self):
        return self._press(<string>b"input keyevent 25")

    def long_press_KEYCODE_POWER(self):
        return self._press(<string>b"input keyevent --longpress 26")

    def short_press_KEYCODE_POWER(self):
        return self._press(<string>b"input keyevent 26")

    def long_press_KEYCODE_CAMERA(self):
        return self._press(<string>b"input keyevent --longpress 27")

    def short_press_KEYCODE_CAMERA(self):
        return self._press(<string>b"input keyevent 27")

    def long_press_KEYCODE_CLEAR(self):
        return self._press(<string>b"input keyevent --longpress 28")

    def short_press_KEYCODE_CLEAR(self):
        return self._press(<string>b"input keyevent 28")

    def long_press_KEYCODE_A(self):
        return self._press(<string>b"input keyevent --longpress 29")

    def short_press_KEYCODE_A(self):
        return self._press(<string>b"input keyevent 29")

    def long_press_KEYCODE_B(self):
        return self._press(<string>b"input keyevent --longpress 30")

    def short_press_KEYCODE_B(self):
        return self._press(<string>b"input keyevent 30")

    def long_press_KEYCODE_C(self):
        return self._press(<string>b"input keyevent --longpress 31")

    def short_press_KEYCODE_C(self):
        return self._press(<string>b"input keyevent 31")

    def long_press_KEYCODE_D(self):
        return self._press(<string>b"input keyevent --longpress 32")

    def short_press_KEYCODE_D(self):
        return self._press(<string>b"input keyevent 32")

    def long_press_KEYCODE_E(self):
        return self._press(<string>b"input keyevent --longpress 33")

    def short_press_KEYCODE_E(self):
        return self._press(<string>b"input keyevent 33")

    def long_press_KEYCODE_F(self):
        return self._press(<string>b"input keyevent --longpress 34")

    def short_press_KEYCODE_F(self):
        return self._press(<string>b"input keyevent 34")

    def long_press_KEYCODE_G(self):
        return self._press(<string>b"input keyevent --longpress 35")

    def short_press_KEYCODE_G(self):
        return self._press(<string>b"input keyevent 35")

    def long_press_KEYCODE_H(self):
        return self._press(<string>b"input keyevent --longpress 36")

    def short_press_KEYCODE_H(self):
        return self._press(<string>b"input keyevent 36")

    def long_press_KEYCODE_I(self):
        return self._press(<string>b"input keyevent --longpress 37")

    def short_press_KEYCODE_I(self):
        return self._press(<string>b"input keyevent 37")

    def long_press_KEYCODE_J(self):
        return self._press(<string>b"input keyevent --longpress 38")

    def short_press_KEYCODE_J(self):
        return self._press(<string>b"input keyevent 38")

    def long_press_KEYCODE_K(self):
        return self._press(<string>b"input keyevent --longpress 39")

    def short_press_KEYCODE_K(self):
        return self._press(<string>b"input keyevent 39")

    def long_press_KEYCODE_L(self):
        return self._press(<string>b"input keyevent --longpress 40")

    def short_press_KEYCODE_L(self):
        return self._press(<string>b"input keyevent 40")

    def long_press_KEYCODE_M(self):
        return self._press(<string>b"input keyevent --longpress 41")

    def short_press_KEYCODE_M(self):
        return self._press(<string>b"input keyevent 41")

    def long_press_KEYCODE_N(self):
        return self._press(<string>b"input keyevent --longpress 42")

    def short_press_KEYCODE_N(self):
        return self._press(<string>b"input keyevent 42")

    def long_press_KEYCODE_O(self):
        return self._press(<string>b"input keyevent --longpress 43")

    def short_press_KEYCODE_O(self):
        return self._press(<string>b"input keyevent 43")

    def long_press_KEYCODE_P(self):
        return self._press(<string>b"input keyevent --longpress 44")

    def short_press_KEYCODE_P(self):
        return self._press(<string>b"input keyevent 44")

    def long_press_KEYCODE_Q(self):
        return self._press(<string>b"input keyevent --longpress 45")

    def short_press_KEYCODE_Q(self):
        return self._press(<string>b"input keyevent 45")

    def long_press_KEYCODE_R(self):
        return self._press(<string>b"input keyevent --longpress 46")

    def short_press_KEYCODE_R(self):
        return self._press(<string>b"input keyevent 46")

    def long_press_KEYCODE_S(self):
        return self._press(<string>b"input keyevent --longpress 47")

    def short_press_KEYCODE_S(self):
        return self._press(<string>b"input keyevent 47")

    def long_press_KEYCODE_T(self):
        return self._press(<string>b"input keyevent --longpress 48")

    def short_press_KEYCODE_T(self):
        return self._press(<string>b"input keyevent 48")

    def long_press_KEYCODE_U(self):
        return self._press(<string>b"input keyevent --longpress 49")

    def short_press_KEYCODE_U(self):
        return self._press(<string>b"input keyevent 49")

    def long_press_KEYCODE_V(self):
        return self._press(<string>b"input keyevent --longpress 50")

    def short_press_KEYCODE_V(self):
        return self._press(<string>b"input keyevent 50")

    def long_press_KEYCODE_W(self):
        return self._press(<string>b"input keyevent --longpress 51")

    def short_press_KEYCODE_W(self):
        return self._press(<string>b"input keyevent 51")

    def long_press_KEYCODE_X(self):
        return self._press(<string>b"input keyevent --longpress 52")

    def short_press_KEYCODE_X(self):
        return self._press(<string>b"input keyevent 52")

    def long_press_KEYCODE_Y(self):
        return self._press(<string>b"input keyevent --longpress 53")

    def short_press_KEYCODE_Y(self):
        return self._press(<string>b"input keyevent 53")

    def long_press_KEYCODE_Z(self):
        return self._press(<string>b"input keyevent --longpress 54")

    def short_press_KEYCODE_Z(self):
        return self._press(<string>b"input keyevent 54")

    def long_press_KEYCODE_COMMA(self):
        return self._press(<string>b"input keyevent --longpress 55")

    def short_press_KEYCODE_COMMA(self):
        return self._press(<string>b"input keyevent 55")

    def long_press_KEYCODE_PERIOD(self):
        return self._press(<string>b"input keyevent --longpress 56")

    def short_press_KEYCODE_PERIOD(self):
        return self._press(<string>b"input keyevent 56")

    def long_press_KEYCODE_ALT_LEFT(self):
        return self._press(<string>b"input keyevent --longpress 57")

    def short_press_KEYCODE_ALT_LEFT(self):
        return self._press(<string>b"input keyevent 57")

    def long_press_KEYCODE_ALT_RIGHT(self):
        return self._press(<string>b"input keyevent --longpress 58")

    def short_press_KEYCODE_ALT_RIGHT(self):
        return self._press(<string>b"input keyevent 58")

    def long_press_KEYCODE_SHIFT_LEFT(self):
        return self._press(<string>b"input keyevent --longpress 59")

    def short_press_KEYCODE_SHIFT_LEFT(self):
        return self._press(<string>b"input keyevent 59")

    def long_press_KEYCODE_SHIFT_RIGHT(self):
        return self._press(<string>b"input keyevent --longpress 60")

    def short_press_KEYCODE_SHIFT_RIGHT(self):
        return self._press(<string>b"input keyevent 60")

    def long_press_KEYCODE_TAB(self):
        return self._press(<string>b"input keyevent --longpress 61")

    def short_press_KEYCODE_TAB(self):
        return self._press(<string>b"input keyevent 61")

    def long_press_KEYCODE_SPACE(self):
        return self._press(<string>b"input keyevent --longpress 62")

    def short_press_KEYCODE_SPACE(self):
        return self._press(<string>b"input keyevent 62")

    def long_press_KEYCODE_SYM(self):
        return self._press(<string>b"input keyevent --longpress 63")

    def short_press_KEYCODE_SYM(self):
        return self._press(<string>b"input keyevent 63")

    def long_press_KEYCODE_EXPLORER(self):
        return self._press(<string>b"input keyevent --longpress 64")

    def short_press_KEYCODE_EXPLORER(self):
        return self._press(<string>b"input keyevent 64")

    def long_press_KEYCODE_ENVELOPE(self):
        return self._press(<string>b"input keyevent --longpress 65")

    def short_press_KEYCODE_ENVELOPE(self):
        return self._press(<string>b"input keyevent 65")

    def long_press_KEYCODE_ENTER(self):
        return self._press(<string>b"input keyevent --longpress 66")

    def short_press_KEYCODE_ENTER(self):
        return self._press(<string>b"input keyevent 66")

    def long_press_KEYCODE_DEL(self):
        return self._press(<string>b"input keyevent --longpress 67")

    def short_press_KEYCODE_DEL(self):
        return self._press(<string>b"input keyevent 67")

    def long_press_KEYCODE_GRAVE(self):
        return self._press(<string>b"input keyevent --longpress 68")

    def short_press_KEYCODE_GRAVE(self):
        return self._press(<string>b"input keyevent 68")

    def long_press_KEYCODE_MINUS(self):
        return self._press(<string>b"input keyevent --longpress 69")

    def short_press_KEYCODE_MINUS(self):
        return self._press(<string>b"input keyevent 69")

    def long_press_KEYCODE_EQUALS(self):
        return self._press(<string>b"input keyevent --longpress 70")

    def short_press_KEYCODE_EQUALS(self):
        return self._press(<string>b"input keyevent 70")

    def long_press_KEYCODE_LEFT_BRACKET(self):
        return self._press(<string>b"input keyevent --longpress 71")

    def short_press_KEYCODE_LEFT_BRACKET(self):
        return self._press(<string>b"input keyevent 71")

    def long_press_KEYCODE_RIGHT_BRACKET(self):
        return self._press(<string>b"input keyevent --longpress 72")

    def short_press_KEYCODE_RIGHT_BRACKET(self):
        return self._press(<string>b"input keyevent 72")

    def long_press_KEYCODE_BACKSLASH(self):
        return self._press(<string>b"input keyevent --longpress 73")

    def short_press_KEYCODE_BACKSLASH(self):
        return self._press(<string>b"input keyevent 73")

    def long_press_KEYCODE_SEMICOLON(self):
        return self._press(<string>b"input keyevent --longpress 74")

    def short_press_KEYCODE_SEMICOLON(self):
        return self._press(<string>b"input keyevent 74")

    def long_press_KEYCODE_APOSTROPHE(self):
        return self._press(<string>b"input keyevent --longpress 75")

    def short_press_KEYCODE_APOSTROPHE(self):
        return self._press(<string>b"input keyevent 75")

    def long_press_KEYCODE_SLASH(self):
        return self._press(<string>b"input keyevent --longpress 76")

    def short_press_KEYCODE_SLASH(self):
        return self._press(<string>b"input keyevent 76")

    def long_press_KEYCODE_AT(self):
        return self._press(<string>b"input keyevent --longpress 77")

    def short_press_KEYCODE_AT(self):
        return self._press(<string>b"input keyevent 77")

    def long_press_KEYCODE_NUM(self):
        return self._press(<string>b"input keyevent --longpress 78")

    def short_press_KEYCODE_NUM(self):
        return self._press(<string>b"input keyevent 78")

    def long_press_KEYCODE_HEADSETHOOK(self):
        return self._press(<string>b"input keyevent --longpress 79")

    def short_press_KEYCODE_HEADSETHOOK(self):
        return self._press(<string>b"input keyevent 79")

    def long_press_KEYCODE_FOCUS(self):
        return self._press(<string>b"input keyevent --longpress 80")

    def short_press_KEYCODE_FOCUS(self):
        return self._press(<string>b"input keyevent 80")

    def long_press_KEYCODE_PLUS(self):
        return self._press(<string>b"input keyevent --longpress 81")

    def short_press_KEYCODE_PLUS(self):
        return self._press(<string>b"input keyevent 81")

    def long_press_KEYCODE_MENU(self):
        return self._press(<string>b"input keyevent --longpress 82")

    def short_press_KEYCODE_MENU(self):
        return self._press(<string>b"input keyevent 82")

    def long_press_KEYCODE_NOTIFICATION(self):
        return self._press(<string>b"input keyevent --longpress 83")

    def short_press_KEYCODE_NOTIFICATION(self):
        return self._press(<string>b"input keyevent 83")

    def long_press_KEYCODE_SEARCH(self):
        return self._press(<string>b"input keyevent --longpress 84")

    def short_press_KEYCODE_SEARCH(self):
        return self._press(<string>b"input keyevent 84")

    def long_press_KEYCODE_MEDIA_PLAY_PAUSE(self):
        return self._press(<string>b"input keyevent --longpress 85")

    def short_press_KEYCODE_MEDIA_PLAY_PAUSE(self):
        return self._press(<string>b"input keyevent 85")

    def long_press_KEYCODE_MEDIA_STOP(self):
        return self._press(<string>b"input keyevent --longpress 86")

    def short_press_KEYCODE_MEDIA_STOP(self):
        return self._press(<string>b"input keyevent 86")

    def long_press_KEYCODE_MEDIA_NEXT(self):
        return self._press(<string>b"input keyevent --longpress 87")

    def short_press_KEYCODE_MEDIA_NEXT(self):
        return self._press(<string>b"input keyevent 87")

    def long_press_KEYCODE_MEDIA_PREVIOUS(self):
        return self._press(<string>b"input keyevent --longpress 88")

    def short_press_KEYCODE_MEDIA_PREVIOUS(self):
        return self._press(<string>b"input keyevent 88")

    def long_press_KEYCODE_MEDIA_REWIND(self):
        return self._press(<string>b"input keyevent --longpress 89")

    def short_press_KEYCODE_MEDIA_REWIND(self):
        return self._press(<string>b"input keyevent 89")

    def long_press_KEYCODE_MEDIA_FAST_FORWARD(self):
        return self._press(<string>b"input keyevent --longpress 90")

    def short_press_KEYCODE_MEDIA_FAST_FORWARD(self):
        return self._press(<string>b"input keyevent 90")

    def long_press_KEYCODE_MUTE(self):
        return self._press(<string>b"input keyevent --longpress 91")

    def short_press_KEYCODE_MUTE(self):
        return self._press(<string>b"input keyevent 91")

    def long_press_KEYCODE_PAGE_UP(self):
        return self._press(<string>b"input keyevent --longpress 92")

    def short_press_KEYCODE_PAGE_UP(self):
        return self._press(<string>b"input keyevent 92")

    def long_press_KEYCODE_PAGE_DOWN(self):
        return self._press(<string>b"input keyevent --longpress 93")

    def short_press_KEYCODE_PAGE_DOWN(self):
        return self._press(<string>b"input keyevent 93")

    def long_press_KEYCODE_PICTSYMBOLS(self):
        return self._press(<string>b"input keyevent --longpress 94")

    def short_press_KEYCODE_PICTSYMBOLS(self):
        return self._press(<string>b"input keyevent 94")

    def long_press_KEYCODE_SWITCH_CHARSET(self):
        return self._press(<string>b"input keyevent --longpress 95")

    def short_press_KEYCODE_SWITCH_CHARSET(self):
        return self._press(<string>b"input keyevent 95")

    def long_press_KEYCODE_BUTTON_A(self):
        return self._press(<string>b"input keyevent --longpress 96")

    def short_press_KEYCODE_BUTTON_A(self):
        return self._press(<string>b"input keyevent 96")

    def long_press_KEYCODE_BUTTON_B(self):
        return self._press(<string>b"input keyevent --longpress 97")

    def short_press_KEYCODE_BUTTON_B(self):
        return self._press(<string>b"input keyevent 97")

    def long_press_KEYCODE_BUTTON_C(self):
        return self._press(<string>b"input keyevent --longpress 98")

    def short_press_KEYCODE_BUTTON_C(self):
        return self._press(<string>b"input keyevent 98")

    def long_press_KEYCODE_BUTTON_X(self):
        return self._press(<string>b"input keyevent --longpress 99")

    def short_press_KEYCODE_BUTTON_X(self):
        return self._press(<string>b"input keyevent 99")

    def long_press_KEYCODE_BUTTON_Y(self):
        return self._press(<string>b"input keyevent --longpress 100")

    def short_press_KEYCODE_BUTTON_Y(self):
        return self._press(<string>b"input keyevent 100")

    def long_press_KEYCODE_BUTTON_Z(self):
        return self._press(<string>b"input keyevent --longpress 101")

    def short_press_KEYCODE_BUTTON_Z(self):
        return self._press(<string>b"input keyevent 101")

    def long_press_KEYCODE_BUTTON_L1(self):
        return self._press(<string>b"input keyevent --longpress 102")

    def short_press_KEYCODE_BUTTON_L1(self):
        return self._press(<string>b"input keyevent 102")

    def long_press_KEYCODE_BUTTON_R1(self):
        return self._press(<string>b"input keyevent --longpress 103")

    def short_press_KEYCODE_BUTTON_R1(self):
        return self._press(<string>b"input keyevent 103")

    def long_press_KEYCODE_BUTTON_L2(self):
        return self._press(<string>b"input keyevent --longpress 104")

    def short_press_KEYCODE_BUTTON_L2(self):
        return self._press(<string>b"input keyevent 104")

    def long_press_KEYCODE_BUTTON_R2(self):
        return self._press(<string>b"input keyevent --longpress 105")

    def short_press_KEYCODE_BUTTON_R2(self):
        return self._press(<string>b"input keyevent 105")

    def long_press_KEYCODE_BUTTON_THUMBL(self):
        return self._press(<string>b"input keyevent --longpress 106")

    def short_press_KEYCODE_BUTTON_THUMBL(self):
        return self._press(<string>b"input keyevent 106")

    def long_press_KEYCODE_BUTTON_THUMBR(self):
        return self._press(<string>b"input keyevent --longpress 107")

    def short_press_KEYCODE_BUTTON_THUMBR(self):
        return self._press(<string>b"input keyevent 107")

    def long_press_KEYCODE_BUTTON_START(self):
        return self._press(<string>b"input keyevent --longpress 108")

    def short_press_KEYCODE_BUTTON_START(self):
        return self._press(<string>b"input keyevent 108")

    def long_press_KEYCODE_BUTTON_SELECT(self):
        return self._press(<string>b"input keyevent --longpress 109")

    def short_press_KEYCODE_BUTTON_SELECT(self):
        return self._press(<string>b"input keyevent 109")

    def long_press_KEYCODE_BUTTON_MODE(self):
        return self._press(<string>b"input keyevent --longpress 110")

    def short_press_KEYCODE_BUTTON_MODE(self):
        return self._press(<string>b"input keyevent 110")

    def long_press_KEYCODE_ESCAPE(self):
        return self._press(<string>b"input keyevent --longpress 111")

    def short_press_KEYCODE_ESCAPE(self):
        return self._press(<string>b"input keyevent 111")

    def long_press_KEYCODE_FORWARD_DEL(self):
        return self._press(<string>b"input keyevent --longpress 112")

    def short_press_KEYCODE_FORWARD_DEL(self):
        return self._press(<string>b"input keyevent 112")

    def long_press_KEYCODE_CTRL_LEFT(self):
        return self._press(<string>b"input keyevent --longpress 113")

    def short_press_KEYCODE_CTRL_LEFT(self):
        return self._press(<string>b"input keyevent 113")

    def long_press_KEYCODE_CTRL_RIGHT(self):
        return self._press(<string>b"input keyevent --longpress 114")

    def short_press_KEYCODE_CTRL_RIGHT(self):
        return self._press(<string>b"input keyevent 114")

    def long_press_KEYCODE_CAPS_LOCK(self):
        return self._press(<string>b"input keyevent --longpress 115")

    def short_press_KEYCODE_CAPS_LOCK(self):
        return self._press(<string>b"input keyevent 115")

    def long_press_KEYCODE_SCROLL_LOCK(self):
        return self._press(<string>b"input keyevent --longpress 116")

    def short_press_KEYCODE_SCROLL_LOCK(self):
        return self._press(<string>b"input keyevent 116")

    def long_press_KEYCODE_META_LEFT(self):
        return self._press(<string>b"input keyevent --longpress 117")

    def short_press_KEYCODE_META_LEFT(self):
        return self._press(<string>b"input keyevent 117")

    def long_press_KEYCODE_META_RIGHT(self):
        return self._press(<string>b"input keyevent --longpress 118")

    def short_press_KEYCODE_META_RIGHT(self):
        return self._press(<string>b"input keyevent 118")

    def long_press_KEYCODE_FUNCTION(self):
        return self._press(<string>b"input keyevent --longpress 119")

    def short_press_KEYCODE_FUNCTION(self):
        return self._press(<string>b"input keyevent 119")

    def long_press_KEYCODE_SYSRQ(self):
        return self._press(<string>b"input keyevent --longpress 120")

    def short_press_KEYCODE_SYSRQ(self):
        return self._press(<string>b"input keyevent 120")

    def long_press_KEYCODE_BREAK(self):
        return self._press(<string>b"input keyevent --longpress 121")

    def short_press_KEYCODE_BREAK(self):
        return self._press(<string>b"input keyevent 121")

    def long_press_KEYCODE_MOVE_HOME(self):
        return self._press(<string>b"input keyevent --longpress 122")

    def short_press_KEYCODE_MOVE_HOME(self):
        return self._press(<string>b"input keyevent 122")

    def long_press_KEYCODE_MOVE_END(self):
        return self._press(<string>b"input keyevent --longpress 123")

    def short_press_KEYCODE_MOVE_END(self):
        return self._press(<string>b"input keyevent 123")

    def long_press_KEYCODE_INSERT(self):
        return self._press(<string>b"input keyevent --longpress 124")

    def short_press_KEYCODE_INSERT(self):
        return self._press(<string>b"input keyevent 124")

    def long_press_KEYCODE_FORWARD(self):
        return self._press(<string>b"input keyevent --longpress 125")

    def short_press_KEYCODE_FORWARD(self):
        return self._press(<string>b"input keyevent 125")

    def long_press_KEYCODE_MEDIA_PLAY(self):
        return self._press(<string>b"input keyevent --longpress 126")

    def short_press_KEYCODE_MEDIA_PLAY(self):
        return self._press(<string>b"input keyevent 126")

    def long_press_KEYCODE_MEDIA_PAUSE(self):
        return self._press(<string>b"input keyevent --longpress 127")

    def short_press_KEYCODE_MEDIA_PAUSE(self):
        return self._press(<string>b"input keyevent 127")

    def long_press_KEYCODE_MEDIA_CLOSE(self):
        return self._press(<string>b"input keyevent --longpress 128")

    def short_press_KEYCODE_MEDIA_CLOSE(self):
        return self._press(<string>b"input keyevent 128")

    def long_press_KEYCODE_MEDIA_EJECT(self):
        return self._press(<string>b"input keyevent --longpress 129")

    def short_press_KEYCODE_MEDIA_EJECT(self):
        return self._press(<string>b"input keyevent 129")

    def long_press_KEYCODE_MEDIA_RECORD(self):
        return self._press(<string>b"input keyevent --longpress 130")

    def short_press_KEYCODE_MEDIA_RECORD(self):
        return self._press(<string>b"input keyevent 130")

    def long_press_KEYCODE_F1(self):
        return self._press(<string>b"input keyevent --longpress 131")

    def short_press_KEYCODE_F1(self):
        return self._press(<string>b"input keyevent 131")

    def long_press_KEYCODE_F2(self):
        return self._press(<string>b"input keyevent --longpress 132")

    def short_press_KEYCODE_F2(self):
        return self._press(<string>b"input keyevent 132")

    def long_press_KEYCODE_F3(self):
        return self._press(<string>b"input keyevent --longpress 133")

    def short_press_KEYCODE_F3(self):
        return self._press(<string>b"input keyevent 133")

    def long_press_KEYCODE_F4(self):
        return self._press(<string>b"input keyevent --longpress 134")

    def short_press_KEYCODE_F4(self):
        return self._press(<string>b"input keyevent 134")

    def long_press_KEYCODE_F5(self):
        return self._press(<string>b"input keyevent --longpress 135")

    def short_press_KEYCODE_F5(self):
        return self._press(<string>b"input keyevent 135")

    def long_press_KEYCODE_F6(self):
        return self._press(<string>b"input keyevent --longpress 136")

    def short_press_KEYCODE_F6(self):
        return self._press(<string>b"input keyevent 136")

    def long_press_KEYCODE_F7(self):
        return self._press(<string>b"input keyevent --longpress 137")

    def short_press_KEYCODE_F7(self):
        return self._press(<string>b"input keyevent 137")

    def long_press_KEYCODE_F8(self):
        return self._press(<string>b"input keyevent --longpress 138")

    def short_press_KEYCODE_F8(self):
        return self._press(<string>b"input keyevent 138")

    def long_press_KEYCODE_F9(self):
        return self._press(<string>b"input keyevent --longpress 139")

    def short_press_KEYCODE_F9(self):
        return self._press(<string>b"input keyevent 139")

    def long_press_KEYCODE_F10(self):
        return self._press(<string>b"input keyevent --longpress 140")

    def short_press_KEYCODE_F10(self):
        return self._press(<string>b"input keyevent 140")

    def long_press_KEYCODE_F11(self):
        return self._press(<string>b"input keyevent --longpress 141")

    def short_press_KEYCODE_F11(self):
        return self._press(<string>b"input keyevent 141")

    def long_press_KEYCODE_F12(self):
        return self._press(<string>b"input keyevent --longpress 142")

    def short_press_KEYCODE_F12(self):
        return self._press(<string>b"input keyevent 142")

    def long_press_KEYCODE_NUM_LOCK(self):
        return self._press(<string>b"input keyevent --longpress 143")

    def short_press_KEYCODE_NUM_LOCK(self):
        return self._press(<string>b"input keyevent 143")

    def long_press_KEYCODE_NUMPAD_0(self):
        return self._press(<string>b"input keyevent --longpress 144")

    def short_press_KEYCODE_NUMPAD_0(self):
        return self._press(<string>b"input keyevent 144")

    def long_press_KEYCODE_NUMPAD_1(self):
        return self._press(<string>b"input keyevent --longpress 145")

    def short_press_KEYCODE_NUMPAD_1(self):
        return self._press(<string>b"input keyevent 145")

    def long_press_KEYCODE_NUMPAD_2(self):
        return self._press(<string>b"input keyevent --longpress 146")

    def short_press_KEYCODE_NUMPAD_2(self):
        return self._press(<string>b"input keyevent 146")

    def long_press_KEYCODE_NUMPAD_3(self):
        return self._press(<string>b"input keyevent --longpress 147")

    def short_press_KEYCODE_NUMPAD_3(self):
        return self._press(<string>b"input keyevent 147")

    def long_press_KEYCODE_NUMPAD_4(self):
        return self._press(<string>b"input keyevent --longpress 148")

    def short_press_KEYCODE_NUMPAD_4(self):
        return self._press(<string>b"input keyevent 148")

    def long_press_KEYCODE_NUMPAD_5(self):
        return self._press(<string>b"input keyevent --longpress 149")

    def short_press_KEYCODE_NUMPAD_5(self):
        return self._press(<string>b"input keyevent 149")

    def long_press_KEYCODE_NUMPAD_6(self):
        return self._press(<string>b"input keyevent --longpress 150")

    def short_press_KEYCODE_NUMPAD_6(self):
        return self._press(<string>b"input keyevent 150")

    def long_press_KEYCODE_NUMPAD_7(self):
        return self._press(<string>b"input keyevent --longpress 151")

    def short_press_KEYCODE_NUMPAD_7(self):
        return self._press(<string>b"input keyevent 151")

    def long_press_KEYCODE_NUMPAD_8(self):
        return self._press(<string>b"input keyevent --longpress 152")

    def short_press_KEYCODE_NUMPAD_8(self):
        return self._press(<string>b"input keyevent 152")

    def long_press_KEYCODE_NUMPAD_9(self):
        return self._press(<string>b"input keyevent --longpress 153")

    def short_press_KEYCODE_NUMPAD_9(self):
        return self._press(<string>b"input keyevent 153")

    def long_press_KEYCODE_NUMPAD_DIVIDE(self):
        return self._press(<string>b"input keyevent --longpress 154")

    def short_press_KEYCODE_NUMPAD_DIVIDE(self):
        return self._press(<string>b"input keyevent 154")

    def long_press_KEYCODE_NUMPAD_MULTIPLY(self):
        return self._press(<string>b"input keyevent --longpress 155")

    def short_press_KEYCODE_NUMPAD_MULTIPLY(self):
        return self._press(<string>b"input keyevent 155")

    def long_press_KEYCODE_NUMPAD_SUBTRACT(self):
        return self._press(<string>b"input keyevent --longpress 156")

    def short_press_KEYCODE_NUMPAD_SUBTRACT(self):
        return self._press(<string>b"input keyevent 156")

    def long_press_KEYCODE_NUMPAD_ADD(self):
        return self._press(<string>b"input keyevent --longpress 157")

    def short_press_KEYCODE_NUMPAD_ADD(self):
        return self._press(<string>b"input keyevent 157")

    def long_press_KEYCODE_NUMPAD_DOT(self):
        return self._press(<string>b"input keyevent --longpress 158")

    def short_press_KEYCODE_NUMPAD_DOT(self):
        return self._press(<string>b"input keyevent 158")

    def long_press_KEYCODE_NUMPAD_COMMA(self):
        return self._press(<string>b"input keyevent --longpress 159")

    def short_press_KEYCODE_NUMPAD_COMMA(self):
        return self._press(<string>b"input keyevent 159")

    def long_press_KEYCODE_NUMPAD_ENTER(self):
        return self._press(<string>b"input keyevent --longpress 160")

    def short_press_KEYCODE_NUMPAD_ENTER(self):
        return self._press(<string>b"input keyevent 160")

    def long_press_KEYCODE_NUMPAD_EQUALS(self):
        return self._press(<string>b"input keyevent --longpress 161")

    def short_press_KEYCODE_NUMPAD_EQUALS(self):
        return self._press(<string>b"input keyevent 161")

    def long_press_KEYCODE_NUMPAD_LEFT_PAREN(self):
        return self._press(<string>b"input keyevent --longpress 162")

    def short_press_KEYCODE_NUMPAD_LEFT_PAREN(self):
        return self._press(<string>b"input keyevent 162")

    def long_press_KEYCODE_NUMPAD_RIGHT_PAREN(self):
        return self._press(<string>b"input keyevent --longpress 163")

    def short_press_KEYCODE_NUMPAD_RIGHT_PAREN(self):
        return self._press(<string>b"input keyevent 163")

    def long_press_KEYCODE_VOLUME_MUTE(self):
        return self._press(<string>b"input keyevent --longpress 164")

    def short_press_KEYCODE_VOLUME_MUTE(self):
        return self._press(<string>b"input keyevent 164")

    def long_press_KEYCODE_INFO(self):
        return self._press(<string>b"input keyevent --longpress 165")

    def short_press_KEYCODE_INFO(self):
        return self._press(<string>b"input keyevent 165")

    def long_press_KEYCODE_CHANNEL_UP(self):
        return self._press(<string>b"input keyevent --longpress 166")

    def short_press_KEYCODE_CHANNEL_UP(self):
        return self._press(<string>b"input keyevent 166")

    def long_press_KEYCODE_CHANNEL_DOWN(self):
        return self._press(<string>b"input keyevent --longpress 167")

    def short_press_KEYCODE_CHANNEL_DOWN(self):
        return self._press(<string>b"input keyevent 167")

    def long_press_KEYCODE_ZOOM_IN(self):
        return self._press(<string>b"input keyevent --longpress 168")

    def short_press_KEYCODE_ZOOM_IN(self):
        return self._press(<string>b"input keyevent 168")

    def long_press_KEYCODE_ZOOM_OUT(self):
        return self._press(<string>b"input keyevent --longpress 169")

    def short_press_KEYCODE_ZOOM_OUT(self):
        return self._press(<string>b"input keyevent 169")

    def long_press_KEYCODE_TV(self):
        return self._press(<string>b"input keyevent --longpress 170")

    def short_press_KEYCODE_TV(self):
        return self._press(<string>b"input keyevent 170")

    def long_press_KEYCODE_WINDOW(self):
        return self._press(<string>b"input keyevent --longpress 171")

    def short_press_KEYCODE_WINDOW(self):
        return self._press(<string>b"input keyevent 171")

    def long_press_KEYCODE_GUIDE(self):
        return self._press(<string>b"input keyevent --longpress 172")

    def short_press_KEYCODE_GUIDE(self):
        return self._press(<string>b"input keyevent 172")

    def long_press_KEYCODE_DVR(self):
        return self._press(<string>b"input keyevent --longpress 173")

    def short_press_KEYCODE_DVR(self):
        return self._press(<string>b"input keyevent 173")

    def long_press_KEYCODE_BOOKMARK(self):
        return self._press(<string>b"input keyevent --longpress 174")

    def short_press_KEYCODE_BOOKMARK(self):
        return self._press(<string>b"input keyevent 174")

    def long_press_KEYCODE_CAPTIONS(self):
        return self._press(<string>b"input keyevent --longpress 175")

    def short_press_KEYCODE_CAPTIONS(self):
        return self._press(<string>b"input keyevent 175")

    def long_press_KEYCODE_SETTINGS(self):
        return self._press(<string>b"input keyevent --longpress 176")

    def short_press_KEYCODE_SETTINGS(self):
        return self._press(<string>b"input keyevent 176")

    def long_press_KEYCODE_TV_POWER(self):
        return self._press(<string>b"input keyevent --longpress 177")

    def short_press_KEYCODE_TV_POWER(self):
        return self._press(<string>b"input keyevent 177")

    def long_press_KEYCODE_TV_INPUT(self):
        return self._press(<string>b"input keyevent --longpress 178")

    def short_press_KEYCODE_TV_INPUT(self):
        return self._press(<string>b"input keyevent 178")

    def long_press_KEYCODE_STB_POWER(self):
        return self._press(<string>b"input keyevent --longpress 179")

    def short_press_KEYCODE_STB_POWER(self):
        return self._press(<string>b"input keyevent 179")

    def long_press_KEYCODE_STB_INPUT(self):
        return self._press(<string>b"input keyevent --longpress 180")

    def short_press_KEYCODE_STB_INPUT(self):
        return self._press(<string>b"input keyevent 180")

    def long_press_KEYCODE_AVR_POWER(self):
        return self._press(<string>b"input keyevent --longpress 181")

    def short_press_KEYCODE_AVR_POWER(self):
        return self._press(<string>b"input keyevent 181")

    def long_press_KEYCODE_AVR_INPUT(self):
        return self._press(<string>b"input keyevent --longpress 182")

    def short_press_KEYCODE_AVR_INPUT(self):
        return self._press(<string>b"input keyevent 182")

    def long_press_KEYCODE_PROG_RED(self):
        return self._press(<string>b"input keyevent --longpress 183")

    def short_press_KEYCODE_PROG_RED(self):
        return self._press(<string>b"input keyevent 183")

    def long_press_KEYCODE_PROG_GREEN(self):
        return self._press(<string>b"input keyevent --longpress 184")

    def short_press_KEYCODE_PROG_GREEN(self):
        return self._press(<string>b"input keyevent 184")

    def long_press_KEYCODE_PROG_YELLOW(self):
        return self._press(<string>b"input keyevent --longpress 185")

    def short_press_KEYCODE_PROG_YELLOW(self):
        return self._press(<string>b"input keyevent 185")

    def long_press_KEYCODE_PROG_BLUE(self):
        return self._press(<string>b"input keyevent --longpress 186")

    def short_press_KEYCODE_PROG_BLUE(self):
        return self._press(<string>b"input keyevent 186")

    def long_press_KEYCODE_APP_SWITCH(self):
        return self._press(<string>b"input keyevent --longpress 187")

    def short_press_KEYCODE_APP_SWITCH(self):
        return self._press(<string>b"input keyevent 187")

    def long_press_KEYCODE_BUTTON_1(self):
        return self._press(<string>b"input keyevent --longpress 188")

    def short_press_KEYCODE_BUTTON_1(self):
        return self._press(<string>b"input keyevent 188")

    def long_press_KEYCODE_BUTTON_2(self):
        return self._press(<string>b"input keyevent --longpress 189")

    def short_press_KEYCODE_BUTTON_2(self):
        return self._press(<string>b"input keyevent 189")

    def long_press_KEYCODE_BUTTON_3(self):
        return self._press(<string>b"input keyevent --longpress 190")

    def short_press_KEYCODE_BUTTON_3(self):
        return self._press(<string>b"input keyevent 190")

    def long_press_KEYCODE_BUTTON_4(self):
        return self._press(<string>b"input keyevent --longpress 191")

    def short_press_KEYCODE_BUTTON_4(self):
        return self._press(<string>b"input keyevent 191")

    def long_press_KEYCODE_BUTTON_5(self):
        return self._press(<string>b"input keyevent --longpress 192")

    def short_press_KEYCODE_BUTTON_5(self):
        return self._press(<string>b"input keyevent 192")

    def long_press_KEYCODE_BUTTON_6(self):
        return self._press(<string>b"input keyevent --longpress 193")

    def short_press_KEYCODE_BUTTON_6(self):
        return self._press(<string>b"input keyevent 193")

    def long_press_KEYCODE_BUTTON_7(self):
        return self._press(<string>b"input keyevent --longpress 194")

    def short_press_KEYCODE_BUTTON_7(self):
        return self._press(<string>b"input keyevent 194")

    def long_press_KEYCODE_BUTTON_8(self):
        return self._press(<string>b"input keyevent --longpress 195")

    def short_press_KEYCODE_BUTTON_8(self):
        return self._press(<string>b"input keyevent 195")

    def long_press_KEYCODE_BUTTON_9(self):
        return self._press(<string>b"input keyevent --longpress 196")

    def short_press_KEYCODE_BUTTON_9(self):
        return self._press(<string>b"input keyevent 196")

    def long_press_KEYCODE_BUTTON_10(self):
        return self._press(<string>b"input keyevent --longpress 197")

    def short_press_KEYCODE_BUTTON_10(self):
        return self._press(<string>b"input keyevent 197")

    def long_press_KEYCODE_BUTTON_11(self):
        return self._press(<string>b"input keyevent --longpress 198")

    def short_press_KEYCODE_BUTTON_11(self):
        return self._press(<string>b"input keyevent 198")

    def long_press_KEYCODE_BUTTON_12(self):
        return self._press(<string>b"input keyevent --longpress 199")

    def short_press_KEYCODE_BUTTON_12(self):
        return self._press(<string>b"input keyevent 199")

    def long_press_KEYCODE_BUTTON_13(self):
        return self._press(<string>b"input keyevent --longpress 200")

    def short_press_KEYCODE_BUTTON_13(self):
        return self._press(<string>b"input keyevent 200")

    def long_press_KEYCODE_BUTTON_14(self):
        return self._press(<string>b"input keyevent --longpress 201")

    def short_press_KEYCODE_BUTTON_14(self):
        return self._press(<string>b"input keyevent 201")

    def long_press_KEYCODE_BUTTON_15(self):
        return self._press(<string>b"input keyevent --longpress 202")

    def short_press_KEYCODE_BUTTON_15(self):
        return self._press(<string>b"input keyevent 202")

    def long_press_KEYCODE_BUTTON_16(self):
        return self._press(<string>b"input keyevent --longpress 203")

    def short_press_KEYCODE_BUTTON_16(self):
        return self._press(<string>b"input keyevent 203")

    def long_press_KEYCODE_LANGUAGE_SWITCH(self):
        return self._press(<string>b"input keyevent --longpress 204")

    def short_press_KEYCODE_LANGUAGE_SWITCH(self):
        return self._press(<string>b"input keyevent 204")

    def long_press_KEYCODE_MANNER_MODE(self):
        return self._press(<string>b"input keyevent --longpress 205")

    def short_press_KEYCODE_MANNER_MODE(self):
        return self._press(<string>b"input keyevent 205")

    def long_press_KEYCODE_3D_MODE(self):
        return self._press(<string>b"input keyevent --longpress 206")

    def short_press_KEYCODE_3D_MODE(self):
        return self._press(<string>b"input keyevent 206")

    def long_press_KEYCODE_CONTACTS(self):
        return self._press(<string>b"input keyevent --longpress 207")

    def short_press_KEYCODE_CONTACTS(self):
        return self._press(<string>b"input keyevent 207")

    def long_press_KEYCODE_CALENDAR(self):
        return self._press(<string>b"input keyevent --longpress 208")

    def short_press_KEYCODE_CALENDAR(self):
        return self._press(<string>b"input keyevent 208")

    def long_press_KEYCODE_MUSIC(self):
        return self._press(<string>b"input keyevent --longpress 209")

    def short_press_KEYCODE_MUSIC(self):
        return self._press(<string>b"input keyevent 209")

    def long_press_KEYCODE_CALCULATOR(self):
        return self._press(<string>b"input keyevent --longpress 210")

    def short_press_KEYCODE_CALCULATOR(self):
        return self._press(<string>b"input keyevent 210")

    def long_press_KEYCODE_ZENKAKU_HANKAKU(self):
        return self._press(<string>b"input keyevent --longpress 211")

    def short_press_KEYCODE_ZENKAKU_HANKAKU(self):
        return self._press(<string>b"input keyevent 211")

    def long_press_KEYCODE_EISU(self):
        return self._press(<string>b"input keyevent --longpress 212")

    def short_press_KEYCODE_EISU(self):
        return self._press(<string>b"input keyevent 212")

    def long_press_KEYCODE_MUHENKAN(self):
        return self._press(<string>b"input keyevent --longpress 213")

    def short_press_KEYCODE_MUHENKAN(self):
        return self._press(<string>b"input keyevent 213")

    def long_press_KEYCODE_HENKAN(self):
        return self._press(<string>b"input keyevent --longpress 214")

    def short_press_KEYCODE_HENKAN(self):
        return self._press(<string>b"input keyevent 214")

    def long_press_KEYCODE_KATAKANA_HIRAGANA(self):
        return self._press(<string>b"input keyevent --longpress 215")

    def short_press_KEYCODE_KATAKANA_HIRAGANA(self):
        return self._press(<string>b"input keyevent 215")

    def long_press_KEYCODE_YEN(self):
        return self._press(<string>b"input keyevent --longpress 216")

    def short_press_KEYCODE_YEN(self):
        return self._press(<string>b"input keyevent 216")

    def long_press_KEYCODE_RO(self):
        return self._press(<string>b"input keyevent --longpress 217")

    def short_press_KEYCODE_RO(self):
        return self._press(<string>b"input keyevent 217")

    def long_press_KEYCODE_KANA(self):
        return self._press(<string>b"input keyevent --longpress 218")

    def short_press_KEYCODE_KANA(self):
        return self._press(<string>b"input keyevent 218")

    def long_press_KEYCODE_ASSIST(self):
        return self._press(<string>b"input keyevent --longpress 219")

    def short_press_KEYCODE_ASSIST(self):
        return self._press(<string>b"input keyevent 219")

    def long_press_KEYCODE_BRIGHTNESS_DOWN(self):
        return self._press(<string>b"input keyevent --longpress 220")

    def short_press_KEYCODE_BRIGHTNESS_DOWN(self):
        return self._press(<string>b"input keyevent 220")

    def long_press_KEYCODE_BRIGHTNESS_UP(self):
        return self._press(<string>b"input keyevent --longpress 221")

    def short_press_KEYCODE_BRIGHTNESS_UP(self):
        return self._press(<string>b"input keyevent 221")

    def long_press_KEYCODE_MEDIA_AUDIO_TRACK(self):
        return self._press(<string>b"input keyevent --longpress 222")

    def short_press_KEYCODE_MEDIA_AUDIO_TRACK(self):
        return self._press(<string>b"input keyevent 222")

    def long_press_KEYCODE_SLEEP(self):
        return self._press(<string>b"input keyevent --longpress 223")

    def short_press_KEYCODE_SLEEP(self):
        return self._press(<string>b"input keyevent 223")

    def long_press_KEYCODE_WAKEUP(self):
        return self._press(<string>b"input keyevent --longpress 224")

    def short_press_KEYCODE_WAKEUP(self):
        return self._press(<string>b"input keyevent 224")

    def long_press_KEYCODE_PAIRING(self):
        return self._press(<string>b"input keyevent --longpress 225")

    def short_press_KEYCODE_PAIRING(self):
        return self._press(<string>b"input keyevent 225")

    def long_press_KEYCODE_MEDIA_TOP_MENU(self):
        return self._press(<string>b"input keyevent --longpress 226")

    def short_press_KEYCODE_MEDIA_TOP_MENU(self):
        return self._press(<string>b"input keyevent 226")

    def long_press_KEYCODE_11(self):
        return self._press(<string>b"input keyevent --longpress 227")

    def short_press_KEYCODE_11(self):
        return self._press(<string>b"input keyevent 227")

    def long_press_KEYCODE_12(self):
        return self._press(<string>b"input keyevent --longpress 228")

    def short_press_KEYCODE_12(self):
        return self._press(<string>b"input keyevent 228")

    def long_press_KEYCODE_LAST_CHANNEL(self):
        return self._press(<string>b"input keyevent --longpress 229")

    def short_press_KEYCODE_LAST_CHANNEL(self):
        return self._press(<string>b"input keyevent 229")

    def long_press_KEYCODE_TV_DATA_SERVICE(self):
        return self._press(<string>b"input keyevent --longpress 230")

    def short_press_KEYCODE_TV_DATA_SERVICE(self):
        return self._press(<string>b"input keyevent 230")

    def long_press_KEYCODE_VOICE_ASSIST(self):
        return self._press(<string>b"input keyevent --longpress 231")

    def short_press_KEYCODE_VOICE_ASSIST(self):
        return self._press(<string>b"input keyevent 231")

    def long_press_KEYCODE_TV_RADIO_SERVICE(self):
        return self._press(<string>b"input keyevent --longpress 232")

    def short_press_KEYCODE_TV_RADIO_SERVICE(self):
        return self._press(<string>b"input keyevent 232")

    def long_press_KEYCODE_TV_TELETEXT(self):
        return self._press(<string>b"input keyevent --longpress 233")

    def short_press_KEYCODE_TV_TELETEXT(self):
        return self._press(<string>b"input keyevent 233")

    def long_press_KEYCODE_TV_NUMBER_ENTRY(self):
        return self._press(<string>b"input keyevent --longpress 234")

    def short_press_KEYCODE_TV_NUMBER_ENTRY(self):
        return self._press(<string>b"input keyevent 234")

    def long_press_KEYCODE_TV_TERRESTRIAL_ANALOG(self):
        return self._press(<string>b"input keyevent --longpress 235")

    def short_press_KEYCODE_TV_TERRESTRIAL_ANALOG(self):
        return self._press(<string>b"input keyevent 235")

    def long_press_KEYCODE_TV_TERRESTRIAL_DIGITAL(self):
        return self._press(<string>b"input keyevent --longpress 236")

    def short_press_KEYCODE_TV_TERRESTRIAL_DIGITAL(self):
        return self._press(<string>b"input keyevent 236")

    def long_press_KEYCODE_TV_SATELLITE(self):
        return self._press(<string>b"input keyevent --longpress 237")

    def short_press_KEYCODE_TV_SATELLITE(self):
        return self._press(<string>b"input keyevent 237")

    def long_press_KEYCODE_TV_SATELLITE_BS(self):
        return self._press(<string>b"input keyevent --longpress 238")

    def short_press_KEYCODE_TV_SATELLITE_BS(self):
        return self._press(<string>b"input keyevent 238")

    def long_press_KEYCODE_TV_SATELLITE_CS(self):
        return self._press(<string>b"input keyevent --longpress 239")

    def short_press_KEYCODE_TV_SATELLITE_CS(self):
        return self._press(<string>b"input keyevent 239")

    def long_press_KEYCODE_TV_SATELLITE_SERVICE(self):
        return self._press(<string>b"input keyevent --longpress 240")

    def short_press_KEYCODE_TV_SATELLITE_SERVICE(self):
        return self._press(<string>b"input keyevent 240")

    def long_press_KEYCODE_TV_NETWORK(self):
        return self._press(<string>b"input keyevent --longpress 241")

    def short_press_KEYCODE_TV_NETWORK(self):
        return self._press(<string>b"input keyevent 241")

    def long_press_KEYCODE_TV_ANTENNA_CABLE(self):
        return self._press(<string>b"input keyevent --longpress 242")

    def short_press_KEYCODE_TV_ANTENNA_CABLE(self):
        return self._press(<string>b"input keyevent 242")

    def long_press_KEYCODE_TV_INPUT_HDMI_1(self):
        return self._press(<string>b"input keyevent --longpress 243")

    def short_press_KEYCODE_TV_INPUT_HDMI_1(self):
        return self._press(<string>b"input keyevent 243")

    def long_press_KEYCODE_TV_INPUT_HDMI_2(self):
        return self._press(<string>b"input keyevent --longpress 244")

    def short_press_KEYCODE_TV_INPUT_HDMI_2(self):
        return self._press(<string>b"input keyevent 244")

    def long_press_KEYCODE_TV_INPUT_HDMI_3(self):
        return self._press(<string>b"input keyevent --longpress 245")

    def short_press_KEYCODE_TV_INPUT_HDMI_3(self):
        return self._press(<string>b"input keyevent 245")

    def long_press_KEYCODE_TV_INPUT_HDMI_4(self):
        return self._press(<string>b"input keyevent --longpress 246")

    def short_press_KEYCODE_TV_INPUT_HDMI_4(self):
        return self._press(<string>b"input keyevent 246")

    def long_press_KEYCODE_TV_INPUT_COMPOSITE_1(self):
        return self._press(<string>b"input keyevent --longpress 247")

    def short_press_KEYCODE_TV_INPUT_COMPOSITE_1(self):
        return self._press(<string>b"input keyevent 247")

    def long_press_KEYCODE_TV_INPUT_COMPOSITE_2(self):
        return self._press(<string>b"input keyevent --longpress 248")

    def short_press_KEYCODE_TV_INPUT_COMPOSITE_2(self):
        return self._press(<string>b"input keyevent 248")

    def long_press_KEYCODE_TV_INPUT_COMPONENT_1(self):
        return self._press(<string>b"input keyevent --longpress 249")

    def short_press_KEYCODE_TV_INPUT_COMPONENT_1(self):
        return self._press(<string>b"input keyevent 249")

    def long_press_KEYCODE_TV_INPUT_COMPONENT_2(self):
        return self._press(<string>b"input keyevent --longpress 250")

    def short_press_KEYCODE_TV_INPUT_COMPONENT_2(self):
        return self._press(<string>b"input keyevent 250")

    def long_press_KEYCODE_TV_INPUT_VGA_1(self):
        return self._press(<string>b"input keyevent --longpress 251")

    def short_press_KEYCODE_TV_INPUT_VGA_1(self):
        return self._press(<string>b"input keyevent 251")

    def long_press_KEYCODE_TV_AUDIO_DESCRIPTION(self):
        return self._press(<string>b"input keyevent --longpress 252")

    def short_press_KEYCODE_TV_AUDIO_DESCRIPTION(self):
        return self._press(<string>b"input keyevent 252")

    def long_press_KEYCODE_TV_AUDIO_DESCRIPTION_MIX_UP(self):
        return self._press(<string>b"input keyevent --longpress 253")

    def short_press_KEYCODE_TV_AUDIO_DESCRIPTION_MIX_UP(self):
        return self._press(<string>b"input keyevent 253")

    def long_press_KEYCODE_TV_AUDIO_DESCRIPTION_MIX_DOWN(self):
        return self._press(<string>b"input keyevent --longpress 254")

    def short_press_KEYCODE_TV_AUDIO_DESCRIPTION_MIX_DOWN(self):
        return self._press(<string>b"input keyevent 254")

    def long_press_KEYCODE_TV_ZOOM_MODE(self):
        return self._press(<string>b"input keyevent --longpress 255")

    def short_press_KEYCODE_TV_ZOOM_MODE(self):
        return self._press(<string>b"input keyevent 255")

    def long_press_KEYCODE_TV_CONTENTS_MENU(self):
        return self._press(<string>b"input keyevent --longpress 256")

    def short_press_KEYCODE_TV_CONTENTS_MENU(self):
        return self._press(<string>b"input keyevent 256")

    def long_press_KEYCODE_TV_MEDIA_CONTEXT_MENU(self):
        return self._press(<string>b"input keyevent --longpress 257")

    def short_press_KEYCODE_TV_MEDIA_CONTEXT_MENU(self):
        return self._press(<string>b"input keyevent 257")

    def long_press_KEYCODE_TV_TIMER_PROGRAMMING(self):
        return self._press(<string>b"input keyevent --longpress 258")

    def short_press_KEYCODE_TV_TIMER_PROGRAMMING(self):
        return self._press(<string>b"input keyevent 258")

    def long_press_KEYCODE_HELP(self):
        return self._press(<string>b"input keyevent --longpress 259")

    def short_press_KEYCODE_HELP(self):
        return self._press(<string>b"input keyevent 259")

    def long_press_KEYCODE_NAVIGATE_PREVIOUS(self):
        return self._press(<string>b"input keyevent --longpress 260")

    def short_press_KEYCODE_NAVIGATE_PREVIOUS(self):
        return self._press(<string>b"input keyevent 260")

    def long_press_KEYCODE_NAVIGATE_NEXT(self):
        return self._press(<string>b"input keyevent --longpress 261")

    def short_press_KEYCODE_NAVIGATE_NEXT(self):
        return self._press(<string>b"input keyevent 261")

    def long_press_KEYCODE_NAVIGATE_IN(self):
        return self._press(<string>b"input keyevent --longpress 262")

    def short_press_KEYCODE_NAVIGATE_IN(self):
        return self._press(<string>b"input keyevent 262")

    def long_press_KEYCODE_NAVIGATE_OUT(self):
        return self._press(<string>b"input keyevent --longpress 263")

    def short_press_KEYCODE_NAVIGATE_OUT(self):
        return self._press(<string>b"input keyevent 263")

    def long_press_KEYCODE_STEM_PRIMARY(self):
        return self._press(<string>b"input keyevent --longpress 264")

    def short_press_KEYCODE_STEM_PRIMARY(self):
        return self._press(<string>b"input keyevent 264")

    def long_press_KEYCODE_STEM_1(self):
        return self._press(<string>b"input keyevent --longpress 265")

    def short_press_KEYCODE_STEM_1(self):
        return self._press(<string>b"input keyevent 265")

    def long_press_KEYCODE_STEM_2(self):
        return self._press(<string>b"input keyevent --longpress 266")

    def short_press_KEYCODE_STEM_2(self):
        return self._press(<string>b"input keyevent 266")

    def long_press_KEYCODE_STEM_3(self):
        return self._press(<string>b"input keyevent --longpress 267")

    def short_press_KEYCODE_STEM_3(self):
        return self._press(<string>b"input keyevent 267")

    def long_press_KEYCODE_DPAD_UP_LEFT(self):
        return self._press(<string>b"input keyevent --longpress 268")

    def short_press_KEYCODE_DPAD_UP_LEFT(self):
        return self._press(<string>b"input keyevent 268")

    def long_press_KEYCODE_DPAD_DOWN_LEFT(self):
        return self._press(<string>b"input keyevent --longpress 269")

    def short_press_KEYCODE_DPAD_DOWN_LEFT(self):
        return self._press(<string>b"input keyevent 269")

    def long_press_KEYCODE_DPAD_UP_RIGHT(self):
        return self._press(<string>b"input keyevent --longpress 270")

    def short_press_KEYCODE_DPAD_UP_RIGHT(self):
        return self._press(<string>b"input keyevent 270")

    def long_press_KEYCODE_DPAD_DOWN_RIGHT(self):
        return self._press(<string>b"input keyevent --longpress 271")

    def short_press_KEYCODE_DPAD_DOWN_RIGHT(self):
        return self._press(<string>b"input keyevent 271")

    def long_press_KEYCODE_MEDIA_SKIP_FORWARD(self):
        return self._press(<string>b"input keyevent --longpress 272")

    def short_press_KEYCODE_MEDIA_SKIP_FORWARD(self):
        return self._press(<string>b"input keyevent 272")

    def long_press_KEYCODE_MEDIA_SKIP_BACKWARD(self):
        return self._press(<string>b"input keyevent --longpress 273")

    def short_press_KEYCODE_MEDIA_SKIP_BACKWARD(self):
        return self._press(<string>b"input keyevent 273")

    def long_press_KEYCODE_MEDIA_STEP_FORWARD(self):
        return self._press(<string>b"input keyevent --longpress 274")

    def short_press_KEYCODE_MEDIA_STEP_FORWARD(self):
        return self._press(<string>b"input keyevent 274")

    def long_press_KEYCODE_MEDIA_STEP_BACKWARD(self):
        return self._press(<string>b"input keyevent --longpress 275")

    def short_press_KEYCODE_MEDIA_STEP_BACKWARD(self):
        return self._press(<string>b"input keyevent 275")

    def long_press_KEYCODE_SOFT_SLEEP(self):
        return self._press(<string>b"input keyevent --longpress 276")

    def short_press_KEYCODE_SOFT_SLEEP(self):
        return self._press(<string>b"input keyevent 276")

    def long_press_KEYCODE_CUT(self):
        return self._press(<string>b"input keyevent --longpress 277")

    def short_press_KEYCODE_CUT(self):
        return self._press(<string>b"input keyevent 277")

    def long_press_KEYCODE_COPY(self):
        return self._press(<string>b"input keyevent --longpress 278")

    def short_press_KEYCODE_COPY(self):
        return self._press(<string>b"input keyevent 278")

    def long_press_KEYCODE_PASTE(self):
        return self._press(<string>b"input keyevent --longpress 279")

    def short_press_KEYCODE_PASTE(self):
        return self._press(<string>b"input keyevent 279")

    def long_press_KEYCODE_SYSTEM_NAVIGATION_UP(self):
        return self._press(<string>b"input keyevent --longpress 280")

    def short_press_KEYCODE_SYSTEM_NAVIGATION_UP(self):
        return self._press(<string>b"input keyevent 280")

    def long_press_KEYCODE_SYSTEM_NAVIGATION_DOWN(self):
        return self._press(<string>b"input keyevent --longpress 281")

    def short_press_KEYCODE_SYSTEM_NAVIGATION_DOWN(self):
        return self._press(<string>b"input keyevent 281")

    def long_press_KEYCODE_SYSTEM_NAVIGATION_LEFT(self):
        return self._press(<string>b"input keyevent --longpress 282")

    def short_press_KEYCODE_SYSTEM_NAVIGATION_LEFT(self):
        return self._press(<string>b"input keyevent 282")

    def long_press_KEYCODE_SYSTEM_NAVIGATION_RIGHT(self):
        return self._press(<string>b"input keyevent --longpress 283")

    def short_press_KEYCODE_SYSTEM_NAVIGATION_RIGHT(self):
        return self._press(<string>b"input keyevent 283")

    def long_press_KEYCODE_ALL_APPS(self):
        return self._press(<string>b"input keyevent --longpress 284")

    def short_press_KEYCODE_ALL_APPS(self):
        return self._press(<string>b"input keyevent 284")

    def long_press_KEYCODE_REFRESH(self):
        return self._press(<string>b"input keyevent --longpress 285")

    def short_press_KEYCODE_REFRESH(self):
        return self._press(<string>b"input keyevent 285")

    def long_press_KEYCODE_THUMBS_UP(self):
        return self._press(<string>b"input keyevent --longpress 286")

    def short_press_KEYCODE_THUMBS_UP(self):
        return self._press(<string>b"input keyevent 286")

    def long_press_KEYCODE_THUMBS_DOWN(self):
        return self._press(<string>b"input keyevent --longpress 287")

    def short_press_KEYCODE_THUMBS_DOWN(self):
        return self._press(<string>b"input keyevent 287")

    def long_press_KEYCODE_PROFILE_SWITCH(self):
        return self._press(<string>b"input keyevent --longpress 288")

    def short_press_KEYCODE_PROFILE_SWITCH(self):
        return self._press(<string>b"input keyevent 288")

    def long_press_KEYCODE_VIDEO_APP_1(self):
        return self._press(<string>b"input keyevent --longpress 289")

    def short_press_KEYCODE_VIDEO_APP_1(self):
        return self._press(<string>b"input keyevent 289")

    def long_press_KEYCODE_VIDEO_APP_2(self):
        return self._press(<string>b"input keyevent --longpress 290")

    def short_press_KEYCODE_VIDEO_APP_2(self):
        return self._press(<string>b"input keyevent 290")

    def long_press_KEYCODE_VIDEO_APP_3(self):
        return self._press(<string>b"input keyevent --longpress 291")

    def short_press_KEYCODE_VIDEO_APP_3(self):
        return self._press(<string>b"input keyevent 291")

    def long_press_KEYCODE_VIDEO_APP_4(self):
        return self._press(<string>b"input keyevent --longpress 292")

    def short_press_KEYCODE_VIDEO_APP_4(self):
        return self._press(<string>b"input keyevent 292")

    def long_press_KEYCODE_VIDEO_APP_5(self):
        return self._press(<string>b"input keyevent --longpress 293")

    def short_press_KEYCODE_VIDEO_APP_5(self):
        return self._press(<string>b"input keyevent 293")

    def long_press_KEYCODE_VIDEO_APP_6(self):
        return self._press(<string>b"input keyevent --longpress 294")

    def short_press_KEYCODE_VIDEO_APP_6(self):
        return self._press(<string>b"input keyevent 294")

    def long_press_KEYCODE_VIDEO_APP_7(self):
        return self._press(<string>b"input keyevent --longpress 295")

    def short_press_KEYCODE_VIDEO_APP_7(self):
        return self._press(<string>b"input keyevent 295")

    def long_press_KEYCODE_VIDEO_APP_8(self):
        return self._press(<string>b"input keyevent --longpress 296")

    def short_press_KEYCODE_VIDEO_APP_8(self):
        return self._press(<string>b"input keyevent 296")

    def long_press_KEYCODE_FEATURED_APP_1(self):
        return self._press(<string>b"input keyevent --longpress 297")

    def short_press_KEYCODE_FEATURED_APP_1(self):
        return self._press(<string>b"input keyevent 297")

    def long_press_KEYCODE_FEATURED_APP_2(self):
        return self._press(<string>b"input keyevent --longpress 298")

    def short_press_KEYCODE_FEATURED_APP_2(self):
        return self._press(<string>b"input keyevent 298")

    def long_press_KEYCODE_FEATURED_APP_3(self):
        return self._press(<string>b"input keyevent --longpress 299")

    def short_press_KEYCODE_FEATURED_APP_3(self):
        return self._press(<string>b"input keyevent 299")

    def long_press_KEYCODE_FEATURED_APP_4(self):
        return self._press(<string>b"input keyevent --longpress 300")

    def short_press_KEYCODE_FEATURED_APP_4(self):
        return self._press(<string>b"input keyevent 300")

    def long_press_KEYCODE_DEMO_APP_1(self):
        return self._press(<string>b"input keyevent --longpress 301")

    def short_press_KEYCODE_DEMO_APP_1(self):
        return self._press(<string>b"input keyevent 301")

    def long_press_KEYCODE_DEMO_APP_2(self):
        return self._press(<string>b"input keyevent --longpress 302")

    def short_press_KEYCODE_DEMO_APP_2(self):
        return self._press(<string>b"input keyevent 302")

    def long_press_KEYCODE_DEMO_APP_3(self):
        return self._press(<string>b"input keyevent --longpress 303")

    def short_press_KEYCODE_DEMO_APP_3(self):
        return self._press(<string>b"input keyevent 303")

    def long_press_KEYCODE_DEMO_APP_4(self):
        return self._press(<string>b"input keyevent --longpress 304")

    def short_press_KEYCODE_DEMO_APP_4(self):
        return self._press(<string>b"input keyevent 304")


cdef:
    dict letter_lookup_dict = {}
    dict[str,str] mappingdict = {
    " ": "KEY_SPACE:ud:%s",
    "!": "KEY_LEFTSHIFT:d:0#KEY_1:ud:%s#KEY_LEFTSHIFT:u:0",
    "'": "KEY_APOSTROPHE:ud:%s",
    '"': "KEY_LEFTSHIFT:d:0#KEY_APOSTROPHE:ud:%s#KEY_LEFTSHIFT:u:0",
    "#": "KEY_LEFTSHIFT:d:0#KEY_3:ud:%s#KEY_LEFTSHIFT:u:0",
    "$": "KEY_LEFTSHIFT:d:0#KEY_4:ud:%s#KEY_LEFTSHIFT:u:0",
    "%": "KEY_LEFTSHIFT:d:0#KEY_5:ud:%s#KEY_LEFTSHIFT:u:0",
    "&": "KEY_LEFTSHIFT:d:0#KEY_7:ud:%s#KEY_LEFTSHIFT:u:0",
    "(": "KEY_LEFTSHIFT:d:0#KEY_9:ud:%s#KEY_LEFTSHIFT:u:0",
    ")": "KEY_LEFTSHIFT:d:0#KEY_0:ud:%s#KEY_LEFTSHIFT:u:0",
    "*": "KEY_LEFTSHIFT:d:0#KEY_8:ud:%s#KEY_LEFTSHIFT:u:0",
    "+": "KEY_KPPLUS:ud:%s",
    ",": "KEY_COMMA:ud:%s",
    "-": "KEY_MINUS:ud:%s",
    ".": "KEY_DOT:ud:%s",
    "/": "KEY_SLASH:ud:%s",
    "0": "KEY_0:ud:%s",
    "1": "KEY_1:ud:%s",
    "2": "KEY_2:ud:%s",
    "3": "KEY_3:ud:%s",
    "4": "KEY_4:ud:%s",
    "5": "KEY_5:ud:%s",
    "6": "KEY_6:ud:%s",
    "7": "KEY_7:ud:%s",
    "8": "KEY_8:ud:%s",
    "9": "KEY_9:ud:%s",
    ":": "KEY_LEFTSHIFT:d:0#KEY_SEMICOLON:ud:%s#KEY_LEFTSHIFT:u:0",
    ";": "KEY_SEMICOLON:ud:%s",
    "<": "KEY_LEFTSHIFT:d:0#KEY_COMMA:ud:%s#KEY_LEFTSHIFT:u:0",
    "=": "KEY_EQUAL:ud:%s",
    ">": "KEY_LEFTSHIFT:d:0#KEY_DOT:ud:%s#KEY_LEFTSHIFT:u:0",
    "?": "KEY_QUESTION:ud:%s",
    "@": "KEY_LEFTSHIFT:d:0#KEY_2:ud:%s#KEY_LEFTSHIFT:u:0",
    "A": "KEY_LEFTSHIFT:d:0#KEY_A:ud:%s#KEY_LEFTSHIFT:u:0",
    "B": "KEY_LEFTSHIFT:d:0#KEY_B:ud:%s#KEY_LEFTSHIFT:u:0",
    "C": "KEY_LEFTSHIFT:d:0#KEY_C:ud:%s#KEY_LEFTSHIFT:u:0",
    "D": "KEY_LEFTSHIFT:d:0#KEY_D:ud:%s#KEY_LEFTSHIFT:u:0",
    "E": "KEY_LEFTSHIFT:d:0#KEY_E:ud:%s#KEY_LEFTSHIFT:u:0",
    "F": "KEY_LEFTSHIFT:d:0#KEY_F:ud:%s#KEY_LEFTSHIFT:u:0",
    "G": "KEY_LEFTSHIFT:d:0#KEY_G:ud:%s#KEY_LEFTSHIFT:u:0",
    "H": "KEY_LEFTSHIFT:d:0#KEY_H:ud:%s#KEY_LEFTSHIFT:u:0",
    "I": "KEY_LEFTSHIFT:d:0#KEY_I:ud:%s#KEY_LEFTSHIFT:u:0",
    "J": "KEY_LEFTSHIFT:d:0#KEY_J:ud:%s#KEY_LEFTSHIFT:u:0",
    "K": "KEY_LEFTSHIFT:d:0#KEY_K:ud:%s#KEY_LEFTSHIFT:u:0",
    "L": "KEY_LEFTSHIFT:d:0#KEY_L:ud:%s#KEY_LEFTSHIFT:u:0",
    "M": "KEY_LEFTSHIFT:d:0#KEY_M:ud:%s#KEY_LEFTSHIFT:u:0",
    "N": "KEY_LEFTSHIFT:d:0#KEY_N:ud:%s#KEY_LEFTSHIFT:u:0",
    "O": "KEY_LEFTSHIFT:d:0#KEY_O:ud:%s#KEY_LEFTSHIFT:u:0",
    "P": "KEY_LEFTSHIFT:d:0#KEY_P:ud:%s#KEY_LEFTSHIFT:u:0",
    "Q": "KEY_LEFTSHIFT:d:0#KEY_Q:ud:%s#KEY_LEFTSHIFT:u:0",
    "R": "KEY_LEFTSHIFT:d:0#KEY_R:ud:%s#KEY_LEFTSHIFT:u:0",
    "S": "KEY_LEFTSHIFT:d:0#KEY_S:ud:%s#KEY_LEFTSHIFT:u:0",
    "T": "KEY_LEFTSHIFT:d:0#KEY_T:ud:%s#KEY_LEFTSHIFT:u:0",
    "U": "KEY_LEFTSHIFT:d:0#KEY_U:ud:%s#KEY_LEFTSHIFT:u:0",
    "V": "KEY_LEFTSHIFT:d:0#KEY_V:ud:%s#KEY_LEFTSHIFT:u:0",
    "W": "KEY_LEFTSHIFT:d:0#KEY_W:ud:%s#KEY_LEFTSHIFT:u:0",
    "X": "KEY_LEFTSHIFT:d:0#KEY_X:ud:%s#KEY_LEFTSHIFT:u:0",
    "Y": "KEY_LEFTSHIFT:d:0#KEY_Y:ud:%s#KEY_LEFTSHIFT:u:0",
    "Z": "KEY_LEFTSHIFT:d:0#KEY_Z:ud:%s#KEY_LEFTSHIFT:u:0",
    "[": "KEY_LEFTBRACE:ud:%s",
    "\n": "KEY_ENTER:ud:%s",
    "\t": "KEY_TAB:ud:%s",
    "]": "KEY_RIGHTBRACE:ud:%s",
    "^": "KEY_LEFTSHIFT:d:0#KEY_6:ud:%s#KEY_LEFTSHIFT:u:0",
    "_": "KEY_LEFTSHIFT:d:0#KEY_MINUS:ud:%s#KEY_LEFTSHIFT:u:0",
    "`": "KEY_GRAVE:ud:%s",
    "a": "KEY_A:ud:%s",
    "b": "KEY_B:ud:%s",
    "c": "KEY_C:ud:%s",
    "d": "KEY_D:ud:%s",
    "e": "KEY_E:ud:%s",
    "f": "KEY_F:ud:%s",
    "g": "KEY_G:ud:%s",
    "h": "KEY_H:ud:%s",
    "i": "KEY_I:ud:%s",
    "j": "KEY_J:ud:%s",
    "k": "KEY_K:ud:%s",
    "l": "KEY_L:ud:%s",
    "m": "KEY_M:ud:%s",
    "n": "KEY_N:ud:%s",
    "o": "KEY_O:ud:%s",
    "p": "KEY_P:ud:%s",
    "q": "KEY_Q:ud:%s",
    "r": "KEY_R:ud:%s",
    "s": "KEY_S:ud:%s",
    "t": "KEY_T:ud:%s",
    "u": "KEY_U:ud:%s",
    "v": "KEY_V:ud:%s",
    "w": "KEY_W:ud:%s",
    "x": "KEY_X:ud:%s",
    "y": "KEY_Y:ud:%s",
    "z": "KEY_Z:ud:%s",
    "{": "KEY_LEFTSHIFT:d:0#KEY_LEFTBRACE:ud:%s#KEY_LEFTSHIFT:u:0",
    "}": "KEY_LEFTSHIFT:d:0#KEY_RIGHTBRACE:ud:%s#KEY_LEFTSHIFT:u:0",
    "|": "KEY_LEFTSHIFT:d:0#KEY_BACKSLASH:ud:%s#KEY_LEFTSHIFT:u:0",
    "~": "KEY_LEFTSHIFT:d:0#KEY_GRAVE:ud:%s#KEY_LEFTSHIFT:u:0",
    "ç": "KEY_LEFTALT:d:0#KEY_C:ud:%s#KEY_LEFTALT:u:0",
    "Ç": "KEY_LEFTSHIFT:d:0#KEY_LEFTALT:d:0#KEY_C:ud:%s#KEY_LEFTALT:u:0#KEY_LEFTSHIFT:u:0",
    "ß": "KEY_LEFTALT:d:0#KEY_S:ud:%s#KEY_LEFTALT:u:0",
    "ẞ": "KEY_LEFTSHIFT:d:0#KEY_LEFTALT:d:0#KEY_S:ud:%s#KEY_LEFTALT:u:0#KEY_LEFTSHIFT:u:0",
    }



def letter_normalize_lookup(
    str l, bint case_sens= True, str replace= "", str add_to_printable = ""
):
    cdef:
        object index_tuple
        list v
        str sug,stri_pri
        bint is_printable_letter,is_printable,is_capital
    index_tuple = (l, case_sens, replace, add_to_printable)
    if index_tuple in letter_lookup_dict:
        return letter_lookup_dict[index_tuple]

    v = sorted(unicodedata_name(l).split(), key=len)
    sug = replace
    stri_pri = string_printable + add_to_printable.upper()
    is_printable_letter = v[0] in stri_pri
    is_printable = l in stri_pri
    is_capital = "CAPITAL" in v
    if is_printable_letter:
        sug = v[0]

        if case_sens:
            if not is_capital:
                sug = v[0].lower()
    elif is_printable:
        sug = l
    letter_lookup_dict[index_tuple] = sug
    return sug


cdef bytes png_pack(bytes png_tag, bytes data):
    return (
        structpack("!I", len(data))
        + png_tag
        + data
        + structpack("!I", 0xFFFFFFFF & zlib_crc32(png_tag + data))
    )


def write_png(object pic):
    cdef:
        int height, width, channels
        bytes buf
        int width_byte_4
    if len(pic.shape) != 3:
        return b""
    height, width, channels = pic.shape
    if channels not in (3,4):
        return b""
    if channels==3:
        buf = np.flipud(
        np.dstack((pic, np.full(pic.shape[:2], 0xFF, dtype=np.uint8)))
        ).tobytes()
    else:
        buf = np.flipud(
        pic
        ).tobytes()
    width_byte_4 = width * 4
    return b"".join(
        (
            b"\x89PNG\r\n\x1a\n",
            png_pack(b"IHDR", structpack("!2I5B", width, height, 8, 6, 0, 0, 0)),
            png_pack(
                b"IDAT",
                zlib_compress(
                    b"".join(
                        b"\x00" + buf[span : span + width_byte_4]
                        for span in range(
                            (height - 1) * width_byte_4, -1, -width_byte_4
                        )
                    ),
                    9,
                ),
            ),
            png_pack(b"IEND", b""),
        )
    )


cpdef int random_int_function(int minint, int maxint):
    if maxint > minint:
        return random_randint(minint, maxint)
    return minint

@cython.final
cdef class SendEventWrite:
    cdef:
        str exefile
        str text
        str device_path
        int min_time_key_press
        int max_time_key_press
        str _sendevent_cmd

    def __init__(
        self,
        str exefile,
        str text,
        str device_path,
        int min_time_key_press,
        int max_time_key_press,
    ):
        self.exefile = exefile
        self.text = text
        self.device_path = device_path
        self.min_time_key_press = min_time_key_press
        self.max_time_key_press = max_time_key_press
        self._sendevent_cmd = self.create_sendkey_command()

    def __str__(self):
        return self._sendevent_cmd

    def __repr__(self):
        return self._sendevent_cmd

    def __call__(self, bint recreate_command=True, **kwargs):
        if recreate_command:
            self._sendevent_cmd = self.create_sendkey_command()
        return subprocess_run(
            self._sendevent_cmd, **{"shell": True, "env": os_environ, **kwargs}
        )

    def create_sendkey_command(self):
        cdef:
            list[str] commands = []
            str letter
        for letter in self.text:
            commands.append(
                mappingdict[letter]
                % str(
                    random_int_function(
                        self.min_time_key_press, self.max_time_key_press
                    )
                )
            )
        return self.exefile + " " + self.device_path + " " + "#".join(commands)

@cython.final
cdef class InputText:
    #__slots__ = ("text", "normalized_text", "cmd", "send_each_letter_separately")
    cdef:
        str text
        str normalized_text
        str cmd
        bint send_each_letter_separately

    def __init__(self, str text, str cmd, bint send_each_letter_separately):
        self.text = text
        self.normalized_text = "".join(letter_normalize_lookup(x) for x in text)
        self.cmd = cmd
        self.send_each_letter_separately = send_each_letter_separately

    def __str__(self):
        return self.normalized_text

    def __repr__(self):
        return self.__str__()

    def __call__(self, int min_press=1, int max_press=4, **kwargs):
        cdef:
            str letter, note
        if self.send_each_letter_separately:
            for letter in self.normalized_text:
                if letter != "'":
                    subprocess_run(
                        f"{self.cmd} '{letter}'",
                        **{"shell": True, "env": os_environ, **kwargs},
                    )
                else:
                    subprocess_run(
                        f'''{self.cmd} "'"''',
                        **{"shell": True, "env": os_environ, **kwargs},
                    )
                timesleep(float(random_int_function(min_press, max_press)) / 1000)
        else:
            note=self.normalized_text.replace("'", "'\\''")
            subprocess_run(
                f"""{self.cmd} '{note}'""",
                **{"shell": True, "env": os_environ, **kwargs},
            )
