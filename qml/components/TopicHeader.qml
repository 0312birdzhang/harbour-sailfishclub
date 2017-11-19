import QtQuick 2.0
import Sailfish.Silica 1.0

Item{
    property alias avatar: avatar.avatar
    property alias user: username.text
    property string user_id
    property alias groupTitle: groupTitle.text
    property alias time: postTime.text
    property alias index: floor.text
    property alias color: avatar.color
    property alias text: avatar.text
    width: parent.width
    height: parent.height

    Avatar{
        id:avatar
        width: parent.height;
        height: parent.height;
        username: username.text
        MouseArea{
            anchors.fill: parent
                onClicked: {
                    toUserInfoPage(user_id);
            }
        }
    }


    Label{
        id:username
        font.pixelSize: Theme.fontSizeSmall
        anchors{
            left:avatar.right
            leftMargin: Theme.paddingSmall
            top:parent.top
        }
    }

    Label{
        id:groupTitle
        font.pixelSize: Theme.fontSizeTiny
        anchors{
            left:username.right
            leftMargin: Theme.paddingSmall
            top:parent.top
        }
    }

    Label{
        id:postTime
        font.pixelSize: Theme.fontSizeTiny
        color: Theme.secondaryColor
        anchors{
            top:username.bottom
            topMargin: Theme.paddingSmall
            left:username.left
            leftMargin: Theme.paddingSmall
        }
    }


    Label{
        id:floor
        font.pixelSize: Theme.fontSizeSmall
        anchors{
            top:parent.top
            right:parent.right
            rightMargin: Theme.paddingSmall
        }
    }
}
