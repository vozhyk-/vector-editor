import QtQml 2.2

QtObject {
    property var line
    property var lineComponent
    property Polygon polygon

    property var clippedLine

    Component.onCompleted: {
        clippedLine = cyrusBeck(line)
    }

    function cyrusBeck(line) {
        if (line.start == line.end) { // does this even work?
            // TODO line degenerated so clip as point
            return null
        }

        var D = sub(line.end, line.start)

        var tE = 0, tL = 1
        var clippingLines = polygon.getLines()
        for (var i in clippingLines) {
            var clippingLine = clippingLines[i]

            var Ni = outsideNormal(clippingLine)
            var PEi = clippingLine.start // an arbitrary point on clippingLine

            var det = dotProduct(Ni, D)
            if (det != 0) { //ignore parallel lines
                var t = dotProduct(Ni, sub(line.start, PEi)) / -det
                var PE = det < 0
                if (PE)
                    tE = max(tE, t)
                else //PL
                    tL = min(tL, t)
            }
        }
        if (tE > tL) {
            return null
        } else {
            var P = function(t) {
                return add(line.start,
                    constProduct(t, sub(line.end, line.start)))
            }
            return lineComponent.createObject(this, {
                start: P(tE),
                end: P(tL)
            })
        }
    }

    function min(a, b) {
        return a < b ? a : b
    }

    function max(a, b) {
        return a > b ? a : b
    }

    function add(point1, point2) {
        return Qt.point(
            point1.x + point2.x,
            point1.y + point2.y)
    }

    function sub(point1, point2) {
        return add(point1, Qt.point(-point2.x, -point2.y))
    }

    function dotProduct(point1, point2) {
        return point1.x * point2.x +
            point1.y * point2.y
    }

    function constProduct(c, point) {
        return Qt.point(
            c * point.x,
            c * point.y)
    }

    function outsideNormal(line) {
        //var normalStart = line.start
        // Assume the lines are in counter-clockwise order
        return Qt.point(
            /*normalStart.x +*/ -(line.end.y - line.start.y),
            /*normalStart.y +*/ line.end.x - line.start.x)
    }
    
    function paint(c) {
        if (clippedLine)
            clippedLine.paint(c)
    }
}
