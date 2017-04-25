import QtQml 2.2

QtObject {
    property point start
    property point end

    function paint(c) {
        var dy = end.y - start.y
        var dx = end.x - start.x
        var m = dy/dx
        var y = start.y
        for (var x = start.x; x <= end.x; ++x)
        {
            putPixel(Qt.point(x, y), c)
            y += m
        }
    }

    function putPixel(point, c) {
        c.fillRect(point.x, point.y, 1, 1) // TODO optimize
    }
}
