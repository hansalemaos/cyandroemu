import os
import subprocess
import json
import requests

this_folder = os.path.dirname(os.path.abspath(__file__))
json_file = os.path.join(this_folder, "cpp_parsers.json")
link_uiautomator_dump_without_could_not_detect_idle_state = "https://github.com/hansalemaos/uiautomator_dump_without_could_not_detect_idle_state/raw/refs/heads/main/uiautomatorcpulimit.cpp"
link_uiautomator_dump_to_csv = "https://github.com/hansalemaos/uiautomator_dump_to_csv/raw/refs/heads/main/uiautomatornolimit.cpp"
link_sendevent_multicommands_type_text = "https://github.com/hansalemaos/sendevent_multicommands_type_text/raw/refs/heads/main/sendeventall.cpp"
link_mouse_sendevent_android = "https://github.com/hansalemaos/mouse_sendevent_android/raw/refs/heads/main/sendeventmouse.cpp"
link_getevent_keydumper_linux = "https://github.com/hansalemaos/getevent_keydumper_linux/raw/refs/heads/main/newgetevent.cpp"
link_getevent_pretty_print_linux = "https://github.com/hansalemaos/getevent_pretty_print_linux/raw/refs/heads/main/geteventall.cpp"
link_android_fragment_parser = "https://github.com/hansalemaos/android_fragment_parser/raw/refs/heads/main/fragmentdumper.cpp"
link_uiautomator_eventsparser_cpp = "https://github.com/hansalemaos/uiautomator_eventsparser_cpp/raw/refs/heads/main/eventparser.cpp"
link_lcp = "https://github.com/hansalemaos/elparse/raw/refs/heads/main/elparse.cpp"
link_lcp_apk = (
    "https://github.com/hansalemaos/elparse/raw/refs/heads/main/app-release.apk"
)
link_uiautomator2tocsv = "https://github.com/hansalemaos/uiautomator2tocsv/raw/refs/heads/main/uiautomator2parser.cpp"
link_screencaptoppm = "https://github.com/hansalemaos/screencap_uncompressed_screenshots/raw/refs/heads/main/screencaptoppm.cpp"
link_hocr2csv = "https://github.com/hansalemaos/screencap2tesseract2csv/raw/refs/heads/main/tesseractwithimagemagick.cpp"

folder_uiautomator_dump_without_could_not_detect_idle_state = os.path.join(
    this_folder, "uiautomator_dump_without_could_not_detect_idle_state"
)
folder_uiautomator_dump_to_csv = os.path.join(this_folder, "uiautomator_dump_to_csv")
folder_sendevent_multicommands_type_text = os.path.join(
    this_folder, "sendevent_multicommands_type_text"
)
folder_mouse_sendevent_android = os.path.join(this_folder, "mouse_sendevent_android")
folder_getevent_keydumper_linux = os.path.join(this_folder, "getevent_keydumper_linux")
folder_getevent_pretty_print_linux = os.path.join(
    this_folder, "getevent_pretty_print_linux"
)
folder_android_fragment_parser = os.path.join(this_folder, "android_fragment_parser")
folder_uiautomator_eventsparser_cpp = os.path.join(
    this_folder, "uiautomator_eventsparser_cpp"
)
folder_lcp = os.path.join(this_folder, "lcp")
folder_uiautomator2tocsv = os.path.join(this_folder, "uiautomator2tocsv")
folder_screencaptoppm = os.path.join(this_folder, "screencaptoppm")
folder_hocr2csv = os.path.join(this_folder, "hocr2csv")


def _download_and_save(link, folder, filename):
    filepath = os.path.join(
        folder,
        filename,
    )
    with requests.get(link) as r:
        with open(
            filepath,
            "wb",
        ) as f:
            f.write(r.content)
    return filepath


def download_uiautomator_dump_without_could_not_detect_idle_state():
    return _download_and_save(
        link_uiautomator_dump_without_could_not_detect_idle_state,
        folder_uiautomator_dump_without_could_not_detect_idle_state,
        "cppfile.cpp",
    )


def download_uiautomator_dump_to_csv():
    return _download_and_save(
        link_uiautomator_dump_to_csv,
        folder_uiautomator_dump_to_csv,
        "cppfile.cpp",
    )


def download_sendevent_multicommands_type_text():
    return _download_and_save(
        link_sendevent_multicommands_type_text,
        folder_sendevent_multicommands_type_text,
        "cppfile.cpp",
    )


def download_mouse_sendevent_android():
    return _download_and_save(
        link_mouse_sendevent_android,
        folder_mouse_sendevent_android,
        "cppfile.cpp",
    )


