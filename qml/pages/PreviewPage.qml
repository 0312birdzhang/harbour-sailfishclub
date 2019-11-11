import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: previewPage
    property string mdtext
    property string parsedText
    objectName: "previewPage"

    SilicaFlickable{
        id: flickable
        anchors.fill: parent
        contentHeight: column.height

        Column{
            id: column
            anchors{
                top: parent.top
                left: parent.left
                right: parent.right
            }
            PageHeader{
                id: header
                title: qsTr("preview")
            }
            width: parent.width
            spacing: Theme.paddingMedium

            Repeater {
                model: appwindow.splitContent(parsedText, column)
                Loader {
                    anchors {
                        left: parent.left;
                        right: parent.right;
                        margins: Theme.paddingSmall;
                    }
                    source: Qt.resolvedUrl("../components/" +type + "Delegate.qml");
                }
            }

        }

    }

    Connections{
        target: signalCenter
        onPreviewMd:{
//            console.log(result)
            parsedText = result;
        }
    }

    Component.onCompleted: {
//        console.log(mdtext)
        py.previewMd(mdtext);
    }
}
