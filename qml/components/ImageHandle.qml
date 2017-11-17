import QtQuick 2.0
import Sailfish.Silica 1.0


Image {
    id: image
    asynchronous: true
    property string cacheurl

    Connections{
        target: signalCenter
        onLoadImage:{
            image.source = result;
            waitingIcon.visible = false;
        }

    }
    Image{
        id:waitingIcon
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        source: "image://theme/icon-m-refresh";
        visible: parent.status==Image.Loading
    }

    Component.onCompleted: {
        appwindow.py.loadImg(cacheurl);
    }
}
