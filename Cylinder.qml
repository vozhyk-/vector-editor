import QtQml 2.2

LineMesh {
    property double height // half of the height
    property double radius

    property int nPrismSides: 17

    Component.onCompleted: {
        height = 1
        radius = 1
    }

    function paint(c) {
        computeProjectedLines().forEach(function(projectedPoints) {
            drawProjectedLine(c, makeDrawnLine(projectedPoints))
        })
    }

    function computeProjectedLines() {
        var triangles = computeTriangles()

        var result = []
        triangles.forEach(function(triangle) {
            var projected = triangle.map(transformAndProjectPoint)

            if (!shouldBeDrawn(projected))
                return;

            result.push([projected[0], projected[1]])
            result.push([projected[1], projected[2]])
            result.push([projected[2], projected[0]])
        })
        return result
    }

    function shouldBeDrawn(projected) {
        var prod = crossProduct([
            projected[1].x - projected[0].x,
            projected[1].y - projected[0].y,
            0
        ], [
            projected[2].x - projected[0].x,
            projected[2].y - projected[0].y,
            0
        ])

        return prod[2] > 0
    }

    function crossProduct(/* 3D point */ a, /* 3D point */ b) {
        return [
            a[1] * b[2] - a[2] * b[1],
            a[0] * b[2] - a[2] * b[0],
            a[0] * b[1] - a[1] * b[0]
        ]
    }

    function computeTriangles() {
        // "lower" is actually above "upper"
        var lowerBaseVertices = computeBaseVertices(-height)
        var upperBaseVertices = computeBaseVertices(height)
        
        var result = computeBase(lowerBaseVertices, false)
            .concat(computeSides(lowerBaseVertices, upperBaseVertices))
            .concat(computeBase(upperBaseVertices, true))
        
        return result
    }

    function computeBase(baseVertices, reverse) {
        var result = []
        for (var i = 0; i < nPrismSides; i++) {
            var a = baseVertices[0]
            var b = baseVertices[(i + 1) % nPrismSides + 1]
            var c = baseVertices[i + 1]

            result.push( /* triangle */
                !reverse ? [a, b, c] : [a, c, b])
        }
        return result
    }

    function computeBaseVertices(y) {
        var result = []

        var center = [0, y, 0]
        result.push(center)

        for (var i = 1; i <= nPrismSides; i++) {
            var angle = 2 * Math.PI / nPrismSides * (i - 1)
            result.push( /* 3D point */ [
                radius * Math.cos(angle),
                y,
                radius * Math.sin(angle)
            ])
        }

        return result
    }

    function computeSides(lowerBaseVertices, upperBaseVertices) {
        var n = nPrismSides

        var sideVertices = []

        for (var i = 1; i <= n; i++) {
            sideVertices.push(lowerBaseVertices[i])
        }
        for (var i = 1; i <= n; i++) {
            sideVertices.push(upperBaseVertices[i])
        }

        var result = []

        for (var i = 0; i < n - 1; i++) {
            result.push([
                sideVertices[i],
                sideVertices[i + 1],
                sideVertices[i + n]
            ])
        }

        result.push([
            sideVertices[n - 1],
            sideVertices[0],
            sideVertices[2 * n - 1]
        ])

        for (var i = n; i < 2 * n - 1; i++) {
            result.push([
                sideVertices[i],
                sideVertices[i + 1 - n],
                sideVertices[i + 1]
            ])
        }

        result.push([
            sideVertices[2 * n - 1],
            sideVertices[0],
            sideVertices[n]
        ])

        return result
    }
}
