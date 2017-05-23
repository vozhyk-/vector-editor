import QtQml 2.2

QtObject {
    property var firstLine
    property var lineComponent

    property var lines: [firstLine]

    function addPoint(point) {
        var start

        lines.push(lineComponent.createObject(this, {
            start: lines[lines.length - 1].end,
            end: point
        }))
    }

    function getLines() {
        var lastLine = lineComponent.createObject(this, {
            start: lines[lines.length - 1].end,
            end: lines[0].start
        })
        return lines.concat([lastLine])
    }

    function paint(c) {
        var allLines = getLines()
        for (var i in allLines) {
            var line = allLines[i]
            line.paint(c)
        }
    }
}
