from __future__ import annotations
import os
from pprint import pprint
from pandas.core.frame import DataFrame, Series
import numpy as np

import contextlib
from time import sleep as timesleep
import subprocess
from random import randint as random_randint
import requests
from random import uniform
from base64 import b64encode
from subprocess import run as subprocess_run
import regex as re


def clean_zombies(sh_exe="/bin/sh", su_exe="su"):
    cmd2execute = rb"""
top -b -n1 | grep -E "[[:digit:]][[:digit:]][.:][[:digit:]][[:digit:]][[:space:]]+.*a[.]out[[:space:]]*$" | awk '{print $1}' | awk '{$1=$1}1' | awk '{system("kill -9 "$1)}'
top -b -n1 | grep -E "[[:digit:]][[:digit:]][.:][[:digit:]][[:digit:]][[:space:]]+.*stty[[:space:]]+raw" | awk '{print $1}' | awk '{$1=$1}1' | awk '{system("kill -9 "$1)}'
top -b -n1 | grep -E "[[:digit:]][[:digit:]][.:][[:digit:]][[:digit:]][[:space:]]+.*dividers" | awk '{print $1}' | awk '{$1=$1}1' | awk '{system("kill -9 "$1)}'
top -b -n1 | grep -E "[[:digit:]][[:digit:]][.:][[:digit:]][[:digit:]][[:space:]]+.*uiautomator[[:space:]]+events" | awk '{print $1}' | awk '{$1=$1}1' | awk '{system("kill -9 "$1)}'
top -b -n1 | grep -E "[[:digit:]][[:digit:]][.:][[:digit:]][[:digit:]][[:space:]]+com.github.uiautomator.*" | awk '{print $1}' | awk '{$1=$1}1' | awk '{system("kill -9 "$1)}'
top -b -n1 | grep -E "[[:digit:]][[:digit:]][.:][[:digit:]][[:digit:]][[:space:]]+app_process.*instrument.*com.github.uiautomator.*" | awk '{print $1}' | awk '{$1=$1}1' | awk '{system("kill -9 "$1)}'
qx="$(settings get secure enabled_accessibility_services)";rr="android.accessibilityservice.elparse/android.accessibilityservice.elparse.MyAccessibilityService";if [ "$qx" != "$rr" ]; then settings put secure enabled_accessibility_services "$rr";fi
top -b -n1 | grep -E "[[:digit:]][[:digit:]][.:][[:digit:]][[:digit:]][[:space:]]+.*a[.]out[[:space:]]*$" | awk '{print $1}' | awk '{$1=$1}1' | xargs kill -9
top -b -n1 | grep -E "[[:digit:]][[:digit:]][.:][[:digit:]][[:digit:]][[:space:]]+.*stty[[:space:]]+raw" | awk '{print $1}' | awk '{$1=$1}1' | xargs kill -9
top -b -n1 | grep -E "[[:digit:]][[:digit:]][.:][[:digit:]][[:digit:]][[:space:]]+.*dividers" | awk '{print $1}' | awk '{$1=$1}1' | xargs kill -9
top -b -n1 | grep -E "[[:digit:]][[:digit:]][.:][[:digit:]][[:digit:]][[:space:]]+.*uiautomator[[:space:]]+events" | awk '{print $1}' | awk '{$1=$1}1' | xargs kill -9
top -b -n1 | grep -E "[[:digit:]][[:digit:]][.:][[:digit:]][[:digit:]][[:space:]]+com.github.uiautomator.*" | awk '{print $1}' | awk '{$1=$1}1' | xargs kill -9
top -b -n1 | grep -E "[[:digit:]][[:digit:]][.:][[:digit:]][[:digit:]][[:space:]]+app_process.*instrument.*com.github.uiautomator.*" | awk '{print $1}' | awk '{$1=$1}1' | xargs kill -9\n\n"""
    p = subprocess_Popen(
        sh_exe,
        stdout=-3,
        stdin=-1,
        stderr=-3,
    )
    p.stdin.write(su_exe.encode() + b"\n")
    p.stdin.flush()
    p.stdin.write(cmd2execute)
    p.stdin.flush()
    p.stdin.write(b"\nexit\n")
    p.stdin.flush()
    p.stdin.write(b"\nexit\n")
    p.stdin.flush()
    p.stdin.close()
    try:
        p.wait(timeout=10)
    except Exception:
        pass


def disable_phantom_killer():
    """
    Disables phantom killer on android 12+ emulators. This is better for running
    fuzzers because the phantom killer will kill processes that consume too much memory

    Also sets OMP_THREAD_LIMIT, MAGICK_THREAD_LIMIT, KMP_ALL_THREADS, KMP_TEAMS_THREAD_LIMIT,
    and KMP_DEVICE_THREAD_LIMIT to 1 to improve performance on emulators.
    """
    cmds2execute = [
        # for daemon sus
        "settings put global settings_enable_monitor_phantom_procs false",
        "setprop persist.sys.fflag.override.settings_enable_monitor_phantom_procs false",
        "device_config put activity_manager max_phantom_processes 2147483647",
        "device_config set_sync_disabled_for_tests persistent; device_config put activity_manager max_phantom_processes 2147483647",
        "su -c 'settings put global settings_enable_monitor_phantom_procs false'",
        "su -c 'setprop persist.sys.fflag.override.settings_enable_monitor_phantom_procs false'",
        "su -c 'device_config put activity_manager max_phantom_processes 2147483647'",
        'su -c "device_config set_sync_disabled_for_tests persistent; device_config put activity_manager max_phantom_processes 2147483647"',
    ]
    _ = [os.system(cmd) for cmd in cmds2execute]

    # bad performance on emulators if not set to 1
    os.environ["OMP_THREAD_LIMIT"] = "1"
    os.environ["MAGICK_THREAD_LIMIT"] = "1"
    os.environ["KMP_ALL_THREADS"] = "1"
    os.environ["KMP_TEAMS_THREAD_LIMIT"] = "1"
    os.environ["OMP_THREAD_LIMIT"] = "1"
    os.environ["KMP_DEVICE_THREAD_LIMIT"] = "1"


disable_phantom_killer()
try:
    from .uiev import *
    from .download_stuff import (
        load_parser_paths_or_compile,
    )
    from .keycode import *
    from .sheller import *
    from .dffuzzmerger import *
except Exception as e:
    import Cython, setuptools, platform, subprocess, os, sys, time

    iswindows = "win" in platform.platform().lower()
    olddict = os.getcwd()
    dirname = os.path.dirname(__file__)
    os.chdir(dirname)
    files2compile = [
        "dffuzzmerge_compile.py",
        "keycode_compile.py",
        "sheller_compile.py",
        "uiev_compile.py",
    ]
    for file2compile in files2compile:
        compile_file = os.path.join(dirname, file2compile)
        cmd2execute = " ".join([sys.executable, compile_file, "build_ext", "--inplace"])
        os.system(cmd2execute)
        timesleep(5)
    os.chdir(olddict)
    from .uiev import *
    from .download_stuff import (
        load_parser_paths_or_compile,
    )
    from .keycode import *
    from .sheller import *
    from .dffuzzmerger import *

