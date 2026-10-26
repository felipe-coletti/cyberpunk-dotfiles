#!/usr/bin/env python3
"""Color wheel to pick the neon color.

Usage: picker.py [RRGGBB]
Prints the chosen color (RRGGBB) and exits with 0; on cancel, exits with 1.
The labels come from the NEON_* variables (set by pick.sh).
"""

import colorsys
import math
import os
import sys

import cairo
import gi

gi.require_version("Gdk", "3.0")
gi.require_version("Gtk", "3.0")
from gi.repository import Gdk, GLib, Gtk  # noqa: E402

DEFAULT = "ffffff"
WHEEL_SIZE = 240
WHEEL_PADDING = 8  # room so the marker is not cut off at the edge
MIN_BRIGHTNESS = 0.2  # below this the neon fades into the black background


def text(key, fallback):
    return os.environ.get(f"NEON_{key}") or fallback


def parse_hex(value):
    value = value.strip().lstrip("#").lower()
    if len(value) == 6 and all(c in "0123456789abcdef" for c in value):
        return value
    return None


def hex_to_rgb(value):
    return tuple(int(value[i:i + 2], 16) / 255 for i in (0, 2, 4))


def rgb_to_hex(r, g, b):
    return "".join(f"{round(c * 255):02x}" for c in (r, g, b))


