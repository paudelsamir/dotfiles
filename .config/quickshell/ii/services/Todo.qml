pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import Quickshell;
import Quickshell.Io;
import QtQuick;

/**
 * Simple to-do list manager.
 * Each item is an object with "content", "done", and "blockName" properties.
 */
Singleton {
    id: root
    property var filePath: Directories.todoPath
    property var list: []

    function addItem(item) {
        list.push(item)
        root.list = list.slice(0)
        todoFileView.setText(JSON.stringify(root.list))
    }

    function addTask(desc, blockName) {
        const item = {
            "content": desc,
            "done": false,
            "blockName": blockName || "Usual"
        }
        addItem(item)
    }

    function markDone(index) {
        if (index >= 0 && index < list.length) {
            list[index].done = true
            root.list = list.slice(0)
            todoFileView.setText(JSON.stringify(root.list))
        }
    }

    function markUnfinished(index) {
        if (index >= 0 && index < list.length) {
            list[index].done = false
            root.list = list.slice(0)
            todoFileView.setText(JSON.stringify(root.list))
        }
    }

    function deleteItem(index) {
        if (index >= 0 && index < list.length) {
            list.splice(index, 1)
            root.list = list.slice(0)
            todoFileView.setText(JSON.stringify(root.list))
        }
    }

    function refresh() {
        todoFileView.reload()
    }

    Component.onCompleted: {
        todoFileView.reload()
    }

    FileView {
        id: todoFileView
        path: Qt.resolvedUrl(root.filePath)
        onLoaded: {
            const fileContents = todoFileView.text()
            const loadedList = JSON.parse(fileContents)
            root.list = loadedList
            root.list = root.list.slice(0)
            console.log("[To Do] File loaded with " + root.list.length + " items")
        }
        onLoadFailed: (error) => {
            if (error == FileViewError.FileNotFound) {
                console.log("[To Do] File not found, creating empty list.")
                root.list = []
                todoFileView.setText("[]")
            } else {
                console.log("[To Do] Error loading file: " + error)
            }
        }
    }
}
