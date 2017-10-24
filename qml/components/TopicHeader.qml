import QtQuick 2.0
import Sailfish.Silica 1.0

Item{
    property alias avatar: avatar.msource
    property alias user: username.text
    property alias groupTitle: groupTitle.text
    property alias time: postTime.text
    property alias index: floor.text
    width: parent.width
    height: parent.height

    
    MaskImage{
        id:avatar
        width: parent.height;
        height: parent.height;
        anchors{
            top:parent.top
            topMargin: Theme.paddingSmall
            left:parent.left
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
