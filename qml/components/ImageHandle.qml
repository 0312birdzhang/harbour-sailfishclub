import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4

Image {
    id: image
    asynchronous: true
    property string cacheurl

    // Qt.createComponent() ???

    // Python {
    //     id: propy
    //     Component.onCompleted: {
    //         addImportPath("qrc:/py/");
    //         propy.importModule('myprovider', function () {
    //             image.source = 'image://python/' + cacheurl;
    //         });
    //     }

    //     onError: console.log('Python error: ' + traceback)
    // }
    Image{
        id:waitingIcon
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        source: "image://theme/icon-m-refresh";
        visible: parent.status==Image.Loading
    }

    Component.onCompleted: {
        py.loadImage(cacheurl);
    }

    Connections{
        target: signalCenter
        onLoadImage:{
            image.source = result;
            waitingIcon.visible = false;
        }

    }
}
