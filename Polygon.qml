import QtQml 2.2

QtObject {
    property var firstLine
    property var lineComponent
    property bool filled: false

    property var lines: [firstLine]
    property var et: []

    function addPoint(point) {
        var newLine = lineComponent.createObject(this, {
            start: lines[lines.length - 1].end,
            end: point
        })

        lines.push(newLine)
    }

    function getLines() {
        var lastLine = lineComponent.createObject(this, {
            start: lines[lines.length - 1].end,
            end: lines[0].start
        })
        return lines.concat([lastLine])
    }

    function paint(c) {
        console.log("Drawing the polygon")
        var allLines = getLines()
        for (var i in allLines) {
            var line = allLines[i]
            line.paint(c)
        }

        if (filled)
            fill(c)
    }

    function fill(c) {
        c.fillStyle = Qt.rgba(0, 1, 0, 1)

        buildET()

        console.log("Filling")
        var y = firstYInET()
        console.log("First Y in ET: " + y)
        console.log("y: " + y)
        console.log("et[first y]: " + et[y])
        var AET = []
        while (!isAETEmpty(AET) || !isETEmpty()) {
            console.log("y: " + y)
            console.log("et[y]: " + JSON.stringify(et[y]))
            AET = appendToAET(et[y], AET)
            et[y] = undefined
            AET = sortAET(AET)
            // Done before fillScanline()
            // to prevent having an odd number of active edges
            AET = removeExpiredEdges(y, AET)
            fillScanline(y, AET, c)
            ++y
            for (var i in AET) {
                var edge = AET[i]
                edge.minX += 1 * edge.invM
            }
        }
    }

    function firstYInET() {
        for (var i in et)
            if (et[i])
                return i
    }

    function appendToAET(ETBucket, AET) {
        // Don't use a linked list yet.
        /*
        var lastETElem = ETBucket
        while (lastETElem.next) {
            lastETElem = lastETElem.next
        }

        lastETElem.next = AET
        return ETBucket
        */

        return (ETBucket || []).concat(AET)
    }

    function sortAET(AET) {
        return AET.sort(function(a, b) {
            return a.minX - b.minX
        })
    }

    function removeExpiredEdges(y, AET) {
        return AET.filter(function(elem) {
            var result = elem.maxY != y
            if (!result) {
                console.log("Removing expired edge: " +
                            JSON.stringify(elem))
            } else {
                console.log("Edge not expired: maxY: " + elem.maxY +
                            ", y: " + y)
            }
            return result
        })
    }

    function isAETEmpty(AET) {
        return AET.length == 0
    }

    function isETEmpty() {
        for (var i in et)
            if (et[i])
                return false

        return true
    }

    function fillScanline(y, AET, c) {
        console.log("fillScanline: y: " + y)
        for (var i = 0; i < AET.length; i += 2) {
            var left = AET[i]
            var right = AET[i + 1]
            console.log("fillScanline: left: " + JSON.stringify(left) +
                        ", right: " + JSON.stringify(right))
            for (var x = left.minX; x <= right.minX; x++) {
                putPixel(Qt.point(x, y), c)
            }
        }
    }

    function buildET() {
        var allLines = getLines()
        for (var i in allLines) {
            var line = allLines[i]
            addToET(line)
        }
    }

    function addToET(line) {
        console.log("Adding line to ET: " + line.start + " -> " + line.end)
        if (line.start.y > line.end.y) {
            line = lineComponent.createObject(this, {
                start: copy(line.end),
                end: copy(line.start)
            })
        }
        // minY = line.start.y

        // Don't use a linked list yet.
        // Use an array to use its built-in functions.
        /*
        et[line.start.y] = {
            maxY: line.end.y,
            minX: line.start.x, // actually pointOf(minY).x
            invM: (line.end.x - line.start.x) / (line.end.y - line.start.y),
            next: et[line.start.y]
        }
        */

        if (!et[line.start.y])
            et[line.start.y] = []

        var elem = {
            maxY: line.end.y,
            minX: line.start.x, // actually pointOf(minY).x
            invM: (line.end.x - line.start.x) / (line.end.y - line.start.y),
        }
        console.log("Adding element to ET: " + JSON.stringify(elem))
        et[line.start.y].push(elem)
    }

    function copy(point) {
        return Qt.point(point.x, point.y)
    }

    function putPixel(point, c) {
        c.fillRect(point.x, point.y, 1, 1) // TODO optimize
    }
}
