import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property alias avatar: avatar.msource
    property alias color: fontAvatar.color
    property alias text: fontAvatar.text

    MaskImage{
        id:avatar
        width: parent.height;
        height: parent.height;
        visible: avatar != ""
        anchors{
            top:parent.top
            topMargin: Theme.paddingSmall
            left:parent.left
        }
    }

    FontAvatar{
        id:fontAvatar
        width: parent.height;
        height: parent.height;
        visible:!avatar.visible
        anchors{
            top:parent.top
            topMargin: Theme.paddingSmall
            left:parent.left
        }
    }

}
