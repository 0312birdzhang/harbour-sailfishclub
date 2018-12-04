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
                width: parent.width
                sourceSize.width: width
                clip: true
            }

            Label{
                id:contentbody
                opacity: 0.8
                textFormat: Text.RichText
                text: '<style>a:link { color: ' + Theme.highlightColor + '; }</style>' +
                      content + "<br/><br/><br/>"
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                linkColor: Theme.primaryColor
                font.letterSpacing: 2;
                anchors{
                    left:parent.left
                    right:parent.right
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
                onLinkActivated: {
                    appwindow.openLink(link);
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
