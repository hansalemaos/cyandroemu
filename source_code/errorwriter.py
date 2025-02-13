import sys
import traceback
import os


class JustColors:
    def __init__(self):
        self.BOLD = "\033[1m"
        self.ITALIC = "\033[3m"
        self.UNDERLINE = "\033[4m"
        self.UNDERLINE_THICK = "\033[21m"
        self.HIGHLIGHTED = "\033[7m"
        self.HIGHLIGHTED_BLACK = "\033[40m"
        self.HIGHLIGHTED_RED = "\033[41m"
        self.HIGHLIGHTED_GREEN = "\033[42m"
        self.HIGHLIGHTED_YELLOW = "\033[43m"
        self.HIGHLIGHTED_BLUE = "\033[44m"
        self.HIGHLIGHTED_PURPLE = "\033[45m"
        self.HIGHLIGHTED_CYAN = "\033[46m"
        self.HIGHLIGHTED_GREY = "\033[47m"
        self.HIGHLIGHTED_GREY_LIGHT = "\033[100m"
        self.HIGHLIGHTED_RED_LIGHT = "\033[101m"
        self.HIGHLIGHTED_GREEN_LIGHT = "\033[102m"
        self.HIGHLIGHTED_YELLOW_LIGHT = "\033[103m"
        self.HIGHLIGHTED_BLUE_LIGHT = "\033[104m"
        self.HIGHLIGHTED_PURPLE_LIGHT = "\033[105m"
        self.HIGHLIGHTED_CYAN_LIGHT = "\033[106m"
        self.HIGHLIGHTED_WHITE_LIGHT = "\033[107m"
        self.STRIKE_THROUGH = "\033[9m"
        self.MARGIN_1 = "\033[51m"
        self.MARGIN_2 = "\033[52m"
        self.BLACK = "\033[30m"
        self.RED_DARK = "\033[31m"
        self.GREEN_DARK = "\033[32m"
        self.YELLOW_DARK = "\033[33m"
        self.BLUE_DARK = "\033[34m"
        self.PURPLE_DARK = "\033[35m"
        self.CYAN_DARK = "\033[36m"
        self.GREY_DARK = "\033[37m"
        self.BLACK_LIGHT = "\033[90m"
        self.RED = "\033[91m"
        self.GREEN = "\033[92m"
        self.YELLOW = "\033[93m"
        self.BLUE = "\033[94m"
        self.PURPLE = "\033[95m"
        self.CYAN = "\033[96m"
        self.WHITE = "\033[97m"
        self.DEFAULT = "\033[0m"


mycolors = JustColors()


def printincolor(values, color=None, print_to_stderr=False):
    s1 = "GOT AN ERROR DURING PRINTING"
    if color:
        try:
            s1 = "%s%s%s" % (color, values, mycolors.DEFAULT)
        except Exception:
            if isinstance(values, bytes):
                s1 = "%s%s%s" % (
                    color,
                    values.decode("utf-8", "backslashreplace"),
                    mycolors.DEFAULT,
                )
            else:
                s1 = "%s%s%s" % (color, repr(values), mycolors.DEFAULT)
        if print_to_stderr:
            sys.stderr.flush()
            sys.stderr.write(f"{s1}\n")
            sys.stderr.flush()
        else:
            print(s1)

    else:
        try:
            s1 = "%s%s" % (values, mycolors.DEFAULT)
        except Exception:
            if isinstance(values, bytes):
                s1 = "%s%s" % (
                    values.decode("utf-8", "backslashreplace"),
                    mycolors.DEFAULT,
                )
            else:
                s1 = "%s%s" % (repr(values), mycolors.DEFAULT)
        if print_to_stderr:
            sys.stderr.flush()
            sys.stderr.write(f"{s1}\n")
            sys.stderr.flush()
        else:
            print(s1)


def errwrite(*args, **kwargs):
    symbol_top = kwargs.pop("symbol_top", "╦")
    symbol_bottom = kwargs.pop("symbol_bottom", "╩")
    len_top = kwargs.pop("len_top", "60")
    len_bottom = kwargs.pop("len_bottom", "60")
    color_top = kwargs.pop("color_top", "YELLOW_DARK")
    color_bottom = kwargs.pop("color_bottom", "RED_DARK")
    print_to_stderr = kwargs.pop("print_to_stderr", False)
    color_exception = kwargs.pop("color_exception", "CYAN")
    color2print_top = None
    color2print_bottom = None
    color_exceptionmiddle = None
    try:
        color2print_top = mycolors.__dict__.get(
            color_top, mycolors.__dict__.get("YELLOW_DARK")
        )
        color2print_bottom = mycolors.__dict__.get(
            color_bottom, mycolors.__dict__.get("RED_DARK")
        )
        color_exceptionmiddle = mycolors.__dict__.get(
            color_exception, mycolors.__dict__.get("CYAN")
        )
    except Exception as e:
        print(e)

    printincolor(
        values="".join(symbol_top * int(len_top)),
        color=color2print_top,
        print_to_stderr=print_to_stderr,
    )
    etype, value, tb = sys.exc_info()
    lines = traceback.format_exception(etype, value, tb)
    try:
        if print_to_stderr:
            sys.stderr.flush()

            sys.stderr.write("".join(lines))
            sys.stderr.flush()
        else:
            printincolor(
                "".join(lines),
                color=color_exceptionmiddle,
                print_to_stderr=print_to_stderr,
            )
    except Exception:
        print("".join(lines))
    printincolor(
        "".join(symbol_bottom * int(len_bottom)),
        color=color2print_bottom,
        print_to_stderr=print_to_stderr,
    )
