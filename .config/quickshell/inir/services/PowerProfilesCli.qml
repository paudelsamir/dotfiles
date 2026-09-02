pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int profile: 1
    readonly property bool hasPerformanceProfile: true
    property bool _externalUpdate: false

    function cycleProfile(): void {
        switch (profile) {
            case 0: profile = 1; break
            case 1: profile = 2; break
            case 2: profile = 0; break
        }
    }

    function _profileToString(p: int): string {
        switch (p) {
            case 0: return "power-saver"
            case 1: return "balanced"
            case 2: return "performance"
        }
        return ""
    }

    function _stringToProfile(s: string): int {
        switch (s.trim()) {
            case "power-saver": return 0
            case "balanced": return 1
            case "performance": return 2
        }
        return -1
    }

    function _readProfile(): void {
        if (reader.running) return
        reader.running = true
    }

    function _applyProfile(): void {
        if (_externalUpdate) return
        if (writer.running) return
        writer.command = ["powerprofilesctl", "set", _profileToString(root.profile)]
        writer.running = true
    }

    Process {
        id: reader
        command: ["powerprofilesctl", "get"]
        stdout: SplitParser {
            onRead: data => {
                const val = root._stringToProfile(data)
                if (val >= 0 && val !== root.profile) {
                    root._externalUpdate = true
                    root.profile = val
                    root._externalUpdate = false
                }
            }
        }
    }

    Process {
        id: writer
        onExited: (code) => {
            if (code === 0) {
                _readProfile()
            }
        }
    }

    Timer {
        interval: 3000
        repeat: true
        running: true
        onTriggered: root._readProfile()
    }

    Component.onCompleted: Qt.callLater(_readProfile)

    onProfileChanged: _applyProfile()
}
