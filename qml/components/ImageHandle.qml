import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4

Image {
    id: image
    asynchronous: true
    property string cacheurl
    property string username


    Image{
        id:waitingIcon
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        source: "image://theme/icon-m-refresh";
        visible: parent.status==Image.Loading
    }

    Component.onCompleted: {
        image.source = "";
        py.loadImage(username,cacheurl);
    }

    Connections{
        target: signalCenter
        onLoadImage:{
            image.source = result;
            waitingIcon.visible = false;
        }

    }
}
