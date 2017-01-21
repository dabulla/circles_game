import QtQuick 2.0

Rectangle {
    id: root
    width: Math.max(1, parent.width)
    height: width
    x: -width*0.5
    y: -height*0.5
    radius: width*0.5
}

