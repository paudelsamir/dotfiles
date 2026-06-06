pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import org.kde.kdeconnect as KDEConnect

Singleton {
    id: root

    readonly property KDEConnect.DevicesModel pairedDevices: KDEConnect.DevicesModel {
        displayFilter: KDEConnect.DevicesModel.Paired
    }

    readonly property KDEConnect.DevicesModel allDevices: KDEConnect.DevicesModel {}

    readonly property int pairedCount: pairedDevices.count
    readonly property int allCount: allDevices.count

    readonly property int connectedCount: {
        let count = 0
        for (let i = 0; i < pairedDevices.count; i++) {
            const devId = pairedDevices.get(i).deviceId
            const dev = deviceForId(devId)
            if (dev && dev.isReachable) count++
        }
        return count
    }

    function deviceForId(deviceId) {
        return KDEConnect.DeviceDbusInterfaceFactory.create(deviceId)
    }

    function batteryForId(deviceId) {
        return KDEConnect.DeviceBatteryDbusInterfaceFactory.create(deviceId)
    }

    function clipboardForId(deviceId) {
        return KDEConnect.ClipboardDbusInterfaceFactory.create(deviceId)
    }

    function findMyPhoneForId(deviceId) {
        return KDEConnect.FindMyPhoneDbusInterfaceFactory.create(deviceId)
    }

    function sftpForId(deviceId) {
        return KDEConnect.SftpDbusInterfaceFactory.create(deviceId)
    }

    function shareForId(deviceId) {
        return KDEConnect.ShareDbusInterfaceFactory.create(deviceId)
    }

    function smsForId(deviceId) {
        return KDEConnect.SmsDbusInterfaceFactory.create(deviceId)
    }
}
