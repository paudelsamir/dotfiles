import qs
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton
pragma ComponentBehavior: Bound

/**
 * A nice wrapper for date and time strings.
 */
Singleton {
    property var clock: SystemClock {
        id: clock
        precision: GlobalStates.screenLocked ? SystemClock.Seconds : SystemClock.Minutes // Hack to ensure clock is correct after waking up from suspend
    }
    property string time: Qt.locale().toString(clock.date, Config.options?.time.format ?? "hh:mm")
    property string shortDate: Qt.locale().toString(clock.date, Config.options?.time.shortDateFormat ?? "dd/MM")
    property string date: Qt.locale().toString(clock.date, Config.options?.time.dateFormat ?? "dddd, dd/MM")
    property string collapsedCalendarFormat: Qt.locale().toString(clock.date, "dd MMMM yyyy")
    property string uptime: "0h, 0m"
    
    // Day progress tracking
    property int dayProgressPercentage: 0
    property int hoursLeft: 0
    property int minutesLeft: 0

    Timer {
        interval: 60000 // Update every minute
        running: true
        repeat: true
        onTriggered: {
            fileUptime.reload()
            const textUptime = fileUptime.text()
            const uptimeSeconds = Number(textUptime.split(" ")[0] ?? 0)

            // Convert seconds to days, hours, and minutes
            const days = Math.floor(uptimeSeconds / 86400)
            const hours = Math.floor((uptimeSeconds % 86400) / 3600)
            const minutes = Math.floor((uptimeSeconds % 3600) / 60)

            // Build the formatted uptime string
            let formatted = ""
            if (days > 0) formatted += `${days}d`
            if (hours > 0) formatted += `${formatted ? ", " : ""}${hours}h`
            if (minutes > 0 || !formatted) formatted += `${formatted ? ", " : ""}${minutes}m`
            uptime = formatted
            
            // Calculate day progress
            const now = new Date()
            const currentHours = now.getHours()
            const currentMinutes = now.getMinutes()
            const currentSeconds = now.getSeconds()
            
            const totalSeconds = currentHours * 3600 + currentMinutes * 60 + currentSeconds
            dayProgressPercentage = Math.round((totalSeconds / 86400) * 100)
            
            // Calculate hours left in day
            hoursLeft = 23 - currentHours
            minutesLeft = 59 - currentMinutes
            if (minutesLeft < 0) {
                hoursLeft--
                minutesLeft += 60
            }
        }
    }
    
    // Initialize on startup
    Component.onCompleted: {
        const now = new Date()
        const currentHours = now.getHours()
        const currentMinutes = now.getMinutes()
        const currentSeconds = now.getSeconds()
        
        const totalSeconds = currentHours * 3600 + currentMinutes * 60 + currentSeconds
        dayProgressPercentage = Math.round((totalSeconds / 86400) * 100)
        
        hoursLeft = 23 - currentHours
        minutesLeft = 59 - currentMinutes
        if (minutesLeft < 0) {
            hoursLeft--
            minutesLeft += 60
        }
    }

    FileView {
        id: fileUptime
        
        path: "/proc/uptime"
    }

}