# colored print monkey patch
add_printer(True)


def download_tesser_model(tesser_model):
    subprocess_run(
        f"git clone -v --depth 1 --recurse-submodules --shallow-submodules {tesser_model}",
        shell=True,
        cwd="/data/data/com.termux/files/home",
        env=os_environ,
    )


def find_suitable_devices_for_input_events():
    p = subprocess_run("find /dev/input/ -type c", shell=True, capture_output=True)
    stdout = p.stdout.decode().strip().splitlines()
    devices = []
    regex_keyboard_key_a = re.compile(rb"\bKEY_A\b", flags=re.IGNORECASE)
    regex_btn_mouse = re.compile(rb"\bBTN_MOUSE\b", flags=re.IGNORECASE)
    regex_max_value = re.compile(rb"(?<=\bmax\b[:\s]+)\d+", flags=re.IGNORECASE)
    regex_is_mouse = re.compile(rb"\bmouse\b", flags=re.IGNORECASE)
    regex_is_keyboard = re.compile(rb"\bkeyboard\b", flags=re.IGNORECASE)
    regex_is_touch = re.compile(rb"\btouch\b", flags=re.IGNORECASE)
    regex_abs_position = re.compile(rb"\bABS_MT_POSITION_(X|Y)\b", flags=re.IGNORECASE)
    for device in stdout:
        device_stdout = subprocess_run(
            f"getevent -lp {device}", shell=True, capture_output=True
        ).stdout
        device_stdout_lower = device_stdout.lower()
        result = {"type": None, "path": None, "max": (), "keys_found": False}
        if (
            keyfound := regex_keyboard_key_a.search(device_stdout_lower)
        ) or regex_is_keyboard.search(device_stdout_lower):
            result["type"] = "keyboard"
            if keyfound:
                result["keys_found"] = True
            result["path"] = device
        elif (
            keyfound := regex_btn_mouse.search(device_stdout_lower)
        ) or regex_is_mouse.search(device_stdout_lower):
            result["type"] = "mouse"
            if keyfound:
                result["keys_found"] = True
            result["path"] = device
        elif regex_is_touch.search(device_stdout_lower) or regex_abs_position.search(
            device_stdout_lower
        ):
            result["type"] = "touch"
            result["path"] = device
        if result["path"]:
            allvals = regex_max_value.findall(device_stdout)
            if allvals:
                result["max"] = tuple(map(int, allvals))
            devices.append(result)
    return pd.DataFrame(devices)


def get_resolution_of_screen():
    result = [
        list(map(int, x[0].split(b"x")))
        for x in [
            re.findall(
                rb"\b\d+x\d+\b",
                subprocess_run(
                    "wm size", shell=True, capture_output=True
                ).stdout.strip(),
                flags=re.IGNORECASE,
            )
        ]
    ]
    return result[len(result) - 1]


# monkey patch - not meant to be called directly
def d_save_screenshots_as_png(
    self, folder="/sdcard/screenshots_png", screenshot_column="aa_screenshot"
):
    """
    Saves all screenshots in a given column as PNG files in the specified folder.
    For each unique set of coordinates, only one screenshot is saved, and the
    corresponding filenames are saved in a dictionary.

    Parameters
    ----------
    self : pandas.DataFrame
        The dataframe containing the screenshots
    folder : str, optional
        The folder where the screenshots will be saved, by default "/sdcard/screenshots_png"
    screenshot_column : str, optional
        The column containing the screenshots, by default "aa_screenshot"

    Returns
    -------
    list
        A list of the saved files
    """
    os.makedirs(folder, exist_ok=True)
    screenshotdict = {}
    screenshot_filenames = {}
    for key, item in self.iterrows():
        tuplekey = (item.aa_start_x, item.aa_start_y, item.aa_end_x, item.aa_end_y)
        if tuplekey not in screenshotdict:
            try:
                screenshotdict[tuplekey] = write_png(item[screenshot_column])
            except Exception:
                screenshotdict[tuplekey] = b""
            screenshot_filenames[tuplekey] = [os.path.join(folder, f"{key}.png")]
        else:
            screenshot_filenames[tuplekey].append(os.path.join(folder, f"{key}.png"))

    savedfiles = []
    for key, item in screenshot_filenames.items():
        for file in item:
            print(f"Writing {file}", end="\r")
            with open(file, mode="wb") as f:
                f.write(screenshotdict[key])
            savedfiles.append(file)
    return savedfiles


# monkey patch - not meant to be called directly
def d_save_screenshots_as_ppm(
    self, folder="/sdcard/screenshots_ppm", screenshot_column="aa_screenshot"
):
    """
    Save screenshots from a DataFrame as PPM files.

    This function iterates through a DataFrame, extracts screenshots from a specified column,
    and saves them as PPM files in a specified folder. Each screenshot is indexed by its
    bounding box coordinates (start and end positions on x and y axes).

    Parameters
    ----------
    self : pandas.DataFrame
        The DataFrame containing the screenshots.
    folder : str, optional
        The folder where the screenshots will be saved, by default "/sdcard/screenshots_ppm".
    screenshot_column : str, optional
        The column containing the screenshots, by default "aa_screenshot".

    Returns
    -------
    list
        A list of the saved PPM file paths.
    """

    os.makedirs(folder, exist_ok=True)
    screenshotdict = {}
    screenshot_filenames = {}
    dummpynp = np.array([], dtype=np.uint8)
    for key, item in self.iterrows():
        tuplekey = (item.aa_start_x, item.aa_start_y, item.aa_end_x, item.aa_end_y)
        if tuplekey not in screenshotdict:
            try:
                screenshotdict[tuplekey] = [
                    item[screenshot_column].ravel(),
                    item[screenshot_column].shape[1],
                    item[screenshot_column].shape[0],
                ]
            except Exception:
                screenshotdict[tuplekey] = [dummpynp, 0, 0]
            screenshot_filenames[tuplekey] = [os.path.join(folder, f"{key}.ppm")]
        else:
            screenshot_filenames[tuplekey].append(os.path.join(folder, f"{key}.ppm"))

    savedfiles = []
    for key, item in screenshot_filenames.items():
        for file in item:
            print(f"Writing {file}", end="\r")
            write_numpy_array_to_ppm_pic(
                file,
                screenshotdict[key][0],
                screenshotdict[key][1],
                screenshotdict[key][2],
            )
            savedfiles.append(file)
    return savedfiles


# monkey patch - not meant to be called directly
def d_color_search(self, colors, result_column, screenshot_column="aa_screenshot"):
    """
    Searches for the given colors in the given column of the dataframe,
    and appends the results to a new column in the dataframe.

    Parameters
    ----------
    self : pandas.DataFrame
        The dataframe containing the screenshots.
    colors : list of tuples or np.ndarray
        The colors to search for, given as RGB tuples.
    result_column : str, optional
        The column where the results will be stored, by default None.
    screenshot_column : str, optional
        The column containing the screenshots, by default "aa_screenshot".

    Returns
    -------
    None
    """
    if "aa_screenshot" not in self.columns:
        raise IndexError(f"{screenshot_column} column not found")
    if len(colors) == 0:
        return
    if isinstance(colors[0], int):
        colors = [colors]
    if not isinstance(colors, np.ndarray):
        colors = np.array(colors, dtype=np.uint8)
    if colors.dtype != np.uint8:
        colors = colors.astype(np.uint8)
    first_resultcolumn = f"{result_column}"
    try:
        search_for_colors_in_elements(
            df=self,
            colors=colors,
            result_column=first_resultcolumn,
            screenshot_column=screenshot_column,
            start_x="aa_start_x",
            start_y="aa_start_y",
            end_x="aa_end_x",
            end_y="aa_end_y",
        )
    except Exception:
        self.loc[:, result_column] = np.asarray(
            [[] for _ in range(len(self))], dtype="object"
        )


