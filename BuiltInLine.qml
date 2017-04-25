import QtQml 2.2

QtObject {
    property point start
    property point end

    function paint(c) {
        c.beginPath()
        c.moveTo(start.x, start.y)
        c.lineTo(end.x, end.y)
        c.stroke()
    }
}
