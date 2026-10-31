#!/usr/bin/env python3
"""Task list widget in the style of the to-do-list app. Tasks are kept in
~/.local/share/cyberpunk-dotfiles/todo.txt, one per line, with "x " in
front of the ones that are done (like todo.txt), so they can also be
edited by hand."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "common"))
from neon_widget import Gio, GLib, Gtk, GtkLayerShell, NeonWindow, label, run  # noqa: E402

TODO_FILE = Path(GLib.get_user_data_dir()) / "cyberpunk-dotfiles" / "todo.txt"
DELETE_ICON = "\U000F0156"
MAX_LIST_HEIGHT = 260


def read_tasks():
    try:
        lines = TODO_FILE.read_text().splitlines()
    except OSError:
        return []
    tasks = []
    for line in lines:
        if not line.strip():
            continue
        done = line.startswith("x ")
        tasks.append((line[2:] if done else line, done))
    return tasks


def write_tasks(tasks):
    TODO_FILE.parent.mkdir(parents=True, exist_ok=True)
    TODO_FILE.write_text("".join(("x " if done else "") + text + "\n" for text, done in tasks))


class Todo(NeonWindow):
    def __init__(self):
        super().__init__(
            __file__,
            "neon-todo",
            anchors=[GtkLayerShell.Edge.TOP, GtkLayerShell.Edge.RIGHT],
            margins={GtkLayerShell.Edge.TOP: 20, GtkLayerShell.Edge.RIGHT: 20},
            keyboard=True,
        )
        t = self.texts

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.get_style_context().add_class("widget")
        box.set_size_request(300, -1)
        self.add(box)

        header = Gtk.Box(spacing=8)
        header.pack_start(label(t.get("title", "Tasks").upper(), ["heading"]), True, True, 0)
        self.count = label(classes=["dim"], xalign=1.0, ellipsize=False)
        header.pack_end(self.count, False, False, 0)
        box.pack_start(header, False, False, 0)

        self.entry = Gtk.Entry(placeholder_text=t.get("placeholder", "New task"))
        self.entry.connect("activate", self.on_add)
        box.pack_start(self.entry, False, False, 0)

        # Grows with the list up to MAX_LIST_HEIGHT, then scrolls
        self.scroller = Gtk.ScrolledWindow(hscrollbar_policy=Gtk.PolicyType.NEVER)
        self.list = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self.scroller.add(self.list)
        box.pack_start(self.scroller, False, False, 0)

        self.empty = label(t.get("empty", "No tasks yet"), ["dim"])
        self.empty.set_no_show_all(True)
        box.pack_start(self.empty, False, False, 0)

        # Reload when the file changes, also when edited by hand
        TODO_FILE.parent.mkdir(parents=True, exist_ok=True)
        self.file_monitor = Gio.File.new_for_path(str(TODO_FILE)).monitor_file(
            Gio.FileMonitorFlags.NONE, None
        )
        self.file_monitor.connect("changed", lambda *_: GLib.idle_add(self.refresh))
        self.refresh()

    def refresh(self):
        self.tasks = read_tasks()
        for child in self.list.get_children():
            child.destroy()

        for index, (text, done) in enumerate(self.tasks):
            row = Gtk.Box(spacing=10)

            check = Gtk.Button()
            check.get_style_context().add_class("check")
            if done:
                check.get_style_context().add_class("done")
            check.set_valign(Gtk.Align.CENTER)
            check.connect("clicked", lambda _, i=index: self.on_toggle(i))
            row.pack_start(check, False, False, 0)

            name = label(text, ["dim"] if done else [], max_chars=26)
            name.set_line_wrap(False)
            if done:
                name.set_markup(f"<s>{GLib.markup_escape_text(text)}</s>")
            row.pack_start(name, True, True, 0)

            delete = Gtk.Button(label=DELETE_ICON)
            delete.get_style_context().add_class("flat")
            delete.connect("clicked", lambda _, i=index: self.on_delete(i))
            row.pack_end(delete, False, False, 0)

            self.list.pack_start(row, False, False, 0)

        done_count = sum(1 for _, done in self.tasks if done)
        self.count.set_text(f"{done_count}/{len(self.tasks)}" if self.tasks else "")
        self.empty.set_visible(not self.tasks)
        self.list.show_all()
        _, natural = self.list.get_preferred_height()
        self.scroller.set_min_content_height(min(natural, MAX_LIST_HEIGHT))
        self.scroller.set_visible(bool(self.tasks))
        return False

    def on_add(self, entry):
        text = entry.get_text().strip()
        if text:
            write_tasks(self.tasks + [(text, False)])
            entry.set_text("")
            self.refresh()

    def on_toggle(self, index):
        text, done = self.tasks[index]
        self.tasks[index] = (text, not done)
        write_tasks(self.tasks)
        self.refresh()

    def on_delete(self, index):
        del self.tasks[index]
        write_tasks(self.tasks)
        self.refresh()


if __name__ == "__main__":
    run(Todo())
