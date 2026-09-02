pragma Singleton

import QtQuick
import Quickshell

/**
 * Shared state for monthly goals
 */
QtObject {
    id: root
    
    property var goals: [
        {"id": 1, "title": "Complete 2026 Transformation", "progress": 30},
        {"id": 2, "title": "Master DSA Concepts", "progress": 45},
        {"id": 3, "title": "Daily Consistency", "progress": 60}
    ]
    
    property int nextGoalId: 4
    
    function addGoal(title, initialProgress) {
        let newGoal = {"id": nextGoalId, "title": title, "progress": initialProgress || 0}
        goals.push(newGoal)
        goals = goals  // Trigger property change signal
        nextGoalId++
    }
    
    function updateGoalProgress(id, progress) {
        for (let i = 0; i < goals.length; i++) {
            if (goals[i].id === id) {
                goals[i].progress = Math.min(100, Math.max(0, progress))
                goals = goals  // Trigger property change signal
                break
            }
        }
    }
    
    function updateGoalTitle(id, title) {
        for (let i = 0; i < goals.length; i++) {
            if (goals[i].id === id) {
                goals[i].title = title
                goals = goals  // Trigger property change signal
                break
            }
        }
    }
    
    function deleteGoal(id) {
        goals = goals.filter(g => g.id !== id)
    }
}
