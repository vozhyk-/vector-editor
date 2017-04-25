import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
//import QtQuick.Dialogs 1.2

ApplicationWindow {
    title: "Vector Editor"

    ColumnLayout {
        anchors.fill: parent

        Row {
            Text {
                text: "Modes:"
            }

            Button {
                text: "Built-in line"
                onClicked: canvas.mode = canvas.modes.builtInLine
            }
        }

        Canvas {
            id: canvas
            Layout.fillWidth: true
            Layout.fillHeight: true

            property var shapes: []
            property string mode

            property QtObject modes: QtObject {
                property string builtInLine: "built-in line"
            }

            MouseArea {
                anchors.fill: parent

                property var lineStart

                onPressed: {
                    lineStart = Qt.point(mouseX, mouseY)
                }

                onReleased: {
                    canvas.addLine(lineStart, Qt.point(mouseX, mouseY))
                }
            }

            function addLine(start, end) {
                var component

                switch (mode) {
                default:
                    return

                case modes.builtInLine:
                    component = Qt.createComponent("BuiltInLine.qml")
                    if (component.status != Component.Ready) {
                        console.log("Component not ready!")
                        return
                    }
                    break
                }

                var line = component.createObject(this, {
                    start: start,
                    end: end
                })

                shapes.push(line)
                requestPaint()
            }

            onPaint: {
                var c = getContext("2d")

                for (var i in shapes) {
                    var line = shapes[i]

                    line.paint(c)
                }
            }
        }
    }
}
