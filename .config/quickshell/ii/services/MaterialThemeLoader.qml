pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Automatically reloads generated material colors.
 * It is necessary to run reapplyTheme() on startup because Singletons are lazily loaded.
 */
Singleton {
    id: root
    property string filePath: Directories.generatedMaterialThemeScssPath

    function reapplyTheme() {
        themeFileView.reload()
    }

    function normalizeThemeKey(key) {
        if (/[A-Z]/.test(key)) {
            return key
        }
        return key.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase())
    }

    function applyColors(fileContent) {
        const theme = {}
        const trimmed = fileContent.trim()

        if (trimmed.startsWith("{")) {
            Object.assign(theme, JSON.parse(trimmed))
        } else {
            for (const line of fileContent.split(/\r?\n/)) {
                const match = line.match(/^\$([A-Za-z0-9_]+):\s*(.+);$/)
                if (!match) {
                    continue
                }

                const key = match[1]
                const value = match[2].trim()
                if (key === "darkmode" || key === "transparent") {
                    theme[key] = /^true$/i.test(value)
                } else {
                    theme[key] = value
                }
            }
        }

        for (const key in theme) {
            if (!theme.hasOwnProperty(key)) {
                continue
            }

            if (key === "darkmode") {
                Appearance.m3colors.darkmode = Boolean(theme[key])
                continue
            }

            if (key === "transparent") {
                Appearance.m3colors.transparent = Boolean(theme[key])
                continue
            }

            const normalizedKey = root.normalizeThemeKey(key)
            const m3Key = `m3${normalizedKey}`
            if (m3Key in Appearance.m3colors) {
                Appearance.m3colors[m3Key] = theme[key]
            }
        }

        if (theme.darkmode === undefined) {
            Appearance.m3colors.darkmode = (Appearance.m3colors.m3background.hslLightness < 0.5)
        }
    }

    Timer {
        id: delayedFileRead
        interval: Config.options?.hacks?.arbitraryRaceConditionDelay ?? 100
        repeat: false
        running: false
        onTriggered: {
            root.applyColors(themeFileView.text())
        }
    }

	FileView { 
        id: themeFileView
        path: Qt.resolvedUrl(root.filePath)
        watchChanges: true
        onFileChanged: {
            this.reload()
            delayedFileRead.start()
        }
        onLoadedChanged: {
            const fileContent = themeFileView.text()
            root.applyColors(fileContent)
        }
    }
}
