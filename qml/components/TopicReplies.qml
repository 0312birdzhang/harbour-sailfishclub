import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property variant replies
    width: parent.width
    height: parent.height

    Row{
        id: usersRow
        spacing: -Theme.itemSizeExtraSmall/4
        height: parent.height
        width: parent.width
        Repeater{
            model: replies.count
            Avatar{
                width: parent.height;
                height: width;
                avatar: appwindow.getPicture(replies.users[index].picture)
                username: replies.users[index].username
                text: replies.users[index]["icon:text"]
                color: replies.users[index]["icon:bgColor"]
            }
        }


    }

    Label{
        visible: replies.count > 0
        text:  "<br>" + replies.count.toString() + "</br> " + qsTr("replaies")
        width: parent.width
        maximumLineCount: 3
        textFormat: Text.StyledText
        font.pixelSize: Theme.fontSizeTiny
        color: Theme.secondaryColor
        x: replies.count * ( parent.height - Theme.itemSizeExtraSmall/4 )
           + Theme.paddingMedium*3
        anchors{
            verticalCenter: parent.verticalCenter
        }
    }


}
