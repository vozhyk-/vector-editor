import QtQml 2.2

QtObject {
    property point start
    property point end
    property var lineComponent

    Component.onCompleted: {
    }

    function paint(c) {
        lineComponent.createObject(this, {
            start: start,
            end: end
        }).paint(c)
    }

    function add(point1, point2) {
        return Qt.point(
            point1.x + point2.x,
            point1.y + point2.y)
    }

    function sub(point1, point2) {
        return add(point1, Qt.point(-point2.x, -point2.y))
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
