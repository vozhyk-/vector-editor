import QtQuick 2.7
import QtQuick.Controls 1.4
//import QtQuick.Layouts 1.3
//import QtQuick.Dialogs 1.2

ApplicationWindow {
    title: "Vector Editor"

    Canvas {
        id: canvas

        anchors.fill: parent

        property var shapes: []

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
            shapes.push({
                start: start,
                end: end
            })

            requestPaint()
        }

        onPaint: {
            var c = getContext("2d")
            c.fillStyle = "red"

            for (var i in shapes) {
                var line = shapes[i]

                c.beginPath()
                c.moveTo(line.start.x, line.start.y)
                c.lineTo(line.end.x, line.end.y)
                c.stroke()
            }
        }
    }
}
