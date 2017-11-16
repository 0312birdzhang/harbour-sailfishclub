import QtQuick 2.0
import io.thp.pyotherside 1.4

Image {
    id: image
    property string url;
    Python {
        Component.onCompleted: {
            // Add the directory of this .qml file to the search path
            addImportPath('qrc:/py/')
            importModule('image', function () {
                image.source = 'image://python/'+ url;
            });
        }
        onError: console.log('Python error: ' + traceback)
    }
}