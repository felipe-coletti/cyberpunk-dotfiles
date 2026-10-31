"""Shared base for the desktop widgets: a layer-shell window on the
desktop, the widget's style and translations, and the live color change.

Each widget is a folder with a main.py, a style.css (which imports
common/base.css) and an i18n folder with one <language>.sh per language."""

import os
from pathlib import Path

import gi

gi.require_version("Gdk", "3.0")
gi.require_version("GdkPixbuf", "2.0")
gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
gi.require_version("Pango", "1.0")
from gi.repository import Gdk, Gio, GLib, Gtk, GtkLayerShell, Pango  # noqa: E402

# apply.sh rewrites this file every time the neon changes
NEON_CSS = Path.home() / ".config/colors/neon.css"


def texts(i18n_dir):
    """Translations for the system language, chosen like lang.sh does:
    exact language, then the same language from another region, then en_US"""
    lang = os.environ.get("LC_ALL") or os.environ.get("LC_MESSAGES") or os.environ.get("LANG") or ""
    lang = lang.split(".")[0]
    candidates = [i18n_dir / f"{lang}.sh"]
    candidates += sorted(i18n_dir.glob(f"{lang.split('_')[0]}_*.sh")) if lang else []
    candidates.append(i18n_dir / "en_US.sh")
    path = next((p for p in candidates if p.is_file()), None)
    if path is None:
        return {}

    values = {}
    for line in path.read_text().splitlines():
        key, sep, value = line.partition("=")
        if sep and key.isidentifier():
            values[key] = value.strip().strip('"')
    return values


class NeonWindow(Gtk.Window):
    """A window fixed on the desktop (under the other windows), in the neon
    color, recolored whenever the color wheel changes it.

    widget_file is the widget's main.py: its folder holds style.css and i18n"""

    def __init__(self, widget_file, namespace, anchors, margins, keyboard=False):
        super().__init__()
        folder = Path(widget_file).resolve().parent
        self.style_file = folder / "style.css"
        self.texts = texts(folder / "i18n")

        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_namespace(self, namespace)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.BOTTOM)
        for edge in anchors:
            GtkLayerShell.set_anchor(self, edge, True)
        for edge, margin in margins.items():
            GtkLayerShell.set_margin(self, edge, margin)
        GtkLayerShell.set_keyboard_mode(
            self,
            GtkLayerShell.KeyboardMode.ON_DEMAND if keyboard else GtkLayerShell.KeyboardMode.NONE,
        )

        # Above the user's gtk.css: it also imports the palette, and GTK takes
        # @neon from the provider with the highest priority. Since that one
        # never reloads, the widgets would keep the color they started with
        self.provider = Gtk.CssProvider()
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), self.provider, Gtk.STYLE_PROVIDER_PRIORITY_USER + 1
        )
        self.recolor()

        # Loading the style again also reads the new neon.css it imports
        self.color_monitor = Gio.File.new_for_path(str(NEON_CSS)).monitor_file(
            Gio.FileMonitorFlags.NONE, None
        )
        self.color_monitor.connect("changed", lambda *_: GLib.idle_add(self.recolor))
        self.connect("destroy", Gtk.main_quit)

    def recolor(self):
        try:
            self.provider.load_from_path(str(self.style_file))
        except GLib.Error:
            pass  # neon.css caught halfway through being written; the next change reloads it
        return False


def label(text="", classes=(), xalign=0.0, ellipsize=True, max_chars=28):
    widget = Gtk.Label(label=text, xalign=xalign)
    if ellipsize:
        widget.set_ellipsize(Pango.EllipsizeMode.END)
        widget.set_max_width_chars(max_chars)
    for name in classes:
        widget.get_style_context().add_class(name)
    return widget


def run(window):
    window.show_all()
    Gtk.main()
