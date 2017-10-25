import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
      width: parent.width
      height: parent.height
      property alias color: rect.color
      property alias text: fn.text
        Rectangle {
            id:rect
            width: parent.width
            height: width
            // color: "red"
            radius: width*0.5
            
        }
        Label {
            id:fn
            anchors.centerIn: rect
            color: "white"
            font.pixelSize: parent.width
            // text: "B"
        }
}