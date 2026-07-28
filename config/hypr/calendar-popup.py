#!/usr/bin/env python3
import calendar
import datetime as dt
import os
import signal
import sys

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Gdk", "4.0")
from gi.repository import Gdk, Gtk

PID_FILE = "/tmp/feng-calendar-popup.pid"
APP_ID = "cn.fengluoxiao.CalendarPopup"

CSS = """
window.feng-calendar-window { background: transparent; }
.calendar-card { background: #f8fbfd; color: #15232d; border: 1px solid #b8dff2; border-radius: 22px; padding: 18px; box-shadow: none; }
.calendar-title { font-size: 18px; font-weight: 800; color: #15232d; }
.calendar-subtitle { color: #50616d; font-size: 13px; font-weight: 600; }
.calendar-nav { background-color: #e8f1f7; background-image: none; color: #123244; border-radius: 16px; min-width: 34px; min-height: 34px; padding: 0; }
.calendar-nav:hover, .footer-button:hover { background-color: #881144; background-image: none; color: #ffffff; }
.month-label { color: #123244; font-size: 15px; font-weight: 800; }
.weekday { color: #50616d; font-size: 12px; font-weight: 800; }
.day-button { background-color: #e8f1f7; color: #15232d; border-radius: 12px; min-width: 52px; min-height: 34px; padding: 0; font-size: 13px; font-weight: 700; }
.day-button label { color: #15232d; font-size: 13px; font-weight: 700; }
.day-muted { background-color: rgba(51, 136, 187, 0.22); color: #a9b6bf; }
#today-day, #selected-day, .day-today, .day-selected { background-color: #3388bb; background-image: none; color: #ffffff; border-radius: 12px; }
#today-day label, #selected-day label, .day-today label, .day-selected label { color: #ffffff; }
.footer-button { background-color: #e8f1f7; background-image: none; color: #123244; border-radius: 16px; min-height: 34px; padding: 0 18px; font-weight: 800; }
"""


class CalendarPopup(Gtk.Application):
    def __init__(self):
        super().__init__(application_id=APP_ID)
        self.today = dt.date.today()
        self.selected = self.today
        self.year = self.today.year
        self.month = self.today.month

    def do_activate(self):
        provider = Gtk.CssProvider()
        provider.load_from_data(CSS.encode())
        Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

        self.window = Gtk.ApplicationWindow(application=self)
        self.window.set_title("日历")
        self.window.set_decorated(False)
        self.window.set_resizable(False)
        self.window.set_default_size(340, 410)
        self.window.add_css_class("feng-calendar-window")
        self.window.connect("close-request", self._on_close)

        self.card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)
        self.card.add_css_class("calendar-card")
        self.window.set_child(self.card)

        title = Gtk.Label(label="日历")
        title.add_css_class("calendar-title")
        self.card.append(title)
        self.subtitle = Gtk.Label()
        self.subtitle.add_css_class("calendar-subtitle")
        self.card.append(self.subtitle)

        nav = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.card.append(nav)
        nav.append(self._nav_button("‹‹", lambda *_: self._move_year(-1)))
        nav.append(self._nav_button("‹", lambda *_: self._move_month(-1)))
        self.month_label = Gtk.Label()
        self.month_label.add_css_class("month-label")
        self.month_label.set_hexpand(True)
        nav.append(self.month_label)
        nav.append(self._nav_button("›", lambda *_: self._move_month(1)))
        nav.append(self._nav_button("››", lambda *_: self._move_year(1)))

        self.grid = Gtk.Grid(column_spacing=4, row_spacing=6, column_homogeneous=True)
        self.card.append(self.grid)

        footer = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        footer.set_halign(Gtk.Align.END)
        self.card.append(footer)
        for label, callback in (("今天", self._go_today), ("关闭", lambda *_: self.window.close())):
            button = Gtk.Button(label=label)
            button.add_css_class("footer-button")
            button.connect("clicked", callback)
            footer.append(button)

        self._render()
        self.window.present()

    def _nav_button(self, label, callback):
        button = Gtk.Button(label=label)
        button.add_css_class("calendar-nav")
        button.connect("clicked", callback)
        return button

    def _render(self):
        while child := self.grid.get_first_child():
            self.grid.remove(child)
        self.month_label.set_text(f"{self.year} 年 {self.month} 月")
        self.subtitle.set_text(self.selected.strftime("%Y-%m-%d  %A"))
        for col, label_text in enumerate(["一", "二", "三", "四", "五", "六", "日"]):
            label = Gtk.Label(label=label_text)
            label.add_css_class("weekday")
            self.grid.attach(label, col, 0, 1, 1)
        for row, week in enumerate(calendar.Calendar(firstweekday=0).monthdatescalendar(self.year, self.month), start=1):
            for col, date in enumerate(week):
                button = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
                button.add_css_class("day-button")
                button.set_halign(Gtk.Align.FILL)
                button.set_valign(Gtk.Align.FILL)
                button.set_size_request(52, 34)
                is_current_month = date.month == self.month
                label = Gtk.Label(label=str(date.day) if is_current_month else "")
                label.set_halign(Gtk.Align.CENTER)
                label.set_valign(Gtk.Align.CENTER)
                label.set_hexpand(True)
                label.set_vexpand(True)
                button.append(label)
                if not is_current_month:
                    button.add_css_class("day-muted")
                    label.add_css_class("day-muted")
                if date == self.today:
                    button.add_css_class("day-today")
                    button.set_name("today-day")
                if date == self.selected:
                    button.add_css_class("day-selected")
                    button.set_name("selected-day")
                if is_current_month:
                    click = Gtk.GestureClick.new()
                    click.connect("released", self._select_day, date)
                    button.add_controller(click)
                self.grid.attach(button, col, row, 1, 1)

    def _select_day(self, _gesture, _press_count, _x, _y, date):
        self.selected = date
        self.year = date.year
        self.month = date.month
        self._render()

    def _move_month(self, delta):
        month = self.month + delta
        year = self.year
        if month < 1:
            month, year = 12, year - 1
        elif month > 12:
            month, year = 1, year + 1
        self.year, self.month = year, month
        self.selected = dt.date(year, month, min(self.selected.day, calendar.monthrange(year, month)[1]))
        self._render()

    def _move_year(self, delta):
        self.year += delta
        self.selected = dt.date(self.year, self.month, min(self.selected.day, calendar.monthrange(self.year, self.month)[1]))
        self._render()

    def _go_today(self, *_args):
        self.selected = self.today
        self.year = self.today.year
        self.month = self.today.month
        self._render()

    def _on_close(self, *_args):
        try:
            os.unlink(PID_FILE)
        except FileNotFoundError:
            pass
        return False


def toggle_existing():
    try:
        with open(PID_FILE, "r", encoding="utf-8") as file:
            pid = int(file.read().strip())
        os.kill(pid, 0)
    except (FileNotFoundError, ProcessLookupError, ValueError):
        return False
    os.kill(pid, signal.SIGTERM)
    return True


if __name__ == "__main__":
    if toggle_existing():
        sys.exit(0)
    with open(PID_FILE, "w", encoding="utf-8") as file:
        file.write(str(os.getpid()))
    raise SystemExit(CalendarPopup().run(sys.argv))
