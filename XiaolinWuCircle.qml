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

        wuCircle(R, function(x, y) {
            putMiddle(x, y)
            putMiddle(y, x)
        }, function(color) {
            c.fillStyle = color
        })
    }

    function wuCircle(R, put, setColor)
    {
        var D = function(R, y) {
            var s = Math.sqrt(R * R - y * y)
            return Math.ceil(s) - s
        }

        var x = R;
        var y = 0;
        put(x, y);
        while (x > y)
        {
            ++y;
            x = Math.ceil(Math.sqrt(R * R - y * y));
            var T = D(R, y);
            var rightGreyLevel = T;
            var leftGreyLevel = 1 - T;
            setColor(grey(rightGreyLevel))
            put(x, y);
            setColor(grey(leftGreyLevel))
            put(x - 1, y);
        }
        setColor(grey(0))
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