def s_cluster_values(columnarray, min_points=50, min_cluster_size=50):
    columns2calculate = {}
    for key, item in enumerate(columnarray):
        tuitem = tuple((i["x"], i["y"]) for i in item)
        if tuitem:
            columns2calculate.setdefault(tuitem, []).append(key)
    alldataframes_list = []
    for key, items in columns2calculate.items():
        tmpframe = pd.DataFrame(
            py_calculate_hdbscan(
                data=key, min_points=min_points, min_cluster_size=min_cluster_size
            )
        )
        for item in items:
            alldataframes_list.append(tmpframe.assign(dfiloc=item))
    return pd.concat(alldataframes_list, ignore_index=True)


# adb keyboard - supports unicode input, but not working on all devices
class AdbKeyBoard:
    __slots__ = ("link", "save_path", "system_bin_path", "valid_adb_keyboards")

    def __init__(
        self,
        system_bin: str,
        link: str = "https://github.com/hansalemaos/ADBKeyBoard/raw/refs/heads/master/ADBKeyboard.apk",
        save_path: str = "/sdcard/ADBKeyboard.apk",
        valid_adb_keyboards: tuple = (
            "com.android.adbkeyboard/.AdbIME",
            "com.github.uiautomator/.AdbKeyboard",
        ),
    ):
        """
        Initialize an AdbKeyBoard instance with specified parameters.

        Parameters
        ----------
        system_bin : str
            The path to the system binary directory.
        link : str, optional
            The URL to download the ADB Keyboard APK, by default "https://github.com/hansalemaos/ADBKeyBoard/raw/refs/heads/master/ADBKeyboard.apk".
        save_path : str, optional
            The path where the ADB Keyboard APK will be saved, by default "/sdcard/ADBKeyboard.apk".
        valid_adb_keyboards : tuple, optional
            A tuple of valid ADB keyboard identifiers, by default ("com.android.adbkeyboard/.AdbIME", "com.github.uiautomator/.AdbKeyboard").
        """

        self.system_bin_path: str = system_bin
        self.link: str = link
        self.save_path: str = save_path
        self.valid_adb_keyboards: tuple = valid_adb_keyboards

    def download_adbkeyboard_apk(self):
        """
        Downloads the ADB Keyboard APK from the specified link and saves it to the given path.

        This method sends a GET request to the URL provided in `self.link`. If the request is
        successful (status code 200), the content of the response is written to the file path
        specified in `self.save_path`.

        Raises
        ------
        requests.exceptions.RequestException
            If there is an issue with the network request.
        """

        with requests.get(self.link) as r:
            if r.status_code == 200:
                with open(self.save_path, "wb") as f:
                    f.write(r.content)

    def install_adbkeyboard_apk(self):
        """
        Installs the ADB Keyboard APK to the device.

        This method uses the package manager (pm) utility to install the APK
        located at the path specified in `self.save_path` with grant permissions.

        Raises
        ------
        subprocess.CalledProcessError
            If the installation command fails.
        """

        subprocess_run(
            self.system_bin_path + "pm install -g " + self.save_path,
            shell=True,
            env=os_environ,
        )

    def get_all_installed_keyboards(self):
        """
        Returns a list of all the installed keyboards on the device.

        This method uses the Android's package manager (pm) utility to list all the installed
        packages that support the input method. The output is then parsed to extract the
        packages names.

        Returns
        -------
        list
            A list of the package names of the installed keyboards.
        """
        return [
            x.strip()
            for x in [
                x.strip().strip(":")
                for x in (
                    subprocess_run(
                        self.system_bin_path + "ime list -a",
                        shell=True,
                        env=os_environ,
                        capture_output=True,
                    )
                    .stdout.strip()
                    .decode("utf-8")
                    .splitlines()
                )
                if re.search(r"^[^\s]", x)
            ]
        ]

    def activate_adb_keyboard(self):
        """
        Activate the ADB keyboard.

        If the ADB keyboard is not installed, it will be downloaded and installed.
        If the ADB keyboard is not the current input method, it will be set as the current input method.

        This method will try to activate the first ADB keyboard it finds in the list of installed
        keyboards that support the input method. If no ADB keyboard is found, it will download and
        install the ADB keyboard.

        Returns
        -------
        None
        """
        try:
            keyba = [
                x
                for x in self.get_all_installed_keyboards()
                if x in self.valid_adb_keyboards
            ][0]
        except Exception:
            self.download_adbkeyboard_apk()
            self.install_adbkeyboard_apk()
            keyba = [
                x
                for x in self.get_all_installed_keyboards()
                if x in self.valid_adb_keyboards
            ][0]
        subprocess_run(
            self.system_bin_path + f"ime enable {keyba}",
            shell=True,
            env=os_environ,
        )
        subprocess_run(
            self.system_bin_path + f"ime set {keyba}",
            shell=True,
            env=os_environ,
        )

    def disable_adb_keyboard(self):
        """
        Disable the ADB keyboard and reset input method settings.

        This method executes a command to reset the input method settings on the device.
        It effectively disables any active ADB keyboard by resetting the input method
        configuration to its default state.

        Raises
        ------
        subprocess.CalledProcessError
            If the reset command fails.
        """

        subprocess_run(
            self.system_bin_path + "ime reset",
            shell=True,
            env=os_environ,
        )

    def send_unicode_text_with_delay(
        self, text: str, delay_range: tuple = (0.05, 0.1), **kwargs
    ):
        """
        Send a string of Unicode text to the device with a random delay between
        each character.

        Parameters
        ----------
        text : str
            The string of Unicode text to send.
        delay_range : tuple of float
            A tuple of two floats between 0 and 1, representing the range of
            delays to introduce between each character. The default delay range
            is (0.05, 0.1), which means a random delay between 50ms and 100ms
            will be introduced between each character.

        Returns
        -------
        self : ADBKeyboard
            The instance of ADBKeyboard, allowing chaining of calls.
        """
        for t in list(text):
            self.send_unicode_text(t, **kwargs)
            timesleep((uniform(*delay_range)))
        return self

    def send_unicode_text(self, text: str, **kwargs):
        """
        Send a string of Unicode text to the device.

        Parameters
        ----------
        text : str
            The string of Unicode text to send.

        Returns
        -------
        self : ADBKeyboard
            The instance of ADBKeyboard, allowing chaining of calls.
        """
        charsb64 = (
            "'"
            + (b64encode(text.encode("utf-8"))).decode("utf-8").replace("'", "'\\''")
            + "'"
        )
        mycmd = (
            self.system_bin_path + f"am broadcast -a ADB_INPUT_B64 --es msg {charsb64}"
        )
        subprocess_run(
            mycmd,
            **{"shell": True, "env": os_environ, **kwargs},
        )
        return self