class Picker(Gtk.Window):
    def __init__(self, initial):
        super().__init__(title=text("TITLE", "Neon color"))
        self.set_resizable(False)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.result = None
        self.syncing = False  # avoids loops between the hex field and the wheel
        self.wheel_cache = None

        self.css = Gtk.CssProvider()
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), self.css,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=16)
        root.set_border_width(20)
        self.add(root)

        heading = Gtk.Label(label=text("TITLE", "Neon color").upper(), xalign=0)
        heading.get_style_context().add_class("heading")
        root.pack_start(heading, False, False, 0)

        # Wheel: angle = hue, distance from the center = saturation (center = white)
        self.wheel = Gtk.DrawingArea()
        self.wheel.set_size_request(WHEEL_SIZE, WHEEL_SIZE)
        self.wheel.add_events(
            Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_MOTION_MASK
        )
        self.wheel.connect("draw", self.on_draw)
        self.wheel.connect("button-press-event", self.on_pointer)
        self.wheel.connect("motion-notify-event", self.on_pointer)
        root.pack_start(self.wheel, False, False, 0)

        brightness_label = Gtk.Label(
            label=text("BRIGHTNESS", "Brightness").upper(), xalign=0
        )
        root.pack_start(brightness_label, False, False, 0)

        self.brightness = Gtk.Scale.new_with_range(
            Gtk.Orientation.HORIZONTAL, MIN_BRIGHTNESS, 1, 0.01
        )
        self.brightness.set_draw_value(False)
        self.brightness.connect("value-changed", self.on_brightness)
        root.pack_start(self.brightness, False, False, 0)

        row = Gtk.Box(spacing=8)
        self.swatch = Gtk.Box()
        self.swatch.get_style_context().add_class("swatch")
        self.entry = Gtk.Entry(max_length=7, width_chars=8)
        self.entry.connect("changed", self.on_entry)
        self.entry.connect("activate", lambda *_: self.apply())
        row.pack_start(self.swatch, False, False, 0)
        row.pack_start(self.entry, True, True, 0)
        root.pack_start(row, False, False, 0)

        buttons = Gtk.Box(spacing=8)
        reset = Gtk.Button(label=text("DEFAULT", "Default").upper())
        reset.connect("clicked", lambda *_: self.set_hex(DEFAULT))
        cancel = Gtk.Button(label=text("CANCEL", "Cancel").upper())
        cancel.connect("clicked", lambda *_: self.destroy())
        apply = Gtk.Button(label=text("APPLY", "Apply").upper())
        apply.get_style_context().add_class("primary")
        apply.connect("clicked", lambda *_: self.apply())
        buttons.pack_start(reset, False, False, 0)
        buttons.pack_end(apply, False, False, 0)
        buttons.pack_end(cancel, False, False, 0)
        root.pack_start(buttons, False, False, 0)

        self.connect("key-press-event", self.on_key)
        self.connect("destroy", Gtk.main_quit)

        self.set_hex(initial)

    # ─── State ──────────────────────────────────────────────
    @property
    def hex(self):
        return rgb_to_hex(*colorsys.hsv_to_rgb(self.h, self.s, self.v))

    def set_hex(self, value):
        self.h, self.s, self.v = colorsys.rgb_to_hsv(*hex_to_rgb(value))
        self.v = max(self.v, MIN_BRIGHTNESS)
        self.refresh()

    def refresh(self, from_entry=False):
        self.syncing = True
        self.brightness.set_value(self.v)
        if not from_entry:
            self.entry.set_text(f"#{self.hex}")
        self.syncing = False
        self.restyle()
        self.wheel.queue_draw()

    def apply(self):
        self.result = self.hex
        self.destroy()

    # ─── Events ─────────────────────────────────────────────
    def on_pointer(self, area, event):
        size = min(area.get_allocated_width(), area.get_allocated_height())
        c = size / 2
        radius = c - WHEEL_PADDING
        dx, dy = event.x - c, c - event.y
        self.s = max(0, min(math.hypot(dx, dy) / max(radius, 1), 1))
        self.h = (math.atan2(dy, dx) / (2 * math.pi)) % 1
        self.refresh()
        return True

    def on_brightness(self, scale):
        if not self.syncing:
            self.v = scale.get_value()
            self.refresh()

    def on_entry(self, entry):
        if self.syncing:
            return
        value = parse_hex(entry.get_text())
        if value:
            self.h, self.s, self.v = colorsys.rgb_to_hsv(*hex_to_rgb(value))
            self.v = max(self.v, MIN_BRIGHTNESS)
            self.refresh(from_entry=True)

    def on_key(self, _, event):
        if event.keyval == Gdk.KEY_Escape:
            self.destroy()
            return True
        return False

    # ─── Drawing ────────────────────────────────────────────
    def render_wheel(self, size):
        surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, size, size)
        cr = cairo.Context(surface)
        c = size / 2
        radius = c - WHEEL_PADDING
        # No antialiasing on the slices, otherwise seams show between them
        cr.set_antialias(cairo.ANTIALIAS_NONE)
        # One slice per degree, with a gradient from white (center) to the hue
        for degree in range(360):
            r, g, b = colorsys.hsv_to_rgb(degree / 360, 1, 1)
            gradient = cairo.RadialGradient(c, c, 0, c, c, radius)
            gradient.add_color_stop_rgb(0, 1, 1, 1)
            gradient.add_color_stop_rgb(1, r, g, b)
            cr.set_source(gradient)
            cr.move_to(c, c)
            # Negative angles: the hue grows counterclockwise
            cr.arc(c, c, radius, math.radians(-degree - 1.5), math.radians(-degree + 0.5))
            cr.close_path()
            cr.fill()
        return surface

    def on_draw(self, area, cr):
        size = min(area.get_allocated_width(), area.get_allocated_height())
        if self.wheel_cache is None or self.wheel_cache.get_width() != size:
            self.wheel_cache = self.render_wheel(size)

        c = size / 2
        radius = c - WHEEL_PADDING

        # Clip to an antialiased circle so the edge of the wheel is smooth
        cr.arc(c, c, radius, 0, 2 * math.pi)
        cr.clip()
        cr.set_source_surface(self.wheel_cache, 0, 0)
        cr.paint()

        # Brightness: darkens the whole wheel
        cr.set_source_rgba(0, 0, 0, 1 - self.v)
        cr.paint()
        cr.reset_clip()
        # Square marker, outlined in black so it shows over white
        angle = self.h * 2 * math.pi
        x = c + math.cos(angle) * self.s * radius
        y = c - math.sin(angle) * self.s * radius
        cr.rectangle(x - 6, y - 6, 12, 12)
        cr.set_source_rgb(0, 0, 0)
        cr.set_line_width(4)
        cr.stroke_preserve()
        cr.set_source_rgb(1, 1, 1)
        cr.set_line_width(1.5)
        cr.stroke()
        return False

    def restyle(self):
        # The window itself uses the chosen color, as a theme preview
        n = f"#{self.hex}"
        self.css.load_from_data(f"""
            window {{ background-color: #000000; }}
            * {{
                font-family: "JetBrainsMono Nerd Font", monospace;
                font-size: 12px;
                color: {n};
                text-shadow: 0 0 3px {n};
            }}
            .heading {{ font-size: 16px; }}
            entry, button {{
                background: transparent;
                border: 1px solid {n};
                border-radius: 0;
                box-shadow: 0 0 3px {n}, inset 0 0 3px {n};
                caret-color: {n};
                padding: 6px 10px;
            }}
            entry:focus, button:hover {{ background-color: alpha({n}, 0.15); }}
            button.primary {{ background-color: {n}; }}
            button.primary label {{ color: #000000; text-shadow: none; }}
            .swatch {{
                background-color: {n};
                box-shadow: 0 0 6px {n};
                min-width: 34px;
            }}
            scale trough {{
                background-color: alpha({n}, 0.25);
                border: none;
                border-radius: 0;
                min-height: 2px;
            }}
            scale highlight {{ background-color: {n}; box-shadow: 0 0 3px {n}; }}
            scale slider {{
                background: #000000;
                border: 1px solid {n};
                border-radius: 0;
                box-shadow: 0 0 3px {n};
                min-height: 12px;
                min-width: 12px;
            }}
        """.encode())


def main():
    initial = parse_hex(sys.argv[1]) if len(sys.argv) > 1 else None
    # app_id on Wayland, used by the Hyprland window rule
    GLib.set_prgname("neon-picker")
    picker = Picker(initial or DEFAULT)
    picker.show_all()
    Gtk.main()

    if picker.result is None:
        sys.exit(1)
    print(picker.result)


if __name__ == "__main__":
    main()
