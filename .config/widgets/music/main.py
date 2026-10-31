#!/usr/bin/env python3
"""Music widget: cover, title, artist and controls of the player that is
playing (Spotify, browsers, mpv...), through playerctl."""

import hashlib
import subprocess
import sys
import threading
import urllib.request
from pathlib import Path
from urllib.parse import unquote, urlparse

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "common"))
from neon_widget import GLib, Gtk, GtkLayerShell, NeonWindow, label, run  # noqa: E402
from gi.repository import GdkPixbuf  # noqa: E402

CACHE = Path(GLib.get_user_cache_dir()) / "neon-widgets"
COVER_SIZE = 64
SEP = "\t"
RESTART_DELAY = 5  # seconds before starting playerctl again if it stops

ICONS = {
    "previous": "\U000F04AE",
    "play": "\U000F040A",
    "pause": "\U000F03E4",
    "next": "\U000F04AD",
    "music": "\U000F075A",
}


class Music(NeonWindow):
    def __init__(self):
        super().__init__(
            __file__,
            "neon-music",
            anchors=[GtkLayerShell.Edge.BOTTOM, GtkLayerShell.Edge.RIGHT],
            margins={GtkLayerShell.Edge.BOTTOM: 20, GtkLayerShell.Edge.RIGHT: 20},
        )
        t = self.texts
        self.cover_url = None

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.get_style_context().add_class("widget")
        box.set_size_request(300, -1)
        self.add(box)

        box.pack_start(label(t.get("title", "Now playing").upper(), ["heading"]), False, False, 0)

        row = Gtk.Box(spacing=12)
        self.cover = Gtk.Image()
        self.cover.get_style_context().add_class("cover")
        self.cover_icon = label(ICONS["music"], ["big-icon", "dim"], xalign=0.5, ellipsize=False)
        self.cover_icon.set_size_request(COVER_SIZE, COVER_SIZE)
        self.cover_stack = Gtk.Stack()
        self.cover_stack.add_named(self.cover_icon, "icon")
        self.cover_stack.add_named(self.cover, "image")
        row.pack_start(self.cover_stack, False, False, 0)

        info = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        info.set_valign(Gtk.Align.CENTER)
        self.title = label(max_chars=22)
        self.artist = label(classes=["dim"], max_chars=22)
        info.pack_start(self.title, False, False, 0)
        info.pack_start(self.artist, False, False, 0)
        row.pack_start(info, True, True, 0)
        box.pack_start(row, False, False, 0)

        self.controls = Gtk.Box(spacing=8, halign=Gtk.Align.CENTER)
        self.play_button = None
        for action in ("previous", "play-pause", "next"):
            button = Gtk.Button(label=ICONS.get(action, ICONS["play"]))
            button.get_style_context().add_class("icon")
            button.connect("clicked", lambda _, a=action: self.control(a))
            if action == "play-pause":
                self.play_button = button
            self.controls.pack_start(button, False, False, 0)
        box.pack_start(self.controls, False, False, 0)

        self.show_nothing()
        self.follow()

    # ─── playerctl ──────────────────────────────────────────
    def follow(self):
        """playerctl --follow prints a line on every change of song or state,
        and an empty line when no player is left"""
        fmt = SEP.join(["{{status}}", "{{artist}}", "{{title}}", "{{mpris:artUrl}}"])
        try:
            self.process = subprocess.Popen(
                ["playerctl", "--follow", "metadata", "--format", fmt],
                stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, bufsize=1,
            )
        except FileNotFoundError:
            return False
        GLib.io_add_watch(self.process.stdout, GLib.PRIORITY_DEFAULT,
                          GLib.IOCondition.IN | GLib.IOCondition.HUP, self.on_line)
        return False

    def on_line(self, stream, condition):
        line = stream.readline()
        if not line:
            # playerctl stopped (for example, D-Bus restarted): start it again
            self.show_nothing()
            GLib.timeout_add_seconds(RESTART_DELAY, self.follow)
            return False
        line = line.rstrip("\n")
        fields = line.split(SEP)
        if len(fields) < 4 or not (fields[1] or fields[2]):
            self.show_nothing()
        else:
            self.show(*fields[:4])
        return True

    def control(self, action):
        subprocess.Popen(["playerctl", action], stderr=subprocess.DEVNULL)

    # ─── Display ────────────────────────────────────────────
    def show(self, status, artist, title, art_url):
        self.title.set_text(title or artist)
        self.artist.set_text(artist if title else "")
        self.play_button.set_label(ICONS["pause"] if status == "Playing" else ICONS["play"])
        self.controls.set_sensitive(True)
        if art_url != self.cover_url:
            self.cover_url = art_url
            self.load_cover(art_url)

    def show_nothing(self):
        self.title.set_text(self.texts.get("nothing_playing", "Nothing playing"))
        self.artist.set_text("")
        self.play_button.set_label(ICONS["play"])
        self.controls.set_sensitive(False)
        self.cover_url = None
        self.cover_stack.set_visible_child_name("icon")

    def load_cover(self, url):
        """Local covers load right away; web covers (Spotify, browsers) are
        downloaded once to the cache, without blocking the widget"""
        if not url:
            self.cover_stack.set_visible_child_name("icon")
            return
        parsed = urlparse(url)
        if parsed.scheme == "file":
            self.set_cover(Path(unquote(parsed.path)), url)
        elif parsed.scheme in ("http", "https"):
            path = CACHE / hashlib.sha1(url.encode()).hexdigest()
            if path.is_file():
                self.set_cover(path, url)
            else:
                threading.Thread(target=self.download, args=(url, path), daemon=True).start()

    def download(self, url, path):
        try:
            CACHE.mkdir(parents=True, exist_ok=True)
            with urllib.request.urlopen(url, timeout=10) as response:
                path.write_bytes(response.read())
        except OSError:
            return
        GLib.idle_add(self.set_cover, path, url)

    def set_cover(self, path, url):
        if url != self.cover_url:
            return False  # the song changed while the cover downloaded
        try:
            pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(str(path), COVER_SIZE, COVER_SIZE, False)
        except GLib.Error:
            self.cover_stack.set_visible_child_name("icon")
            return False
        self.cover.set_from_pixbuf(pixbuf)
        self.cover_stack.set_visible_child_name("image")
        return False


if __name__ == "__main__":
    run(Music())
