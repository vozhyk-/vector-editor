import QtQml 2.2

QtObject {
    property point start
    property point end

    function paint(c) {
        var dist = Qt.point(end.x - start.x, end.y - start.y)
        var R = Math.sqrt(dist.x * dist.x + dist.y * dist.y)

        var putRelative = function(x, y) {
            putPixel(Qt.point(start.x + x, start.y + y), c)
        }

        var putMiddle = function(x, y) {
            putRelative(x, y)
            putRelative(x, -y)
            putRelative(-x, y)
            putRelative(-x, -y)
        }

        midpointCircle(R, function(x, y) {
            putMiddle(x, y)
            putMiddle(y, x)
        })
    }

    function midpointCircle(R, put) {
        var dE = 3;
        var dSE = 5-2*R;
        var d = 1-R;
        var x = 0;
        var y = R;
        put(x, y)
        while (y > x)
        {
            if (d < 0)
                //move to E
            {
                d += dE;
                dE += 2;
                dSE += 2;
            }
            else
                //move to SE
            {
                d += dSE;
                dE += 2;
                dSE += 4;
                --y;
            }
            ++x;
            put(x, y)
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
}
