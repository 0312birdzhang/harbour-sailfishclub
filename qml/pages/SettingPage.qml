import QtQuick 2.0
import Sailfish.Silica 1.0

Page{
    Item {
        width: 200
        height: 200
        anchors.fill: parent
        Rectangle {
            id:rect
            width: parent.width
            height: width
            radius: width*0.5
            color: "#f44336"

        }
        Label {
            id:fn
            anchors.centerIn: rect
            font.pixelSize: parent.width
            text: "一"
        }
    }
}
