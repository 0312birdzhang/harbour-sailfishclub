import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property alias avatar: avatar.msource
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


}
