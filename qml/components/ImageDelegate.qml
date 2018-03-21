import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root;

    property int bh: Math.min(800, Screen.height);
    property int bw: Math.min(500, Screen.width);
    implicitHeight: bh;

    //var ww = Math.min(200, w), hh = Math.min(h * ww/w, 200);

    MouseArea {
        anchors.fill: img;
        onClicked: {
            // TODO 不需要缓存
            pageStack.push(Qt.resolvedUrl("ImagePage.qml"),{"localUrl":content});
        }
    }

    Image {
        id: img;
        anchors.horizontalCenter: root.horizontalCenter;
        //width: Screen.width*3/4;
        width: bw;
        height: parent.height;
        fillMode: Image.PreserveAspectFit;
        sourceSize.width: bw;
        source: content;
        asynchronous: true;
    }

    Image {
        anchors.centerIn: img;
        sourceSize.width: Theme.fontSizeMedium * 2
        source: img.status === Image.Ready ? "" : "image://theme/icon-m-refresh";
        asynchronous: true;
    }
}
