pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import "root:"

Item {
    id: root
    implicitHeight: card.implicitHeight + Appearance.sizes.elevationMargin

    readonly property string username: Config.options?.dashboard?.github?.username ?? ""
    property var weeks: []
    property int total: -1
    property bool loading: false
    property bool error: false
    property bool _cacheLoaded: false
    property double _lastFetch: 0

    readonly property string cachePath: FileUtils.trimFileProtocol(`${Directories.state}/user/github_contrib_cache.json`)
    readonly property int refreshInterval: 3600 * 1000

    FileView {
        id: cacheFile
        path: root.cachePath
        watchChanges: false

        onLoaded: {
            try {
                const cached = JSON.parse(cacheFile.text())
                if (cached.weeks && cached.weeks.length > 0) {
                    root.weeks = cached.weeks
                }
                if (typeof cached.total === "number" && cached.total >= 0) {
                    root.total = cached.total
                }
                root._lastFetch = cached.timestamp ?? 0
            } catch (e) {
                // Corrupted cache, ignore
            }
            root._cacheLoaded = true
            if (root._lastFetch > 0 && Date.now() - root._lastFetch < root.refreshInterval + 5 * 60 * 1000) {
                Qt.callLater(() => heatmap.requestPaint())
            } else {
                Qt.callLater(() => root.fetchData())
            }
        }

        onLoadFailed: (error) => {
            root._cacheLoaded = true
            if (root.username.length > 0) Qt.callLater(() => root.fetchData())
        }
    }

    function saveCache() {
        try {
            cacheFile.setText(JSON.stringify({
                weeks: root.weeks,
                total: root.total,
                timestamp: Date.now()
            }))
        } catch (e) {
            // Non-critical, ignore write failures
        }
    }

    Timer {
        id: fetchTimer
        interval: root.refreshInterval
        running: root.username.length > 0 && Config.ready && GlobalStates.sidebarLeftOpen
        repeat: true
        onTriggered: root.fetchData()
    }

    onUsernameChanged: {
        root.weeks = []
        root.total = -1
        root._lastFetch = 0
        if (root._cacheLoaded && root.username.length > 0) {
            Qt.callLater(() => root.fetchData())
        }
    }

    function fetchData() {
        if (root.username.length === 0 || root.loading) return
        if (Date.now() - root._lastFetch < root.refreshInterval) return
        root.loading = true
        root.error = false
        fetchProcess.url = "https://github-contributions-api.jogruber.de/v4/" + encodeURIComponent(root.username) + "?y=last"
        fetchProcess.running = true
    }

    Process {
        id: fetchProcess
        property string url: ""
        command: ["/usr/bin/curl", "-s", "--max-time", "10", url]
        stdout: StdioCollector {
            onStreamFinished: {
                root.loading = false
                if (text.length === 0) {
                    root.error = true
                    return
                }
                try {
                    const data = JSON.parse(text)
                    const days = data?.contributions ?? []
                    root.total = data?.total?.lastYear ?? days.reduce((acc, d) => acc + (d.count ?? 0), 0)
                    const wk = []
                    for (let i = 0; i < days.length; i += 7) {
                        wk.push(days.slice(i, i + 7).map(d => d.level ?? 0))
                    }
                    root.weeks = wk
                    root._lastFetch = Date.now()
                    root.error = false
                    root.saveCache()
                    heatmap.requestPaint()
                } catch (e) {
                    root.error = true
                }
            }
        }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: parent.width
        implicitHeight: col.implicitHeight + 20
        radius: Appearance.zzzEverywhere ? Appearance.zzz.cardRadius : Appearance.inirEverywhere ? Appearance.inir.roundingNormal : Appearance.rounding.normal
        color: "transparent"
        Behavior on radius { enabled: Appearance.animationsEnabled; NumberAnimation { duration: Appearance.animation.elementResize.duration; easing.type: Appearance.animation.elementResize.type; easing.bezierCurve: Appearance.animation.elementResize.bezierCurve } }

        ColumnLayout {
            id: col
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                MaterialSymbol {
                    text: "code"
                    iconSize: 16
                    color: Appearance.zzzEverywhere ? Appearance.zzz.accent : Appearance.inirEverywhere ? Appearance.inir.colPrimary : Appearance.colors.colPrimary
                }
                StyledText {
                    text: Translation.tr("GitHub activity")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.Medium
                    color: Appearance.zzzEverywhere ? Appearance.zzz.ink : Appearance.inirEverywhere ? Appearance.inir.colText : Appearance.colors.colOnLayer1
                }
                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 6; height: 6; radius: 3
                    color: Appearance.zzzEverywhere ? Appearance.zzz.accent : Appearance.inirEverywhere ? Appearance.inir.colPrimary : Appearance.colors.colPrimary
                    Behavior on color { enabled: Appearance.animationsEnabled; ColorAnimation { duration: Appearance.animation.elementMoveFast.duration; easing.type: Appearance.animation.elementMoveFast.type; easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve } }
                    scale: root.loading ? 1 : 0
                    visible: scale > 0
                    Behavior on scale {
                        enabled: Appearance.animationsEnabled
                        NumberAnimation { duration: Appearance.animation.elementMoveFast.duration; easing.type: Easing.OutCubic }
                    }
                    opacity: 0.6
                    SequentialAnimation on opacity {
                        running: root.loading && GlobalStates.sidebarLeftOpen && Appearance.animationsEnabled
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.3; duration: 400 }
                        NumberAnimation { to: 0.8; duration: 400 }
                    }
                }

                RippleButton {
                    implicitWidth: 24; implicitHeight: 24
                    buttonRadius: Appearance.inirEverywhere ? Appearance.inir.roundingSmall : Appearance.rounding.full
                    colBackground: "transparent"
                    colBackgroundHover: Appearance.zzzEverywhere ? Appearance.zzz.chrome : Appearance.inirEverywhere ? Appearance.inir.colLayer1Hover : Appearance.colors.colLayer1Hover
                    onClicked: { root._lastFetch = 0; root.fetchData() }
                    contentItem: MaterialSymbol {
                        text: "refresh"; iconSize: 14
                        color: Appearance.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colOnLayer1Inactive
                    }
                    StyledToolTip { text: Translation.tr("Refresh") }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.total >= 0 ? root.total.toLocaleString(Qt.locale(), 'f', 0) : (root.loading ? "…" : "—")
                    font.pixelSize: Appearance.font.pixelSize.title
                    font.family: Appearance.font.family.numbers
                    font.weight: Font.DemiBold
                    color: Appearance.zzzEverywhere ? Appearance.zzz.accent : Appearance.inirEverywhere ? Appearance.inir.colPrimary : Appearance.colors.colPrimary
                }
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Translation.tr("contributions in the last year")
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    color: Appearance.zzzEverywhere ? Appearance.zzz.inkMuted : Appearance.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
                }
            }

            Canvas {
                id: heatmap
                Layout.fillWidth: true
                Layout.topMargin: 4
                implicitHeight: 7 * 9
                visible: hasData

                readonly property bool hasData: root.total >= 0 && root.weeks.length > 0
                readonly property color cellColor: Appearance.zzzEverywhere ? Appearance.zzz.accent : Appearance.inirEverywhere ? Appearance.inir.colPrimary : Appearance.colors.colPrimary
                readonly property color emptyColor: Appearance.zzzEverywhere ? Appearance.zzz.chrome : Appearance.inirEverywhere ? Appearance.inir.colLayer2 : Appearance.colors.colLayer2
                onCellColorChanged: requestPaint()
                onWidthChanged: requestPaint()

                onPaint: {
                    const ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    const wk = root.weeks
                    if (!wk.length) return
                    const pitch = 9
                    const cell = 7
                    const cols = Math.min(wk.length, Math.floor(width / pitch))
                    const start = wk.length - cols
                    const xOff = Math.max(0, (width - cols * pitch) / 2)
                    for (let c = 0; c < cols; c++) {
                        const week = wk[start + c]
                        for (let r = 0; r < week.length; r++) {
                            const level = week[r]
                            ctx.fillStyle = level === 0
                                ? emptyColor
                                : Qt.alpha(cellColor, 0.25 + 0.75 * Math.min(level, 4) / 4)
                            ctx.beginPath()
                            ctx.roundedRect(xOff + c * pitch, r * pitch, cell, cell, 2, 2)
                            ctx.fill()
                        }
                    }
                }
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                visible: root.username.length > 0 && heatmap.hasData
                text: "@" + root.username
                font.pixelSize: Appearance.font.pixelSize.smallest
                color: Appearance.zzzEverywhere ? Appearance.zzz.inkMuted : Appearance.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
            }
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                visible: root.error
                horizontalAlignment: Text.AlignHCenter
                text: Translation.tr("Failed to load")
                font.pixelSize: Appearance.font.pixelSize.smallest
                color: Appearance.zzzEverywhere ? Appearance.zzz.signal : Appearance.inirEverywhere ? Appearance.inir.colError : Appearance.colors.colError
            }
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                visible: root.username.length === 0
                horizontalAlignment: Text.AlignHCenter
                text: Translation.tr("Set your GitHub username in Settings")
                font.pixelSize: Appearance.font.pixelSize.smallest
                wrapMode: Text.WordWrap
                color: Appearance.zzzEverywhere ? Appearance.zzz.inkMuted : Appearance.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
            }
        }
    }
}