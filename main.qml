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

            Button {
                text: "DDA line"
                onClicked: canvas.mode = canvas.modes.ddaLine
            }

            Button {
                text: "Midpoint circle"
                onClicked: canvas.mode = canvas.modes.midpointCircle
            }

            Button {
                text: "Xiaolin Wu line"
                onClicked: canvas.mode = canvas.modes.xiaolinWuLine
            }

            Button {
                text: "Xiaolin Wu circle"
                onClicked: canvas.mode = canvas.modes.xiaolinWuCircle
            }

            Button {
                text: "Flood fill"
                onClicked: canvas.mode = canvas.modes.floodFill
            }

            Button {
                text: "Define a polygon"
                onClicked: canvas.mode = canvas.modes.definePolygon
            }

            Button {
                text: "Clipped X-W line"
                onClicked: canvas.mode = canvas.modes.clippedXWLine
            }

            Button {
                text: "Cube"
                onClicked: canvas.mode = canvas.modes.cube
            }

            Button {
                text: "Cylinder"
                onClicked: canvas.mode = canvas.modes.cylinder
            }

            Button {
                text: "Rotate 3D meshes"
                onClicked: canvas.mode = canvas.modes.rotate
            }

            CheckBox {
                id: animateRotation
                text: "Animate 3D mesh rotation"
            }

            Button {
                text: "Fill the last polygon"
                onClicked: canvas.fillLastPolygon()
            }

            Text {
                text: "Thickness:"
            }

            TextField {
                id: thicknessField
                placeholderText: "1"
                validator: IntValidator {}
            }
        }

        Canvas {
            id: canvas
            Layout.fillWidth: true
            Layout.fillHeight: true

            property var shapes: []
            property var lastPolygon
            property string mode

            property QtObject modes: QtObject {
                property string builtInLine: "built-in line"
                property string ddaLine: "DDA line"
                property string midpointCircle: "Midpoint circle"
                property string xiaolinWuLine: "Xiaolin Wu line"
                property string xiaolinWuCircle: "Xiaolin Wu circle"
                property string definePolygon: "Define polygon"
                property string floodFill: "Flood fill"
                property string clippedXWLine: "Clipped X-W line"
                property string fillPolygon: "Fill the last polygon"
                property string cube: "Cube"
                property string cylinder: "Cylinder"
                property string rotate: "Rotate"
            }

            property var polygonComponent
            property var xiaolinWuLineComponent
            property var floodFillComponent
            property var clippedXWLineComponent
            property var cubeComponent
            property var cylinderComponent

            Component.onCompleted: {
                polygonComponent = createComponent("Polygon.qml")
                xiaolinWuLineComponent = createComponent("XiaolinWuLine.qml")
                floodFillComponent = createComponent("FloodFill.qml")
                clippedXWLineComponent = createComponent("ClippedXWLine.qml")
                cubeComponent = createComponent("Cube.qml")
                cylinderComponent = createComponent("Cylinder.qml")
            }

            function createComponent(filename) {
                var result = Qt.createComponent(filename)

                if (result.status != Component.Ready) {
                    console.log(result.errorString())
                    return undefined
                }

                return result
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

                onWheel: {
                    canvas.shapes.forEach(function(shape) {
                        if (shape.distance == undefined)
                            return

                        shape.distance += shape.distanceChange *
                            wheel.angleDelta.y / 120
                    })

                    canvas.requestPaint()
                }
            }

            function addLine(start, end) {
                if (mode === modes.definePolygon) {
                    if (!lastPolygon) {
                        lastPolygon = polygonComponent.createObject(this, {
                            firstLine: xiaolinWuLineComponent.createObject(this, {
                                start: start,
                                end: end
                            }),
                            lineComponent: xiaolinWuLineComponent
                        })
                        shapes.push(lastPolygon)
                    } else {
                        lastPolygon.addPoint(end)
                    }

                    requestPaint()
                    return
                } else if (mode === modes.floodFill) {
                    shapes.push(floodFillComponent.createObject(this, {
                        point: end
                    }))
                    requestPaint()
                    return
                } else if (mode === modes.cube) {
                    shapes.push(cubeComponent.createObject(this, {
                        start: start,
                        end: end,
                        lineComponent: xiaolinWuLineComponent,
                        canvasSize: Qt.point(width, height)
                    }))
                    requestPaint()
                    return
                } else if (mode === modes.cylinder) {
                    shapes.push(cylinderComponent.createObject(this, {
                        start: start,
                        end: end,
                        lineComponent: xiaolinWuLineComponent,
                        canvasSize: Qt.point(width, height)
                    }))
                    requestPaint()
                    return
                } else if (mode === modes.rotate) {
                    shapes.forEach(function(shape) {
                        if (shape.adjustRotation === undefined)
                            return

                        shape.adjustRotation(start, end)
                    })
                    requestPaint()
                    return
                }

                var component

                switch (mode) {
                default:
                    return

                case modes.builtInLine:
                    component = Qt.createComponent("BuiltInLine.qml")
                    break

                case modes.ddaLine:
                    component = Qt.createComponent("DDALine.qml")
                    break

                case modes.midpointCircle:
                    component = Qt.createComponent("MidpointCircle.qml")
                    break

                case modes.xiaolinWuLine:
                    component = xiaolinWuLineComponent
                    break

                case modes.xiaolinWuCircle:
                    component = Qt.createComponent("XiaolinWuCircle.qml")
                    break

                case modes.clippedXWLine:
                    component = xiaolinWuLineComponent
                    break

                case modes.cube:
                    component = cubeComponent
                    break

                case modes.cylinder:
                    component = cylinderComponent
                    break
                }

                if (component.status != Component.Ready) {
                    console.log(component.errorString())
                    return
                }

                var line = component.createObject(this, {
                    start: start,
                    end: end,
                    thickness: parseInt(thicknessField.text)
                })

                if (mode === modes.clippedXWLine) {
                    line = clippedXWLineComponent.createObject(this, {
                        line: line,
                        lineComponent: xiaolinWuLineComponent,
                        polygon: lastPolygon
                    })
                }

                shapes.push(line)
                requestPaint()
            }

            function fillLastPolygon() {
                lastPolygon.filled = true
                requestPaint()
            }

            onPaint: {
                var c = getContext("2d")
                c.fillStyle = Qt.rgba(1, 1, 1, 1)
                c.fillRect(0, 0, width, height)
                c.fillStyle = Qt.rgba(0, 0, 0, 1)

                for (var i in shapes) {
                    var line = shapes[i]

                    line.paint(c)
                }
            }

            Timer {
                interval: 1000 / 30
                repeat: true
                running: animateRotation.checked

                onTriggered: {
                    canvas.shapes.forEach(function(shape) {
                        shape.updateAnimation &&
                            shape.updateAnimation()
                    })

                    canvas.requestPaint()
                }
            }
        }
    }
}
