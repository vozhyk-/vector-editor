import QtQml 2.2

QtObject {
    property point point

    function paint(c) {
        var fg = Qt.rgba(1, 0, 0, 1)
        var border = Qt.rgba(0, 0, 0, 1)

        c.fillStyle = fg
        fill(c, point, fg, border)
    }

    function fill(c, point, fg, border) {
        var queue = [point]

        while (queue.length != 0) {
            var point = queue.shift()

            var old = getPixel(point, c)
            //console.log("old: " + old + ", fg: " + fg + ", border: " + border)
            if (Qt.colorEqual(old, border) || Qt.colorEqual(old, fg)) {
                //console.log("Skipping")
                continue
            }

            console.log(point)
            putPixel(point, c)
            queue.push(Qt.point(point.x + 1, point.y))
            queue.push(Qt.point(point.x - 1, point.y))
            queue.push(Qt.point(point.x, point.y + 1))
            queue.push(Qt.point(point.x, point.y - 1))
        }
    }

    function getPixel(point, c) {
        var data = c.getImageData(point.x, point.y, 1, 1).data
        var max = 255

        var result = Qt.rgba(
            data[0] / max,
            data[1] / max,
            data[2] / max,
            data[3] / max)
        //console.log(result)
        return result
    }

    function colorEqual(color1, color2) {
        //console.log("comparing " + color1 + " and " + color2)
        //console.log("r: " + color1.r + " =? " + color2.r)
        //console.log("g: " + color1.g + " =? " + color2.g)
        //console.log("b: " + color1.b + " =? " + color2.b)
        return color1.r == color2.r &&
            color1.g == color2.g &&
            color1.b == color2.b
    }

    function copy(point) {
        return Qt.point(point.x, point.y)
    }

    function putPixel(point, c) {
        c.fillRect(point.x, point.y, 1, 1) // TODO optimize
    }
}
