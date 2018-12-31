import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page{

    property string slug;
    property string cover;
    property string _title;
    property string content;

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        width: parent.width
        clip: true
        contentHeight: column.height + Theme.paddingMedium * 4
        Column{
            id: column
            spacing: Theme.paddingMedium
            width: parent.width

            PageHeader {
                id:header
                title: _title
                _titleItem.font.pixelSize: Theme.fontSizeSmall
            }
            
            CacheImage{
                id: img
                asynchronous: true
                sourceUncached: cover
                smooth: true
                width: parent.width - Theme.paddingLarge
                sourceSize.width: width
                clip: true
                anchors{
                    horizontalCenter: parent.horizontalCenter
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
            }

            Column{
                id: contentLabel
                width: parent.width;
                spacing: Theme.paddingSmall
                anchors{
                    left:parent.left
                    right:parent.right
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
                Repeater {
                    model: splitContent(content.replace(/<img/g, '<img width="'+ (parent.width - Theme.paddingLarge)+'"'), contentLabel)
                    Loader {
                        anchors {
                            left: parent.left; right: parent.right;
                            margins: Theme.paddingSmall;
                        }
                        source: Qt.resolvedUrl("../components/" +type + "Delegate.qml");
                    }
                }
            }
        }
    }
    Connections{
        target: signalCenter
        onGetUnOfficalContent:{
            if(result){
                content = result.content;
            }
        }
    }

    Component.onCompleted: {
        py.getUnOfficalContent(slug);
    }
}
