import QtQml 2.2

LineMesh {
    property double height // half of the height
    property double radius

    property var texture

    property int nPrismSides: 17

    Component.onCompleted: {
        height = 1
        radius = 1
    }

    function paint(c) {
        var triangles = computeTriangles()
        var projectedTriangles = triangles
            .map(projectTriangle)
            .filter(shouldBeDrawn)

        trianglesToLines(projectedTriangles).forEach(function(projectedPoints) {
            drawProjectedLine(c, makeDrawnLine(projectedPoints))
        })

        drawTexture(c, projectedTriangles)
    }

    function drawTexture(c, projectedTriangles) {
        // Draw vertices with colors from the texture
        projectedTriangles.forEach(function(triangle) {
            triangle.forEach(function(vertex) {
                putPixel(c, vertex.point,
                         getTextureColor(vertex.textureLocation));
            })
        })
        // TODO Draw the other pixels
    }

    function getTextureColor(textureLocation) {
        return colorFromImageData(texture, textureLocation)
    }

    function colorFromImageData(data, point) {
        var pixelData = data.data
        var max = 255

        // TODO offset by point
        var result = Qt.rgba(
            data[0] / max,
            data[1] / max,
            data[2] / max,
            data[3] / max)
        //console.log(result)
        return result
    }

    function putPixel(c, point, color) {
    }

    function trianglesToLines(projectedTriangles) {
        var result = []
        projectedTriangles.forEach(function(projectedTriangle) {
            result.push([projectedTriangle[0].point,
                         projectedTriangle[1].point])
            result.push([projectedTriangle[1].point,
                         projectedTriangle[2].point])
            result.push([projectedTriangle[2].point,
                         projectedTriangle[0].point])
        })
        return result
    }

    function projectTriangle(triangle) {
        return triangle.map(function(vertex) {
            return {
                point: transformAndProjectPoint(vertex.point),
                textureLocation: vertex.textureLocation
            }
        })
    }

    function shouldBeDrawn(projectedTriangle) {
        var prod = crossProduct([
            projectedTriangle[1].point.x - projectedTriangle[0].point.x,
            projectedTriangle[1].point.y - projectedTriangle[0].point.y,
            0
        ], [
            projectedTriangle[2].point.x - projectedTriangle[0].point.x,
            projectedTriangle[2].point.y - projectedTriangle[0].point.y,
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
        result.push({
            point: center,
            textureLocation: [1/4, 1/4]
        })

        for (var i = 1; i <= nPrismSides; i++) {
            var angle = 2 * Math.PI / nPrismSides * (i - 1)
            result.push({
                point: [
                    radius * Math.cos(angle),
                    y,
                    radius * Math.sin(angle)
                ],
                textureLocation: [1/5, 1/5] // TODO
                // TODO make it different for the base and sides
            })
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
