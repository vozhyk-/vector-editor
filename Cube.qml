import QtQml 2.2

QtObject {
    property point start
    property point end
    property double rotation: 0
    property var lineComponent

    property double size // half of the diagonal

    property var lines

    Component.onCompleted: {
        size = abs(sub(end, start))

        lines = [
            // x: -1 -> 1
            [[-1, -1, -1], [ 1, -1, -1]],
            [[-1,  1, -1], [ 1,  1, -1]],
            [[-1, -1,  1], [ 1, -1,  1]],
            [[-1,  1,  1], [ 1,  1,  1]],
            // y: -1 -> 1
            [[-1, -1, -1], [-1,  1, -1]],
            [[ 1, -1, -1], [ 1,  1, -1]],
            [[-1, -1,  1], [-1,  1,  1]],
            [[ 1, -1,  1], [ 1,  1,  1]],
            // z: -1 -> 1
            [[-1, -1, -1], [-1, -1,  1]],
            [[ 1, -1, -1], [ 1, -1,  1]],
            [[-1,  1, -1], [-1,  1,  1]],
            [[ 1,  1, -1], [ 1,  1,  1]]
        ]
    }

    function updateAnimation() {
        rotation += Math.PI / 96
    }

    function paint(c) {
        /* console.log("Painting") */
        /* console.log("Rotation: " + rotation) */
        lines.map(function(line) {
            var projectedPoints = line
                .map(toAffine)
                .map(rotate)
                .map(makeFarther)
                .map(project)
                .map(makeQtPoint)

            return lineComponent.createObject(this, {
                start: projectedPoints[0],
                end: projectedPoints[1]
            })
        }).forEach(function(drawnLine) {
            if (abs(sub(drawnLine.end, drawnLine.start)) > 10000)
                // Line too long - most likely an error
                return;

            /* console.log("Drawing line " + */
            /*             drawnLine.start + " -> " + */
            /*             drawnLine.end) */
            drawnLine.paint(c)
            /* console.log("Done") */
        })
        /* console.log("Done painting") */
    }

    function p(val) {
        console.log(JSON.stringify(val))
        return val
    }

    function rotate(affine3DPoint) {
        var c = Math.cos(rotation)
        var s = Math.sin(rotation)
        // Rotation about y
        var rotationMat = [
            [ c, 0, s, 0],
            [ 0, 1, 0, 0],
            [-s, 0, c, 0],
            [ 0, 0, 0, 1]
        ]
        return matmul(rotationMat, toMat(affine3DPoint))
    }

    function makeFarther(affine3DPoint) {
        var offset = 3
        var translationMat = [
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, offset],
            [0, 0, 0, 1],
        ]
        return matmul(translationMat, toMat(affine3DPoint))
    }

    function project(affine3DPoint) {
        var width = 2 * size / Math.sqrt(2) //800
        var height = 2 * size / Math.sqrt(2) //600

        var viewAngle = Math.PI / 2
        //console.log("viewAngle: " + viewAngle)
        //console.log("Math.tan(viewAngle / 2): " + Math.tan(viewAngle / 2))
        var dist = width / 2 / Math.tan(viewAngle / 2)
        var cX = width / 2
        var cY = height / 2
        var projection = [
            [dist, 0,    start.x, 0],
            [0,    dist, start.y, 0],
            [0,    0,    0,       1],
            [0,    0,    1,       0]
        ]
        //console.log("Projection: " + JSON.stringify(projection))
        return to2D(normalize(matmul(projection, toMat(affine3DPoint))))
    }

    // from https://stackoverflow.com/a/27205510/795068
    function matmul(m1, m2) {
        var result = [];
        for (var i = 0; i < m1.length; i++) {
            result[i] = [];
            for (var j = 0; j < m2[0].length; j++) {
                var sum = 0;
                for (var k = 0; k < m1[0].length; k++) {
                    //console.log(m1[i][k] + " * " + m2[k][j])
                    sum += m1[i][k] * m2[k][j];
                }
                //console.log("sum = " + sum)
                result[i][j] = sum;
            }
        }
        return result;
    }

    function toMat(affine3DPoint) {
        var result = []
        affine3DPoint.forEach(function(i) {
            result.push([i])
        })
        return result
    }

    function normalize(affine3DPoint) {
        return affine3DPoint.map(function(i) {
            return i / affine3DPoint[3]
        })
    }

    function toAffine(_3DPoint) {
        return _3DPoint.concat([1])
    }

    function to2D(affine3DPoint) {
        return [affine3DPoint[0], affine3DPoint[1]]
    }

    function makeQtPoint(_2DPoint) {
        return Qt.point(_2DPoint[0], _2DPoint[1])
    }

    function add(point1, point2) {
        return Qt.point(
            point1.x + point2.x,
            point1.y + point2.y)
    }

    function sub(point1, point2) {
        return add(point1, Qt.point(-point2.x, -point2.y))
    }

    function abs(point) {
        return Math.sqrt(point.x * point.x + point.y * point.y)
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
}
