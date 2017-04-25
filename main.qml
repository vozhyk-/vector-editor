import QtQuick 2.7
import QtQuick.Controls 1.4
//import QtQuick.Layouts 1.3
//import QtQuick.Dialogs 1.2

ApplicationWindow {
    title: "Vector Editor"

    Canvas {
        anchors.fill: parent

        property variant color: Qt.rgba(1, 0, 0, 1)

        MouseArea {
            anchors.fill: parent

            onClicked: {
                parent.color = Qt.rgba(0, 1, 0, 1)
            }
        }

        onPaint: {
            var c = getContext("2d")
            c.fillStyle = color
            c.fillRect(0, 0, width, height)
        }

        onColorChanged: {
            requestPaint()
        }
    }
}
