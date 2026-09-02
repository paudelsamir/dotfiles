import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root
    color: "transparent"
    
    property string expression: ""
    property string result: ""
    
    function calculate() {
        if (expression.trim() === "") {
            result = ""
            return
        }
        
        try {
            // Simple calculator logic
            var expr = expression.replace(/[^0-9+\-*/().\s]/g, '')
            if (expr.trim() === "") {
                result = "Invalid expression"
                return
            }
            
            var evalResult = eval(expr)
            if (isNaN(evalResult) || !isFinite(evalResult)) {
                result = "Error"
            } else {
                result = evalResult.toString()
            }
        } catch (e) {
            result = "Error"
        }
    }
    
    function addToExpression(text) {
        expression += text
        calculate()
    }
    
    function clearExpression() {
        expression = ""
        result = ""
    }
    
    function backspace() {
        if (expression.length > 0) {
            expression = expression.slice(0, -1)
            calculate()
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        
        // Header
        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Translation.tr("Calculator")
            font.pixelSize: Appearance.font.pixelSize.large
            font.weight: Font.DemiBold
            color: Appearance.colors.colOnLayer1
        }
        
        // Display
        Rectangle {
            Layout.fillWidth: true
            height: 80
            radius: Appearance.rounding.normal
            color: Appearance.colors.colLayer0
            border.width: 1
            border.color: Appearance.colors.colLayer0Border
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                
                // Expression
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    StyledText {
                        text: expression || "0"
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.family: "monospace"
                        color: Appearance.colors.colOnLayer0
                        wrapMode: Text.Wrap
                    }
                }
                
                // Result
                StyledText {
                    Layout.fillWidth: true
                    text: result
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.family: "monospace"
                    font.weight: Font.Bold
                    color: Appearance.colors.colPrimary
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
        
        // Button Grid
        GridLayout {
            Layout.fillWidth: true
            columns: 4
            rowSpacing: 5
            columnSpacing: 5
            
            // Row 1
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: "#ef4444"
                colBackgroundHover: "#dc2626"
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "C"
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.Bold
                    color: "white"
                }
                
                onClicked: clearExpression()
            }
            
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: "#f59e0b"
                colBackgroundHover: "#d97706"
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "⌫"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: "white"
                }
                
                onClicked: backspace()
            }
            
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colSecondary
                colBackgroundHover: Qt.darker(Appearance.colors.colSecondary, 1.1)
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "("
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: "white"
                }
                
                onClicked: addToExpression("(")
            }
            
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colSecondary
                colBackgroundHover: Qt.darker(Appearance.colors.colSecondary, 1.1)
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: ")"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: "white"
                }
                
                onClicked: addToExpression(")")
            }
            
            // Row 2
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colLayer1
                colBackgroundHover: Appearance.colors.colLayer2
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "7"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer1
                }
                
                onClicked: addToExpression("7")
            }
            
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colLayer1
                colBackgroundHover: Appearance.colors.colLayer2
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "8"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer1
                }
                
                onClicked: addToExpression("8")
            }
            
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colLayer1
                colBackgroundHover: Appearance.colors.colLayer2
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "9"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer1
                }
                
                onClicked: addToExpression("9")
            }
            
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colSecondary
                colBackgroundHover: Qt.darker(Appearance.colors.colSecondary, 1.1)
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "÷"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: "white"
                }
                
                onClicked: addToExpression("/")
            }
            
            // Row 3
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colLayer1
                colBackgroundHover: Appearance.colors.colLayer2
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "4"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer1
                }
                
                onClicked: addToExpression("4")
            }
            
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colLayer1
                colBackgroundHover: Appearance.colors.colLayer2
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "5"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer1
                }
                
                onClicked: addToExpression("5")
            }
            
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colLayer1
                colBackgroundHover: Appearance.colors.colLayer2
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "6"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer1
                }
                
                onClicked: addToExpression("6")
            }
            
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colSecondary
                colBackgroundHover: Qt.darker(Appearance.colors.colSecondary, 1.1)
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "×"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: "white"
                }
                
                onClicked: addToExpression("*")
            }
            
            // Row 4
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colLayer1
                colBackgroundHover: Appearance.colors.colLayer2
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "1"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer1
                }
                
                onClicked: addToExpression("1")
            }
            
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colLayer1
                colBackgroundHover: Appearance.colors.colLayer2
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "2"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer1
                }
                
                onClicked: addToExpression("2")
            }
            
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colLayer1
                colBackgroundHover: Appearance.colors.colLayer2
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "3"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer1
                }
                
                onClicked: addToExpression("3")
            }
            
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colSecondary
                colBackgroundHover: Qt.darker(Appearance.colors.colSecondary, 1.1)
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "−"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: "white"
                }
                
                onClicked: addToExpression("-")
            }
            
            // Row 5
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                Layout.columnSpan: 2
                colBackground: Appearance.colors.colLayer1
                colBackgroundHover: Appearance.colors.colLayer2
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "0"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer1
                }
                
                onClicked: addToExpression("0")
            }
            
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colLayer1
                colBackgroundHover: Appearance.colors.colLayer2
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "."
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer1
                }
                
                onClicked: addToExpression(".")
            }
            
            RippleButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                colBackground: Appearance.colors.colSecondary
                colBackgroundHover: Qt.darker(Appearance.colors.colSecondary, 1.1)
                buttonRadius: Appearance.rounding.small
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "+"
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: "white"
                }
                
                onClicked: addToExpression("+")
            }
        }
        
        // Advanced Calculator Button
        RippleButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            colBackground: Appearance.colors.colPrimary
            colBackgroundHover: Qt.darker(Appearance.colors.colPrimary, 1.1)
            buttonRadius: Appearance.rounding.normal
            
            contentItem: RowLayout {
                anchors.centerIn: parent
                spacing: 5
                
                MaterialSymbol {
                    text: "calculate"
                    iconSize: 20
                    color: "white"
                }
                
                StyledText {
                    text: Translation.tr("Advanced Calculator")
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: "white"
                }
            }
            
            onClicked: {
                Quickshell.execDetached(["qalculate-gtk"])
            }
        }
        
        Item {
            Layout.fillHeight: true
        }
    }
}