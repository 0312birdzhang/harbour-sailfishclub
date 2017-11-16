import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4


Image {
    id: image
    asynchronous: true
    property string cacheurl
    Python {
        id:provider
        Component.onCompleted: {
            console.log("cacheurl:"+cacheurl)
            addImportPath('qrc:/py/');
            provider.importModule('myprovider', function () {
                image.source = 'image://python/'+ cacheurl;
            });
        }
        onError: console.log('Python error: ' + traceback)
    }

    Image{
        id:waitingIcon
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        source: "image://theme/icon-m-refresh";
        visible: parent.status==Image.Loading
    }
}
