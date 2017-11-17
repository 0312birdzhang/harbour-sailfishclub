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
                call('myprovider.load',[cacheurl],,function(result){
                    if(!result){
                        thumbnail.source = "image://theme/harbour-sailfishclub"
                    }else{
                        thumbnail.source = result;
                    }
                     waitingIcon.visible = false;
                });
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
