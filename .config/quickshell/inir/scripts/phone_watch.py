#!/usr/bin/env python3
import dbus, json, sys, signal, os
import dbus.mainloop.glib
from gi.repository import GLib

BUS_NAME = "org.kde.kdeconnect"

def notify(title: str, body: str, urgency: str = "normal") -> None:
    os.system(f'notify-send -a "PhoneConnect" -u {urgency} "{title}" "{body}"')

def get_device_ids(bus) -> list[str]:
    import re
    obj = bus.get_object(BUS_NAME, "/modules/kdeconnect/devices")
    xml = dbus.Interface(obj, "org.freedesktop.DBus.Introspectable").Introspect()
    return re.findall(r'node name="([^"]+)"', xml)

def get_device_name(bus, device_id: str) -> str:
    path = f"/modules/kdeconnect/devices/{device_id}"
    obj = bus.get_object(BUS_NAME, path)
    dev = dbus.Interface(obj, "org.kde.kdeconnect.device")
    try:
        prop = dev.get_dbus_method("org.freedesktop.DBus.Properties", "Get")
        return str(prop("org.kde.kdeconnect.device", "name"))
    except Exception:
        return device_id

def main():
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    loop = GLib.MainLoop()
    bus = dbus.SessionBus()

    def on_share_received(url: str, device_id: str = None, dev_name: str = "Phone"):
        fname = url.split("/")[-1] if "/" in url else url
        notify(f"File received from {dev_name}", f"{fname}", "normal")

    def on_notification_posted(public_id: str, device_id: str = None, dev_name: str = "Phone"):
        path = f"/modules/kdeconnect/devices/{device_id}"
        obj = bus.get_object(BUS_NAME, path)
        notif = dbus.Interface(obj, "org.kde.kdeconnect.device.notifications")
        try:
            active = notif.activeNotifications()
            import json
            for n in active:
                if str(n.get("id", "")) == public_id:
                    app = n.get("appName", "Notification")
                    text = n.get("text", "")
                    title = n.get("title", "")
                    if title:
                        notify(f"[{app}] {title}", text[:200], "normal")
                    break
        except Exception:
            pass

    device_ids = get_device_ids(bus)
    for did in device_ids:
        dev_name = get_device_name(bus, did)
        path = f"/modules/kdeconnect/devices/{did}"

        bus.add_signal_receiver(
            lambda url, _did=did, _name=dev_name: on_share_received(url, _did, _name),
            signal_name="shareReceived",
            dbus_interface="org.kde.kdeconnect.device.share",
            bus_name=BUS_NAME, path=f"{path}/share",
        )

        def make_notif_handler(_did, _name):
            return lambda pid: on_notification_posted(pid, _did, _name)

        bus.add_signal_receiver(
            make_notif_handler(did, dev_name),
            signal_name="notificationPosted",
            dbus_interface="org.kde.kdeconnect.device.notifications",
            bus_name=BUS_NAME, path=f"{path}/notifications",
        )

    try:
        loop.run()
    except KeyboardInterrupt:
        loop.quit()

if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    main()