class TermuxAutomation:
    def __init__(
        self,
        parsers: dict,
        parser_timeout: int = 30,
        add_input_tap: bool = True,
        add_sendevent_mouse_click: bool = True,
        add_sendevent_tap: bool = True,
        add_mouse_action: bool = True,
        mouse_device: str = "/dev/input/event4",
        touch_device: str = "/dev/input/event5",
        keyboard_device: str = "/dev/input/event1",
        touch_device_max: int = 32767,
        mouse_device_max: int = 65535,
        input_cmd_tap: str = "/system/bin/input tap",
        input_cmd_text: str = "/system/bin/input text",
        sendevent_path: str = "/system/bin/sendevent",
        screen_height: int = 768,
        screen_width: int = 1024,
        sh_exe: str = "/bin/sh",
        su_exe: str = "su",
        uiautomator_dump_path: str = "/sdcard/window_dump.xml",
        uiautomator_cpu_limit: int = 5,
        system_bin_path: str = "/system/bin/",
        path_screencap: str = "screencap",
        path_exe_tesseract: str = "/data/data/com.termux/files/usr/bin/tesseract",
        path_exe_imagemagick: str = "/data/data/com.termux/files/usr/bin/magick",
        tesseract_args: str = '"-l por+eng --oem 3"',
        imagemagick_args: object = None,
        tesseract_path_outpic: str = "/sdcard/screenshot.ppm",
        uiautomator2_download_link1: str = "https://github.com/hansalemaos/uiautomator2tocsv/raw/refs/heads/main/app-uiautomator-test_with_hidden_elements.apk",
        uiautomator2_download_link2: str = "https://github.com/hansalemaos/uiautomator2tocsv/raw/refs/heads/main/app-uiautomator_with_hidden_elements.apk",
        uiautomator2_save_path1: str = "/sdcard/app-uiautomator-test.apk",
        uiautomator2_save_path2: str = "/sdcard/app-uiautomator.apk",
        lcp_deque_size: int = 40960,
        lcp_print_stdout: bool = False,
        lcp_print_stderr: bool = False,
        kwargs: object = None,
        adb_keyboard_link: str = "https://github.com/hansalemaos/ADBKeyBoard/raw/refs/heads/master/ADBKeyboard.apk",
        adb_keyboard_save_path: str = "/sdcard/ADBKeyboard.apk",
        valid_adb_keyboards: tuple = (
            "com.android.adbkeyboard/.AdbIME",
            "com.github.uiautomator/.AdbKeyboard",
        ),
    ):
        r"""
        Initialize the TermuxAutomation class with configuration for various parsers
        and automation tools.

        Parameters
        ----------
        parsers : dict
            A dictionary containing paths to various parser executables.
        parser_timeout : int, optional
            Timeout for parser operations in seconds. Default is 30.
        add_input_tap : bool, optional
            Whether to add input tap capability. Default is True.
        add_sendevent_mouse_click : bool, optional
            Whether to add sendevent mouse click capability. Default is True.
        add_sendevent_tap : bool, optional
            Whether to add sendevent tap capability. Default is True.
        add_mouse_action : bool, optional
            Whether to add mouse action capability. Default is True.
        mouse_device : str, optional
            Path to the mouse input device. Default is "/dev/input/event4".
        touch_device : str, optional
            Path to the touch input device. Default is "/dev/input/event5".
        keyboard_device : str, optional
            Path to the keyboard input device. Default is "/dev/input/event1".
        touch_device_max : int, optional
            Maximum value for touch device coordinates. Default is 32767.
        mouse_device_max : int, optional
            Maximum value for mouse device coordinates. Default is 65535.
        input_cmd_tap : str, optional
            Command for input tap. Default is "/system/bin/input tap".
        input_cmd_text : str, optional
            Command for input text. Default is "/system/bin/input text".
        sendevent_path : str, optional
            Path to the sendevent binary. Default is "/system/bin/sendevent".
        screen_height : int, optional
            Screen height in pixels. Default is 768.
        screen_width : int, optional
            Screen width in pixels. Default is 1024.
        sh_exe : str, optional
            Shell executable path. Default is "/bin/sh".
        su_exe : str, optional
            Superuser executable path. Default is "su".
        uiautomator_dump_path : str, optional
            Path for UIAutomator dump. Default is "/sdcard/window_dump.xml".
        uiautomator_cpu_limit : int, optional
            CPU limit for UIAutomator operations. Default is 5.
        system_bin_path : str, optional
            Path to the system binary directory. Default is "/system/bin/".
        path_screencap : str, optional
            Path to the screencap binary. Default is "screencap".
        path_exe_tesseract : str, optional
            Path to the Tesseract executable. Default is "/data/data/com.termux/files/usr/bin/tesseract".
        path_exe_imagemagick : str, optional
            Path to the ImageMagick executable. Default is "/data/data/com.termux/files/usr/bin/magick".
        tesseract_args : str, optional
            Arguments for Tesseract. Default is '"-l por+eng --oem 3"'.
        imagemagick_args : object, optional
            Arguments for ImageMagick. Default is None.
        tesseract_path_outpic : str, optional
            Path for Tesseract output picture. Default is "/sdcard/screenshot.ppm".
        uiautomator2_download_link1 : str, optional
            Download link for the first UIAutomator2 APK. Default is a GitHub URL.
        uiautomator2_download_link2 : str, optional
            Download link for the second UIAutomator2 APK. Default is a GitHub URL.
        uiautomator2_save_path1 : str, optional
            Save path for the first UIAutomator2 APK. Default is "/sdcard/app-uiautomator-test.apk".
        uiautomator2_save_path2 : str, optional
            Save path for the second UIAutomator2 APK. Default is "/sdcard/app-uiautomator.apk".
        lcp_deque_size : int, optional
            Deque size for LCP operations. Default is 40960.
        lcp_print_stdout : bool, optional
            Whether to print LCP operations to stdout. Default is False.
        lcp_print_stderr : bool, optional
            Whether to print LCP operations to stderr. Default is False.
        kwargs : object, optional
            Additional keyword arguments for parsers. Default is None.
        adb_keyboard_link : str, optional
            Download link for ADB keyboard APK. Default is a GitHub URL.
        adb_keyboard_save_path : str, optional
            Save path for ADB keyboard APK. Default is "/sdcard/ADBKeyboard.apk".
        valid_adb_keyboards : tuple, optional
            Tuple of valid ADB keyboard identifiers. Default includes "com.android.adbkeyboard/.AdbIME" and "com.github.uiautomator/.AdbKeyboard".
        """

        self.tessdata: str = "/data/data/com.termux/files/home/tessdata"
        self.tessdata_fast: str = "/data/data/com.termux/files/home/tessdata_fast"
        self.tessdata_best: str = "/data/data/com.termux/files/home/tessdata_best"
        self.valid_adb_keyboards: tuple = valid_adb_keyboards
        self.adb_keyboard_save_path: str = adb_keyboard_save_path
        self.adb_keyboard_link: str = adb_keyboard_link
        self.keyboard_device: str = keyboard_device
        self.lcp_deque_size: int = lcp_deque_size
        self.lcp_print_stdout: bool = lcp_print_stdout
        self.lcp_print_stderr: bool = lcp_print_stderr
        DataFrame.bb_search_for_colors = d_color_search
        DataFrame.bb_save_screenshots_as_png = d_save_screenshots_as_png
        DataFrame.bb_save_screenshots_as_ppm = d_save_screenshots_as_ppm
        Series.s_cluster_values = s_cluster_values
        self.uiautomator2_download_link1: str = uiautomator2_download_link1
        self.uiautomator2_download_link2: str = uiautomator2_download_link2
        self.uiautomator2_save_path1: str = uiautomator2_save_path1
        self.uiautomator2_save_path2: str = uiautomator2_save_path2
        self.uiautomator_cpu_limit: int = uiautomator_cpu_limit
        self.tesseract_path_outpic: str = tesseract_path_outpic
        self.imagemagick_args: object = imagemagick_args
        self.tesseract_args: str = tesseract_args
        self.path_screencap: str = path_screencap
        self.path_exe_tesseract: str = path_exe_tesseract
        self.path_exe_imagemagick: str = path_exe_imagemagick
        self.system_bin_path: str = "/" + system_bin_path.strip("/ ") + "/"
        self.uiautomator_dump_path: str = uiautomator_dump_path
        self.parser_timeout: int = parser_timeout
        self.add_input_tap: bool = add_input_tap
        self.add_sendevent_mouse_click: bool = add_sendevent_mouse_click
        self.add_sendevent_tap: bool = add_sendevent_tap
        self.add_mouse_action: bool = add_mouse_action
        self.mouse_device: str = mouse_device
        self.touch_device: str = touch_device
        self.touch_device_max: int = touch_device_max
        self.mouse_device_max: int = mouse_device_max
        self.input_cmd: str = input_cmd_tap
        self.input_cmd_text: str = input_cmd_text
        self.sendevent_path: str = sendevent_path
        self.screen_height: int = screen_height
        self.screen_width: int = screen_width
        self.sh_exe: str = sh_exe
        self.su_exe: str = su_exe
        self.kwargs: dict = kwargs if kwargs else {}
        self.exe_android_fragment_parser: str = parsers.get(
            "android_fragment_parser", ""
        )
        self.exe_getevent_keydumper_linux: str = parsers.get(
            "getevent_keydumper_linux", ""
        )
        self.exe_getevent_pretty_print_linux: str = parsers.get(
            "getevent_pretty_print_linux", ""
        )
        self.exe_lcp: str = parsers.get("lcp", "")
        self.exe_mouse_sendevent_android: str = parsers.get(
            "mouse_sendevent_android", ""
        )
        self.exe_uiautomator2tocsv: str = parsers.get("uiautomator2tocsv", "")
        self.exe_uiautomator_dump_to_csv: str = parsers.get(
            "uiautomator_dump_to_csv", ""
        )
        self.exe_uiautomator_dump_without_could_not_detect_idle_state: str = (
            parsers.get("uiautomator_dump_without_could_not_detect_idle_state", "")
        )
        self.exe_sendevent_multicommands_type_text: str = parsers.get(
            "sendevent_multicommands_type_text", ""
        )
        self.exe_hocr2csv: str = parsers.get("hocr2csv", "")

        self.adb_keyboard = AdbKeyBoard(
            system_bin=self.system_bin_path,
            link=self.adb_keyboard_link,
            save_path=self.adb_keyboard_save_path,
            valid_adb_keyboards=self.valid_adb_keyboards,
        )
        self.backend_window_parser: object = WindowDumper(
            android_fragment_parser_exe=self.exe_android_fragment_parser,
            android_window_parser_cmd=f"{self.system_bin_path}cmd window dump-visible-window-views",
            timeout=self.parser_timeout,
            add_input_tap=self.add_input_tap,
            add_sendevent_mouse_click=self.add_sendevent_mouse_click,
            add_sendevent_tap=self.add_sendevent_tap,
            add_mouse_action=self.add_mouse_action,
            x_column="aa_center_x",
            y_column="aa_center_y",
            mouse_device=self.mouse_device,
            touch_device=self.touch_device,
            touch_device_max=self.touch_device_max,
            mouse_device_max=self.mouse_device_max,
            input_cmd=self.input_cmd,
            sendevent_path=self.sendevent_path,
            screen_height=self.screen_height,
            screen_width=self.screen_width,
            mouse_action_exe=self.exe_mouse_sendevent_android,
            sh_exe=self.sh_exe,
            su_exe=self.su_exe,
            kwargs=self.kwargs,
        )
        self.backend_fragment_parser: object = FragMentDumper(
            android_fragment_parser_exe=self.exe_android_fragment_parser,
            timeout=self.parser_timeout,
            add_input_tap=self.add_input_tap,
            add_sendevent_mouse_click=self.add_sendevent_mouse_click,
            add_sendevent_tap=self.add_sendevent_tap,
            add_mouse_action=self.add_mouse_action,
            x_column="aa_center_x",
            y_column="aa_center_y",
            mouse_device=self.mouse_device,
            touch_device=self.touch_device,
            touch_device_max=self.touch_device_max,
            mouse_device_max=self.mouse_device_max,
            input_cmd=self.input_cmd,
            sendevent_path=self.sendevent_path,
            screen_height=self.screen_height,
            screen_width=self.screen_width,
            mouse_action_exe=self.exe_mouse_sendevent_android,
            sh_exe=self.sh_exe,
            su_exe=self.su_exe,
            kwargs=self.kwargs,
        )
        self.backend_uiautomator_classic: object = UiAutomatorClassic(
            uiautomator_parser=self.exe_uiautomator_dump_to_csv,
            timeout=self.parser_timeout,
            add_input_tap=self.add_input_tap,
            add_sendevent_mouse_click=self.add_sendevent_mouse_click,
            add_sendevent_tap=self.add_sendevent_tap,
            add_mouse_action=self.add_mouse_action,
            x_column="aa_center_x",
            y_column="aa_center_y",
            mouse_device=self.mouse_device,
            touch_device=self.touch_device,
            touch_device_max=self.touch_device_max,
            mouse_device_max=self.mouse_device_max,
            input_cmd=self.input_cmd,
            sendevent_path=self.sendevent_path,
            screen_height=self.screen_height,
            screen_width=self.screen_width,
            mouse_action_exe=self.exe_mouse_sendevent_android,
            sh_exe=self.sh_exe,
            su_exe=self.su_exe,
            kwargs=self.kwargs,
            system_bin=self.system_bin_path,
            dump_path=self.uiautomator_dump_path,
        )
        self.backend_tesseract: object = Screencap2Tesseract(
            exe_path=self.exe_hocr2csv,
            timeout=self.parser_timeout,
            add_input_tap=self.add_input_tap,
            add_sendevent_mouse_click=self.add_sendevent_mouse_click,
            add_sendevent_tap=self.add_sendevent_tap,
            add_mouse_action=self.add_mouse_action,
            x_column="aa_center_x",
            y_column="aa_center_y",
            mouse_device=self.mouse_device,
            touch_device=self.touch_device,
            touch_device_max=self.touch_device_max,
            mouse_device_max=self.mouse_device_max,
            input_cmd=self.input_cmd,
            sendevent_path=self.sendevent_path,
            screen_height=self.screen_height,
            screen_width=self.screen_width,
            mouse_action_exe=self.exe_mouse_sendevent_android,
            sh_exe=self.sh_exe,
            su_exe=self.su_exe,
            kwargs=self.kwargs,
            system_bin=self.system_bin_path,
            tessdata=self.tessdata,
            path_screencap=self.path_screencap,
            path_exe_tesseract=self.path_exe_tesseract,
            path_exe_imagemagick=self.path_exe_imagemagick,
            tesseract_args=self.tesseract_args,
            imagemagick_args=self.imagemagick_args,
            path_outpic=self.tesseract_path_outpic,
        )
        self.backend_tesseract_fast: object = Screencap2Tesseract(
            exe_path=self.exe_hocr2csv,
            timeout=self.parser_timeout,
            add_input_tap=self.add_input_tap,
            add_sendevent_mouse_click=self.add_sendevent_mouse_click,
            add_sendevent_tap=self.add_sendevent_tap,
            add_mouse_action=self.add_mouse_action,
            x_column="aa_center_x",
            y_column="aa_center_y",
            mouse_device=self.mouse_device,
            touch_device=self.touch_device,
            touch_device_max=self.touch_device_max,
            mouse_device_max=self.mouse_device_max,
            input_cmd=self.input_cmd,
            sendevent_path=self.sendevent_path,
            screen_height=self.screen_height,
            screen_width=self.screen_width,
            mouse_action_exe=self.exe_mouse_sendevent_android,
            sh_exe=self.sh_exe,
            su_exe=self.su_exe,
            kwargs=self.kwargs,
            system_bin=self.system_bin_path,
            tessdata=self.tessdata_fast,
            path_screencap=self.path_screencap,
            path_exe_tesseract=self.path_exe_tesseract,
            path_exe_imagemagick=self.path_exe_imagemagick,
            tesseract_args=self.tesseract_args,
            imagemagick_args=self.imagemagick_args,
            path_outpic=self.tesseract_path_outpic,
        )
        self.backend_tesseract_best: object = Screencap2Tesseract(
            exe_path=self.exe_hocr2csv,
            timeout=self.parser_timeout,
            add_input_tap=self.add_input_tap,
            add_sendevent_mouse_click=self.add_sendevent_mouse_click,
            add_sendevent_tap=self.add_sendevent_tap,
            add_mouse_action=self.add_mouse_action,
            x_column="aa_center_x",
            y_column="aa_center_y",
            mouse_device=self.mouse_device,
            touch_device=self.touch_device,
            touch_device_max=self.touch_device_max,
            mouse_device_max=self.mouse_device_max,
            input_cmd=self.input_cmd,
            sendevent_path=self.sendevent_path,
            screen_height=self.screen_height,
            screen_width=self.screen_width,
            mouse_action_exe=self.exe_mouse_sendevent_android,
            sh_exe=self.sh_exe,
            su_exe=self.su_exe,
            kwargs=self.kwargs,
            system_bin=self.system_bin_path,
            tessdata=self.tessdata_fast,
            path_screencap=self.path_screencap,
            path_exe_tesseract=self.path_exe_tesseract,
            path_exe_imagemagick=self.path_exe_imagemagick,
            tesseract_args=self.tesseract_args,
            imagemagick_args=self.imagemagick_args,
            path_outpic=self.tesseract_path_outpic,
        )
        self.backend_uiautomator_with_cpu_limit = UiAutomatorClassicWithCPULimit(
            cpu_limit=self.uiautomator_cpu_limit,
            uiautomator_parser=self.exe_uiautomator_dump_without_could_not_detect_idle_state,
            timeout=self.parser_timeout,
            add_input_tap=self.add_input_tap,
            add_sendevent_mouse_click=self.add_sendevent_mouse_click,
            add_sendevent_tap=self.add_sendevent_tap,
            add_mouse_action=self.add_mouse_action,
            x_column="aa_center_x",
            y_column="aa_center_y",
            mouse_device=self.mouse_device,
            touch_device=self.touch_device,
            touch_device_max=self.touch_device_max,
            mouse_device_max=self.mouse_device_max,
            input_cmd=self.input_cmd,
            sendevent_path=self.sendevent_path,
            screen_height=self.screen_height,
            screen_width=self.screen_width,
            mouse_action_exe=self.exe_mouse_sendevent_android,
            sh_exe=self.sh_exe,
            su_exe=self.su_exe,
            kwargs=self.kwargs,
            system_bin=self.system_bin_path,
            dump_path=self.uiautomator_dump_path,
        )
        self.backend_uiautomator2 = UiAutomator2(
            sh_exe=self.sh_exe,
            su_exe=self.su_exe,
            system_bin=self.system_bin_path,
            download_link1=self.uiautomator2_download_link1,
            download_link2=self.uiautomator2_download_link2,
            save_path1=self.uiautomator2_save_path1,
            save_path2=self.uiautomator2_save_path2,
            csv_parser_exe=self.exe_uiautomator2tocsv,
            timeout=self.parser_timeout,
            add_input_tap=self.add_input_tap,
            add_sendevent_mouse_click=self.add_sendevent_mouse_click,
            add_sendevent_tap=self.add_sendevent_tap,
            add_mouse_action=self.add_mouse_action,
            x_column="aa_center_x",
            y_column="aa_center_y",
            mouse_device=self.mouse_device,
            touch_device=self.touch_device,
            touch_device_max=self.touch_device_max,
            mouse_device_max=self.mouse_device_max,
            input_cmd=self.input_cmd,
            sendevent_path=self.sendevent_path,
            screen_height=self.screen_height,
            screen_width=self.screen_width,
            mouse_action_exe=self.exe_mouse_sendevent_android,
            kwargs=self.kwargs,
        )
        self.backend_lcp = LcpParser(
            cmdline=self.exe_lcp,
            deque_size=self.lcp_deque_size,
            add_input_tap=self.add_input_tap,
            add_sendevent_mouse_click=self.add_sendevent_mouse_click,
            add_sendevent_tap=self.add_sendevent_tap,
            add_mouse_action=self.add_mouse_action,
            x_column="aa_center_x",
            y_column="aa_center_y",
            mouse_device=self.mouse_device,
            touch_device=self.touch_device,
            touch_device_max=self.touch_device_max,
            mouse_device_max=self.mouse_device_max,
            input_cmd=self.input_cmd,
            sendevent_path=self.sendevent_path,
            screen_height=self.screen_height,
            screen_width=self.screen_width,
            mouse_action_exe=self.exe_mouse_sendevent_android,
            sh_exe=self.sh_exe,
            su_exe=self.su_exe,
            kwargs=self.kwargs,
            system_bin=self.system_bin_path,
            print_stdout=self.lcp_print_stdout,
            print_stderr=self.lcp_print_stderr,
        )
        self._active_uiautomator2: bool = False
        self._active_lcp: bool = False
        self.KeyCodes = KeyCodePresser(self.system_bin_path)

    def __str__(self):
        return f"""
        android_fragment_parser: {self.exe_android_fragment_parser}
        getevent_keydumper_linux: {self.exe_getevent_keydumper_linux}
        getevent_pretty_print_linux: {self.exe_getevent_pretty_print_linux}
        lcp: {self.exe_lcp}
        mouse_sendevent_android: {self.exe_mouse_sendevent_android}
        uiautomator2tocsv: {self.exe_uiautomator2tocsv}
        uiautomator_dump_to_csv: {self.exe_uiautomator_dump_to_csv}
        uiautomator_dump_without_could_not_detect_idle_state: {self.exe_uiautomator_dump_without_could_not_detect_idle_state}
        sendevent_multicommands_type_text: {self.exe_sendevent_multicommands_type_text}
        hocr2csv: {self.exe_hocr2csv}"""

    def __repr__(self):
        return self.__str__()

    @staticmethod
    def load_parsers_or_download_and_compile(gcc_exe="g++"):
        """
        Tries to load all the parsers. If some parsers are not compiled,
        it will download and compile them.

        Parameters
        ----------
        gcc_exe : str
            The path to gcc executable.

        Returns
        -------
        parser_paths : dict
            A dictionary containing the paths to all the parsers.
        """
        return load_parser_paths_or_compile(gcc_exe=gcc_exe)

    def get_df_tesseract(self, with_screenshot=True, word_group_limit=20, **kwargs):
        if not os.path.exists(self.tessdata):
            download_tesser_model(
                tesser_model="https://github.com/tesseract-ocr/tessdata"
            )
        return self.backend_tesseract.get_df(
            with_screenshot=with_screenshot, word_group_limit=word_group_limit, **kwargs
        )

    def get_df_tesseract_fast(
        self, with_screenshot=True, word_group_limit=20, **kwargs
    ):
        if not os.path.exists(self.tessdata_fast):
            download_tesser_model(
                tesser_model="https://github.com/tesseract-ocr/tessdata_fast"
            )
        return self.backend_tesseract_fast.get_df(
            with_screenshot=with_screenshot, word_group_limit=word_group_limit, **kwargs
        )

    def get_df_tesseract_best(
        self, with_screenshot=True, word_group_limit=20, **kwargs
    ):
        if not os.path.exists(self.tessdata_best):
            download_tesser_model(
                tesser_model="https://github.com/tesseract-ocr/tessdata_best"
            )
        return self.backend_tesseract_best.get_df(
            with_screenshot=with_screenshot, word_group_limit=word_group_limit, **kwargs
        )

    def get_df_uiautomator_classic(self, with_screenshot=True, **kwargs):
        """
        Retrieves a DataFrame using the Uiautomator Classic data extraction (uiautomator dump).

        Parameters
        ----------
        with_screenshot : bool, optional
            If True, includes screenshot data in the DataFrame. Default is True.
        **kwargs : dict
            Additional arguments to change the default parameters
            If you pass anything else than None, it will override the default parameters once.
            add_input_tap=None,
            add_sendevent_mouse_click=None,
            add_sendevent_tap=None,
            add_mouse_action=None,
            x_column=None,
            y_column=None,
            mouse_device=None,
            touch_device=None,
            touch_device_max=None,
            mouse_device_max=None,
            input_cmd=None,
            sendevent_path=None,
            screen_height=None,
            screen_width=None,
            mouse_action_exe=None,
            sh_exe=None,
            su_exe=None,
            kwargs=None,
            dump_path=None,
            timeout=None,
        Returns
        -------
        pandas.DataFrame
            A DataFrame containing the extracted data.
        """
        self.stop_uiautomator2_server()
        # self.stop_lcp_server()
        df = self.backend_uiautomator_classic.get_df(
            with_screenshot=with_screenshot, **kwargs
        )

        return df.rename(
            columns={x: f"aa_{x}" if not x.startswith("aa_") else x for x in df.columns}
        )

    def get_df_uiautomator_with_cpu_limit(self, with_screenshot=True, **kwargs):
        """
        Retrieves a DataFrame using uiautomator dump data extraction with CPU limit.

        Parameters
        ----------
        with_screenshot : bool, optional
            If True, includes screenshot data in the DataFrame. Default is True.
        **kwargs : dict
            Additional arguments to change the default parameters
            If you pass anything else than None, it will override the default parameters once.
            cpu_limit=None,
            add_input_tap=None,
            add_sendevent_mouse_click=None,
            add_sendevent_tap=None,
            add_mouse_action=None,
            x_column=None,
            y_column=None,
            mouse_device=None,
            touch_device=None,
            touch_device_max=None,
            mouse_device_max=None,
            input_cmd=None,
            sendevent_path=None,
            screen_height=None,
            screen_width=None,
            mouse_action_exe=None,
            sh_exe=None,
            su_exe=None,
            kwargs=None,
            timeout=None,
        Returns
        -------
        pandas.DataFrame
            A DataFrame containing the extracted data.
        """
        self.stop_uiautomator2_server()
        # self.stop_lcp_server()
        df = self.backend_uiautomator_with_cpu_limit.get_df(
            with_screenshot=with_screenshot, **kwargs
        )
        return df.rename(
            columns={x: f"aa_{x}" if not x.startswith("aa_") else x for x in df.columns}
        )

    def get_df_fragments(self, with_screenshot=True, **kwargs):
        """
        Retrieves a DataFrame using fragment parser data extraction.

        Parameters
        ----------
        with_screenshot : bool, optional
            If True, includes screenshot data in the DataFrame. Default is True.
        **kwargs : dict
            Additional arguments to change the default parameters.
            If you pass anything else than None, it will override the default parameters once.
            add_input_tap=None,
            add_sendevent_mouse_click=None,
            add_sendevent_tap=None,
            add_mouse_action=None,
            x_column=None,
            y_column=None,
            mouse_device=None,
            touch_device=None,
            touch_device_max=None,
            mouse_device_max=None,
            input_cmd=None,
            sendevent_path=None,
            screen_height=None,
            screen_width=None,
            mouse_action_exe=None,
            sh_exe=None,
            su_exe=None,
            kwargs=None,
            timeout=None,
        Returns
        -------
        pandas.DataFrame
            A DataFrame containing the extracted fragment data.
        """

        return self.backend_fragment_parser.get_df(
            with_screenshot=with_screenshot, **kwargs
        )

    def get_df_uiautomator2(self, with_screenshot=True, **kwargs):
        """
        Retrieves a DataFrame using the UiAutomator2 data extraction.

        Parameters
        ----------
        with_screenshot : bool, optional
            If True, includes screenshot data in the DataFrame. Default is True.
        **kwargs : dict
            Additional arguments to change the default parameters.
            If you pass anything else than None, it will override the default parameters once.
            add_input_tap=None,
            add_sendevent_mouse_click=None,
            add_sendevent_tap=None,
            add_mouse_action=None,
            x_column=None,
            y_column=None,
            mouse_device=None,
            touch_device=None,
            touch_device_max=None,
            mouse_device_max=None,
            input_cmd=None,
            sendevent_path=None,
            screen_height=None,
            screen_width=None,
            mouse_action_exe=None,
            sh_exe=None,
            su_exe=None,
            kwargs=None,
            timeout=None,
        Returns
        -------
        pandas.DataFrame

        """

        self.stop_lcp_server()
        self.start_uiautomator2_server()
        return self.backend_uiautomator2.get_df(
            with_screenshot=with_screenshot, **kwargs
        )

    def get_df_lcp(self, with_screenshot=True, drop_duplicates=True, **kwargs):
        self.stop_uiautomator2_server()
        self.start_lcp_server()
        return self.backend_lcp.get_df(
            with_screenshot=with_screenshot, drop_duplicates=drop_duplicates, **kwargs
        ).dropna()

    def get_df_lcp_with_mouse_movement(
        self,
        with_screenshot=True,
        drop_duplicates=True,
        vertical=True,
        horizontal=True,
        use_every_n_element=5,
        sleep_after_movement=0.1,
        **kwargs,
    ):
        self.stop_uiautomator2_server()
        self.start_lcp_server()
        if vertical:
            move_mouse_to_beginning = self.get_cmd_mouse_action(
                self.screen_width // 2, 1
            )
            move_mouse_to_end = self.get_cmd_mouse_action(
                self.screen_width // 2, self.screen_height - 1
            )
            move_mouse_to_beginning(
                use_every_n_element=use_every_n_element, natural_movement=0
            )
            move_mouse_to_end(
                use_every_n_element=use_every_n_element, natural_movement=0
            )
        if horizontal:
            move_mouse_to_beginning = self.get_cmd_mouse_action(
                1, self.screen_height // 2
            )
            move_mouse_to_end = self.get_cmd_mouse_action(
                self.screen_width - 1, self.screen_height // 2
            )
            move_mouse_to_beginning(
                use_every_n_element=use_every_n_element, natural_movement=0
            )
            move_mouse_to_end(
                use_every_n_element=use_every_n_element, natural_movement=0
            )
        timesleep(sleep_after_movement)
        return self.get_df_lcp(
            with_screenshot=with_screenshot, drop_duplicates=drop_duplicates, **kwargs
        )

    def get_df_window_dump(self, with_screenshot=True, **kwargs):
        return self.backend_window_parser.get_df(
            with_screenshot=with_screenshot, **kwargs
        )

    def start_lcp_server(self):
        if not self._active_lcp:
            # self.stop_uiautomator2_server()
            lcp_cmd_1 = b"""qx="$(settings get secure enabled_accessibility_services)";rr="android.accessibilityservice.elparse/android.accessibilityservice.elparse.MyAccessibilityService";if [ "$qx" != "$rr" ]; then settings put secure enabled_accessibility_services "$rr";fi\n"""

            lcp_cmd_2 = f"""{self.su_exe} -c 'qx="$({self.system_bin_path}settings get secure enabled_accessibility_services)";rr="android.accessibilityservice.elparse/android.accessibilityservice.elparse.MyAccessibilityService";if [ "$qx" != "$rr" ]; then {self.system_bin_path}settings put secure enabled_accessibility_services "$rr";fi'\n""".encode()

            p = subprocess.Popen(
                self.sh_exe,
                shell=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                stdin=subprocess.PIPE,
                env=os.environ,
            )
            p.stdin.write(lcp_cmd_1)
            p.stdin.flush()
            p.stdin.write(lcp_cmd_2)
            p.stdin.flush()
            p.stdin.write(b"\nexit\n")
            p.stdin.flush()
            p.stdin.close()
            p.wait()
            self.backend_lcp.start_server()
            timesleep(3)
            self._active_lcp = True
            # self._active_uiautomator2 = False

    def start_uiautomator2_server(self):
        if not self._active_uiautomator2:
            # self.stop_lcp_server()
            self.backend_uiautomator2.start_server()
            timesleep(3)
            self._active_uiautomator2 = True
            # self._active_lcp = False

    def stop_uiautomator2_server(self):
        if self._active_uiautomator2:
            self.backend_uiautomator2.stop_server()
            self._active_uiautomator2 = False

    def stop_lcp_server(self):
        if self._active_lcp:
            self.backend_lcp.stop_server()
            self._active_lcp = False

    def download_and_install_uiautomator2_apks(self):
        self.backend_uiautomator2.download_apks()
        self.backend_uiautomator2.install_apks()

    def get_cmd_sendkeys(self, text: str, min_press=1, max_press=4):
        return SendEventWrite(
            exefile=self.exe_sendevent_multicommands_type_text,
            text=text,
            device_path=self.keyboard_device,
            min_time_key_press=min_press,
            max_time_key_press=max_press,
        )

    def get_cmd_input_tap(self, x: int, y: int):
        return InputClick(x, y, self.input_cmd)

    def get_cmd_sendevent_tap(self, x: int, y: int, **kwargs):
        return SendEventClick(
            x,
            y,
            self.touch_device,
            self.touch_device_max,
            self.screen_width,
            self.screen_height,
            self.sendevent_path,
            self.sh_exe,
            self.su_exe,
            0,
            **kwargs,
        )

    def get_cmd_sendevent_click(self, x: int, y: int, **kwargs):
        return SendEventClick(
            x,
            y,
            self.mouse_device,
            self.mouse_device_max,
            self.screen_width,
            self.screen_height,
            self.sendevent_path,
            self.sh_exe,
            self.su_exe,
            1,
            kwargs,
        )

    def get_cmd_send_text(self, text: str, **kwargs):
        return InputText(text, self.input_cmd_text, False)

    def get_cmd_send_text_natural(self, text: str, **kwargs):
        return InputText(text, self.input_cmd_text, True)

    def get_cmd_send_text_unicode(self, text: str, **kwargs):
        return UnicodeInputText(self.sh_exe, text, False, kwargs)

    def get_cmd_send_text_natural_unicode(self, text: str, **kwargs):
        return UnicodeInputText(self.sh_exe, text, True, kwargs)

    def get_cmd_mouse_action(self, x: int, y: int, **kwargs):
        return MouseAction(
            x,
            y,
            self.exe_mouse_sendevent_android,
            self.screen_width,
            self.screen_height,
            self.mouse_device,
            kwargs,
        )

    def kill_zombies(self):
        clean_zombies(
            sh_exe=self.sh_exe,
            su_exe=self.su_exe,
        )
        self._active_lcp = False
        self._active_uiautomator2 = False

    def open_shell(
        self,
        buffer_size=40960,
        exit_command=b"exit",
        print_stdout=False,
        print_stderr=False,
    ):
        return Shelly(
            shell_command=self.sh_exe,
            buffer_size=buffer_size,
            stdout_max_len=buffer_size,
            stderr_max_len=buffer_size,
            exit_command=exit_command,
            print_stdout=print_stdout,
            print_stderr=print_stderr,
            su_exe=self.su_exe,
            finish_cmd="HERE_IS_FINISH",
            system_bin=self.system_bin_path,
        )

    @staticmethod
    def find_suitable_devices_for_input_events():
        return find_suitable_devices_for_input_events()

    @staticmethod
    def get_resolution_of_screen():
        return get_resolution_of_screen()
