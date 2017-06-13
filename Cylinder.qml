import QtQml 2.2

LineMesh {
    property double height // half of the height
    property double radius

    property int nPrismSides: 17

    Component.onCompleted: {
        height = 1
        radius = 1

        lines = computeLines()
    }

    function computeLines() {
        var triangles = computeTriangles()

        var result = []
        triangles.forEach(function(triangle) {
            result.push([triangle[0], triangle[1]])
            result.push([triangle[1], triangle[2]])
            result.push([triangle[2], triangle[0]])
        })
        return result
    }

    function computeTriangles() {
        var lowerBaseVertices = computeBaseVertices(-height)
        var upperBaseVertices = computeBaseVertices(height)
        
        var result = computeBase(lowerBaseVertices)
            .concat(computeSides(lowerBaseVertices, upperBaseVertices))
            .concat(computeBase(upperBaseVertices))
        
        return result
    }

    function computeBase(baseVertices) {
        var result = []
        for (var i = 0; i < nPrismSides; i++) {
            result.push( /* triangle */ [
                baseVertices[0],
                baseVertices[(i + 1) % nPrismSides + 1],
                baseVertices[i + 1]
            ])
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
