import QtQuick 2.0
import Sailfish.Silica 1.0


Item {
    id: avatarItem
//    property alias avatar: avatar.msource
//    property alias color: fontAvatar.color
//    property alias text: fontAvatar.text
    property string avatar
    property string color
    property string text
    property string username

    Loader{
        sourceComponent: avatar? avatarComponent : fontAvatarComponent
        anchors.fill: parent
    }

    Component{
        id: avatarComponent
        MaskImage{
            width: parent.height;
            height: parent.height;
            msource: avatarItem.avatar
            name: avatarItem.username
            anchors{
                top:parent.top
                topMargin: Theme.paddingSmall
                left:parent.left
            }
        }
    }

    Component{
        id: fontAvatarComponent
        FontAvatar{
            width: parent.height;
            height: parent.height;
            color: avatarItem.color
            text: avatarItem.text
            anchors{
                top:parent.top
                topMargin: Theme.paddingSmall
                left:parent.left
            }
        }
    }



}