def download_getevent_pretty_print_linux():
    return _download_and_save(
        link_getevent_pretty_print_linux,
        folder_getevent_pretty_print_linux,
        "cppfile.cpp",
    )


def download_android_fragment_parser():
    return _download_and_save(
        link_android_fragment_parser,
        folder_android_fragment_parser,
        "cppfile.cpp",
    )


def download_uiautomator_eventsparser_cpp():
    return _download_and_save(
        link_uiautomator_eventsparser_cpp,
        folder_uiautomator_eventsparser_cpp,
        "cppfile.cpp",
    )


def download_lcp():
    return _download_and_save(
        link_lcp,
        folder_lcp,
        "cppfile.cpp",
    )


def download_getevent_keydumper_linux():
    return _download_and_save(
        link_getevent_keydumper_linux,
        folder_getevent_keydumper_linux,
        "cppfile.cpp",
    )


def download_uiautomator2tocsv():
    return _download_and_save(
        link_uiautomator2tocsv,
        folder_uiautomator2tocsv,
        "cppfile.cpp",
    )


def download_screencaptoppm():
    return _download_and_save(
        link_screencaptoppm,
        folder_screencaptoppm,
        "cppfile.cpp",
    )


def download_hocr2csv():
    return _download_and_save(
        link_hocr2csv,
        folder_hocr2csv,
        "cppfile.cpp",
    )


def download_all_scripts():
    return (
        download_uiautomator_dump_without_could_not_detect_idle_state(),
        download_uiautomator_dump_to_csv(),
        download_sendevent_multicommands_type_text(),
        download_mouse_sendevent_android(),
        download_getevent_keydumper_linux(),
        download_getevent_pretty_print_linux(),
        download_android_fragment_parser(),
        # download_uiautomator_eventsparser_cpp(),
        download_lcp(),
        download_uiautomator2tocsv(),
        # download_screencaptoppm(),
        download_hocr2csv(),
    )


def compile_files(
    allscripts,
    compiler=r"g++",
    compiler_args=(
        "-std=c++2a",
        "-O3",
        "-g0",
        "-march=native",
        "-mtune=native",
        "-o",
        "a.out",
    ),
):
    compiler_args = (compiler,) + compiler_args
    all_executable_files = {}
    current_working_dict = os.getcwd()
    for script in allscripts:
        next_working_dict = os.path.dirname(script)
        os.chdir(next_working_dict)
        cmd2execute = compiler_args + (script,)
        subprocess.run(
            " ".join(cmd2execute),
            shell=True,
            env=os.environ,
            cwd=next_working_dict,
        )
        executable_file = os.path.join(next_working_dict, "a.out")
        spli = next_working_dict.split(os.sep)
        all_executable_files[spli[len(spli) - 1]] = executable_file
    os.chdir(current_working_dict)
    return all_executable_files


def download_and_compile_files(gcc_exe="g++"):
    allscripts = download_all_scripts()
    jsondata = compile_files(
        allscripts,
        compiler=gcc_exe,
        compiler_args=(
            "-std=c++2a",
            "-O3",
            "-g0",
            "-march=native",
            "-mtune=native",
            "-o",
            "a.out",
        ),
    )

    with open(json_file, mode="w", encoding="utf-8") as f:
        f.write(json.dumps(jsondata))
    return jsondata


def makedirs_for_plugins():
    os.makedirs(folder_screencaptoppm, exist_ok=True)
    os.makedirs(folder_hocr2csv, exist_ok=True)
    os.makedirs(
        folder_uiautomator_dump_without_could_not_detect_idle_state, exist_ok=True
    )
    os.makedirs(folder_uiautomator_dump_to_csv, exist_ok=True)
    os.makedirs(folder_sendevent_multicommands_type_text, exist_ok=True)
    os.makedirs(folder_mouse_sendevent_android, exist_ok=True)
    os.makedirs(folder_getevent_keydumper_linux, exist_ok=True)
    os.makedirs(folder_getevent_pretty_print_linux, exist_ok=True)
    os.makedirs(folder_android_fragment_parser, exist_ok=True)
    os.makedirs(folder_uiautomator_eventsparser_cpp, exist_ok=True)
    os.makedirs(folder_lcp, exist_ok=True)
    os.makedirs(folder_getevent_keydumper_linux, exist_ok=True)
    os.makedirs(folder_uiautomator2tocsv, exist_ok=True)


def load_parser_paths():
    with open(json_file, "r", encoding="utf-8") as f:
        data = f.read()
    return json.loads(data)


def load_parser_paths_or_compile(gcc_exe="g++"):
    makedirs_for_plugins()
    try:
        return load_parser_paths()
    except Exception:
        download_and_compile_files(gcc_exe=gcc_exe)
        return load_parser_paths()
