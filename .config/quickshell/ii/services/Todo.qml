pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import Quickshell;
import Quickshell.Io;
import QtQuick;

/**
 * Simple to-do list manager.
 * Includes daily recurring tasks that reset each day.
 * Each item is an object with "content" and "done" properties.
 */
Singleton {
    id: root
    property var filePath: Directories.todoPath
    property var list: []
    property string lastResetDate: ""
    property var stateFilePath: Directories.state + "/user/todo_state.json"
    
    // Daily recurring tasks by time block
    property var dailyTasks: [
        {"content": "Leetcode (1 hr)", "blockName": "6-11 AM"},
        {"content": "AI/ML (2 hr)", "blockName": "6-11 AM"},
        {"content": "Work on Project (2 hr)", "blockName": "6-11 AM"},
        {"content": "Lunch", "blockName": "11 AM-12 PM"},
        {"content": "Share Market (1 hr)", "blockName": "12-3 PM"},
        {"content": "Apply Jobs/Prepare Interviews (2 hr)", "blockName": "12-3 PM"},
        {"content": "Gym", "blockName": "3-5:30 PM"},
        {"content": "Dinner", "blockName": "5:30-7 PM"},
        {"content": "Read Books (30 min)", "blockName": "7-10 PM"},
        {"content": "Journaling (1 hr)", "blockName": "7-10 PM"},
        {"content": "Chess/Guitar (1.5 hr)", "blockName": "7-10 PM"},
        {"content": "Meditate and Sleep (10 min)", "blockName": "7-10 PM"}
    ]
    
    function addItem(item) {
        list.push(item)
        // Reassign to trigger onListChanged
        root.list = list.slice(0)
        todoFileView.setText(JSON.stringify(root.list))
    }

    function addTask(desc) {
        const item = {
            "content": desc,
            "done": false,
            "blockName": "Other"
        }
        addItem(item)
    }

    function markDone(index) {
        if (index >= 0 && index < list.length) {
            list[index].done = true
            // Reassign to trigger onListChanged
            root.list = list.slice(0)
            todoFileView.setText(JSON.stringify(root.list))
        }
    }

    function markUnfinished(index) {
        if (index >= 0 && index < list.length) {
            list[index].done = false
            // Reassign to trigger onListChanged
            root.list = list.slice(0)
            todoFileView.setText(JSON.stringify(root.list))
        }
    }

    function deleteItem(index) {
        if (index >= 0 && index < list.length) {
            list.splice(index, 1)
            // Reassign to trigger onListChanged
            root.list = list.slice(0)
            todoFileView.setText(JSON.stringify(root.list))
        }
    }
    
    function initializeDailyTasks() {
        const today = new Date().toISOString().split('T')[0]
        
        // Reset if it's a new day
        if (lastResetDate !== today) {
            lastResetDate = today
            
            // Save the reset date
            saveState()
            
            // Remove old daily tasks from list
            root.list = root.list.filter(item => !item.isDaily)
            
            // Add today's daily tasks (in reverse order so they appear in correct order)
            for (let i = dailyTasks.length - 1; i >= 0; i--) {
                root.list.unshift({
                    "content": dailyTasks[i].content,
                    "done": false,
                    "isDaily": true,
                    "blockName": dailyTasks[i].blockName
                })
            }
            
            root.list = root.list.slice(0)
            todoFileView.setText(JSON.stringify(root.list))
            console.log("[To Do] Daily tasks initialized for " + today)
        }
    }
    
    function saveState() {
        const state = {
            "lastResetDate": lastResetDate
        }
        stateFileView.setText(JSON.stringify(state))
    }
    
    function loadState() {
        try {
            const stateContents = stateFileView.text()
            const state = JSON.parse(stateContents)
            lastResetDate = state.lastResetDate || ""
            console.log("[To Do] State loaded, last reset: " + lastResetDate)
        } catch(e) {
            console.log("[To Do] Could not load state: " + e)
            lastResetDate = ""
        }
    }

    function refresh() {
        todoFileView.reload()
    }

    Component.onCompleted: {
        // Load state first, then todos
        stateFileView.reload()
    }
    
    FileView {
        id: stateFileView
        path: Qt.resolvedUrl(root.stateFilePath)
        onLoaded: {
            loadState()
            // Now load the todo file after state is loaded
            todoFileView.reload()
        }
        onLoadFailed: (error) => {
            if(error == FileViewError.FileNotFound) {
                console.log("[To Do] State file not found, will create on first reset.")
                lastResetDate = ""
            }
            // Still load todos even if state file doesn't exist
            todoFileView.reload()
        }
    }

    FileView {
        id: todoFileView
        path: Qt.resolvedUrl(root.filePath)
        onLoaded: {
            const fileContents = todoFileView.text()
            const loadedList = JSON.parse(fileContents)
            
            // Check if we need to reset for a new day
            const today = new Date().toISOString().split('T')[0]
            
            // Only reset if it's actually a new day AND we have a previous reset date
            // If lastResetDate is empty, it means first run, so check if list already has tasks
            if (lastResetDate !== "" && lastResetDate !== today) {
                console.log("[To Do] New day detected (" + today + "), resetting daily tasks")
                root.list = loadedList
                root.initializeDailyTasks()
            } else {
                // Same day or first run with existing tasks - keep everything as-is
                console.log("[To Do] Keeping existing tasks as-is")
                root.list = loadedList
                root.list = root.list.slice(0)  // Trigger change signal
                
                // Set lastResetDate to today if it's empty (first run)
                if (lastResetDate === "") {
                    lastResetDate = today
                    saveState()
                }
            }
            console.log("[To Do] File loaded with " + root.list.length + " items")
        }
        onLoadFailed: (error) => {
            if(error == FileViewError.FileNotFound) {
                console.log("[To Do] File not found, creating new file with daily tasks.")
                root.list = []
                const today = new Date().toISOString().split('T')[0]
                lastResetDate = today
                saveState()
                root.initializeDailyTasks()
            } else {
                console.log("[To Do] Error loading file: " + error)
            }
        }
    }
    
    // Timer to reset at midnight
    Timer {
        interval: 60000 // Check every minute
        running: true
        repeat: true
        onTriggered: {
            root.initializeDailyTasks()
        }
    }
}
