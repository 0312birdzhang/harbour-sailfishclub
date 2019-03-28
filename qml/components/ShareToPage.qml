import QtQuick 2.0
import Sailfish.Silica 1.0
//import Sailfish.TransferEngine 1.0

Page {
    id: page

    allowedOrientations:Orientation.All
    
    property string link
    property string linkTitle

    ShareMethodList {
        id: methodlist
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Share this topic!")
        }
        content: {
            "type": "text/x-url",
            "status": page.link,
            "linkTitle": page.linkTitle
        }
        filter: "text/x-url"

        ViewPlaceholder {
            enabled: methodlist.count == 0
            text: qsTr("No sharing plugins installed, try to install Aliendalvik Control or others from StoreMan!")
        }
    }
}

