import QtQml 2.2

QtObject {
    property point start
    property point end
    property int thickness

    function paint(c) {
        var fakeStart = copy(start)
        var fakeEnd = copy(end)
        var fakePut = function(fakePoint) {
            putPixel(fakePoint, c)
        }

        var dy = fakeEnd.y - fakeStart.y
        var dx = fakeEnd.x - fakeStart.x

        if (Math.abs(dx) < Math.abs(dy)) {
            fakeStart = rotate(start)
            fakeEnd = rotate(end)
            fakePut = function(fakePoint) {
                putPixel(rotate(fakePoint), c)
            }
        }

        if (fakeEnd.x < fakeStart.x) {
            var temp = copy(fakeStart)
            fakeStart = fakeEnd
            fakeEnd = temp
        }


        dy = fakeEnd.y - fakeStart.y
        dx = fakeEnd.x - fakeStart.x

        var m = dy/dx
        var y = fakeStart.y
        for (var x = fakeStart.x; x <= fakeEnd.x; ++x)
        {
            // Hardcode the colors as L = black, B = white instead:
            var upperGreyLevel = y - Math.floor(y)
            console.log("Upper: " + upperGreyLevel)
            c.fillStyle = grey(upperGreyLevel)
            fakePut(Qt.point(x, y))

            var lowerGreyLevel = 1 - upperGreyLevel
            console.log("Lower: " + lowerGreyLevel)
            c.fillStyle = grey(lowerGreyLevel)
            fakePut(Qt.point(x, y + 1))

            /*
            for (var i = 0; i < (thickness - 1) / 2; i++) {
                fakePut(Qt.point(x, y - i))
                fakePut(Qt.point(x, y + i))
            }
            */
            y += m
        }
    }

    function copy(point) {
        return Qt.point(point.x, point.y)
    }

    function rotate(point) {
        return Qt.point(point.y, point.x)
    }

    function putPixel(point, c) {
        c.fillRect(Math.round(point.x), Math.round(point.y), 1, 1) // TODO optimize
    }

    function grey(level) {
        return Qt.rgba(level, level, level, 1)
    }
}
