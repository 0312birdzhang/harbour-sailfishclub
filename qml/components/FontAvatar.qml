import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: fv
    width: parent.width
    height: parent.height
    property string color
    property string text
    Rectangle {
        id:rect
        antialiasing: true
        width: parent.width
        height: width
        color: fv.color ? fv.color : "steelblue"
        radius: width*0.5
    }

    Label {
        id:fn
        text: fv.text
        anchors.centerIn: rect
        font.pixelSize: parent.width * 0.75
    }

}
