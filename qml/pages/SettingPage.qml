import QtQuick 2.0
import Sailfish.Silica 1.0

Page{
    property string rcolor;
    property string ltext;
    Item {
        width: 200
        height: 200
        anchors.fill: parent
        Rectangle {
            id:rect
            width: parent.width
            height: width
            radius: width*0.5
            color: rcolor//"#f44336"

        }
        Label {
            id:fn
            anchors.centerIn: rect
            font.pixelSize: parent.width * 0.8
            text: ltext//"一"
        }
    }

    Component.onCompleted: {
        rcolor = "#f44336"
        ltext = "熊"
    }
}
