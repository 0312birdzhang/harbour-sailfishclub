import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root;

    property int bh: Math.min(400, Screen.height);
    property int bw: Math.min(540, Screen.width);
    // implicitHeight: bh;
    height: img.height

    //var ww = Math.min(200, w), hh = Math.min(h * ww/w, 200);

    MouseArea {
        anchors.fill: img;
        onClicked: {
            pageStack.push(Qt.resolvedUrl("ImageHandle.qml"),{"localUrl": img.source});
        }
    }

    Image {
        id: img;
        anchors.horizontalCenter: root.horizontalCenter;
        width: Screen.width - Theme.paddingMedium;
        // width: bw;
        cache: true;
        // height: parent.height;
        fillMode: Image.PreserveAspectFit;
        // sourceSize.width: bw;
        source: content;
        asynchronous: true;
        Image {
            anchors.fill: parent
            visible: img.status !== Image.Ready
            source: "image://theme/icon-m-refresh";
        }
    }


}
