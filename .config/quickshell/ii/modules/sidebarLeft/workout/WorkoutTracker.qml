import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.settings

Item {
    id: root
    anchors.fill: parent
    
    property int currentMonth: new Date().getMonth()
    property int currentYear: new Date().getFullYear()
    property int currentDay: new Date().getDate()
    
    property var workoutDays: ({})
    
    property int selectedDay: -1
    property string editingNotes: ""
    
    // Use Qt Settings for persistent storage
    Settings {
        id: workoutSettings
        category: "WorkoutTracker"
        property string workoutData: "{}"
    }
    
    Component.onCompleted: {
        loadData();
    }
    
    function loadData() {
        try {
            const stored = workoutSettings.workoutData;
            console.log("Loading data: " + stored.substring(0, 50) + "...");
            
            if (stored && stored !== "{}") {
                root.workoutDays = JSON.parse(stored);
                console.log("Loaded " + Object.keys(root.workoutDays).length + " workout entries");
            } else {
                console.log("No saved data, using defaults");
                initializeDefaultData();
            }
        } catch (e) {
            console.log("Load error: " + e);
            initializeDefaultData();
        }
    }
    
    function initializeDefaultData() {
        const data = {};
        root.workoutDays = data;
        saveData();
    }
    
    function saveData() {
        try {
            const dataStr = JSON.stringify(root.workoutDays);
            workoutSettings.workoutData = dataStr;
            console.log("✓ Saved " + Object.keys(root.workoutDays).length + " workout entries");
        } catch (e) {
            console.log("Save error: " + e.toString());
        }
    }
    
    function getDaysInMonth(month, year) {
        return new Date(year, month + 1, 0).getDate();
    }
    
    function getFirstDayOfMonth(month, year) {
        return new Date(year, month, 1).getDay();
    }
    
    function toggleDay(day) {
        const dayStr = day.toString();
        const monthStr = root.currentMonth.toString();
        const yearStr = root.currentYear.toString();
        const key = yearStr + "-" + monthStr + "-" + dayStr;
        
        if (root.workoutDays[key]) {
            root.workoutDays[key].completed = !root.workoutDays[key].completed;
        } else {
            root.workoutDays[key] = { completed: true, notes: "" };
        }
        
        // Trigger property change notification
        root.workoutDays = Object.assign({}, root.workoutDays);
        
        // Save after property change
        root.saveData();
    }
    
    function getCompletedCount() {
        let count = 0;
        for (let key in root.workoutDays) {
            if (root.workoutDays[key].completed) count++;
        }
        return count;
    }
    
    function getMonthName(month) {
        const months = ["January", "February", "March", "April", "May", "June", 
                       "July", "August", "September", "October", "November", "December"];
        return months[month];
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        
        // Month Navigation
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            RippleButton {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                buttonRadius: 4
                colBackground: Appearance.colors.colLayer2
                
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "chevron_left"
                    iconSize: 14
                    color: Appearance.colors.colOnLayer2
                }
                
                onClicked: {
                    root.currentMonth = (root.currentMonth - 1 + 12) % 12;
                    if (root.currentMonth === 11) root.currentYear--;
                }
            }
            
            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer1
                text: root.getMonthName(root.currentMonth) + " " + root.currentYear
            }
            
            RippleButton {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                buttonRadius: 4
                colBackground: Appearance.colors.colLayer2
                
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "chevron_right"
                    iconSize: 14
                    color: Appearance.colors.colOnLayer2
                }
                
                onClicked: {
                    root.currentMonth = (root.currentMonth + 1) % 12;
                    if (root.currentMonth === 0) root.currentYear++;
                }
            }
        }
        
        // Calendar Grid
        GridLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            columns: 7
            rowSpacing: 3
            columnSpacing: 3
            
            // Day headers
            Repeater {
                model: ["S", "M", "T", "W", "T", "F", "S"]
                
                StyledText {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 18
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    color: Appearance.colors.colOnLayer2
                    text: modelData
                }
            }
            
            // Empty cells
            Repeater {
                model: root.getFirstDayOfMonth(root.currentMonth, root.currentYear)
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "transparent"
                }
            }
            
            // Days of month
            Repeater {
                model: root.getDaysInMonth(root.currentMonth, root.currentYear)
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: {
                        const dayStr = (index + 1).toString();
                        const monthStr = root.currentMonth.toString();
                        const yearStr = root.currentYear.toString();
                        const key = yearStr + "-" + monthStr + "-" + dayStr;
                        const data = root.workoutDays[key];
                        if (data && data.completed) {
                            return "#d34d3d"; // Slight red
                        }
                        return Appearance.colors.colLayer2;
                    }
                    radius: 4
                    border.width: 1
                    border.color: Appearance.colors.colLayer0Border
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 1
                        
                        StyledText {
                            Layout.fillWidth: true
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.colOnLayer2
                            text: (index + 1).toString()
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.LeftButton) {
                                root.toggleDay(index + 1);
                            } else if (mouse.button === Qt.RightButton) {
                                root.selectedDay = index + 1;
                                const dayStr = (index + 1).toString();
                                const monthStr = root.currentMonth.toString();
                                const yearStr = root.currentYear.toString();
                                const key = yearStr + "-" + monthStr + "-" + dayStr;
                                root.editingNotes = root.workoutDays[key] ? root.workoutDays[key].notes : "";
                                noteDialog.open();
                            }
                        }
                    }
                }
            }
        }
        
        // Stats
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: Appearance.colors.colLayer2
            radius: 4
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 1
                
                StyledText {
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    color: Appearance.colors.colOnLayer2
                    text: "Completed"
                }
                
                StyledText {
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colPrimary
                    text: root.getCompletedCount() + "/" + root.getDaysInMonth(root.currentMonth, root.currentYear)
                }
            }
        }
        
        Item { Layout.fillHeight: true }
    }
    
    // Note Editor Dialog
    Rectangle {
        id: noteDialog
        visible: false
        anchors.centerIn: parent
        width: 280
        height: 200
        color: Appearance.colors.colLayer0
        radius: 4
        border.width: 1
        border.color: Appearance.colors.colLayer0Border
        z: 1000
        
        function open() {
            noteDialog.visible = true;
        }
        
        function close() {
            noteDialog.visible = false;
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10
            
            StyledText {
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer1
                text: "Day " + root.selectedDay + " Workout Info"
            }
            
            TextArea {
                Layout.fillWidth: true
                Layout.fillHeight: true
                placeholderText: "Muscle group, notes, duration..."
                text: root.editingNotes
                onTextChanged: root.editingNotes = text
                color: Appearance.colors.colOnLayer1
                background: Rectangle {
                    color: Appearance.colors.colLayer1
                    radius: 4
                    border.width: 1
                    border.color: Appearance.colors.colLayer0Border
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                RippleButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    buttonRadius: 4
                    colBackground: Appearance.colors.colLayer2
                    
                    contentItem: StyledText {
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colOnLayer2
                    }
                    
                    onClicked: noteDialog.close()
                }
                
                RippleButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    buttonRadius: 4
                    colBackground: Appearance.colors.colPrimary
                    
                    contentItem: StyledText {
                        anchors.centerIn: parent
                        text: "Save"
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colOnPrimary
                    }
                    
                    onClicked: {
                        const dayStr = root.selectedDay.toString();
                        const monthStr = root.currentMonth.toString();
                        const yearStr = root.currentYear.toString();
                        const key = yearStr + "-" + monthStr + "-" + dayStr;
                        
                        if (root.workoutDays[key]) {
                            root.workoutDays[key].notes = root.editingNotes;
                        } else {
                            root.workoutDays[key] = { completed: true, notes: root.editingNotes };
                        }
                        
                        // Trigger property change
                        root.workoutDays = Object.assign({}, root.workoutDays);
                        
                        // Save
                        root.saveData();
                        noteDialog.close();
                    }
                }
            }
        }
    }
}
