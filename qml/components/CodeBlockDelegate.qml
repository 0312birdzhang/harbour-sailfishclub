import QtQuick 2.0
import Sailfish.Silica 1.0

TextArea{
    id: codeBlock
    property int originHeight: 0

    text: content
    width: parent.width
    focusOnClick: true
    font.pixelSize: Theme.fontSizeSmall
    font.weight: Font.Light
    color: Theme.secondaryColor
    horizontalAlignment: TextInput.AlignLeft
    EnterKey.onClicked: parent.focus = true
    anchors{
        left:parent.left
        right:parent.right
        leftMargin: Theme.paddingMedium
        rightMargin: Theme.paddingMedium
    }
    onClicked: {
        codeBlock.height = codeBlock.originHeight ===0? Theme.dp(30):codeBlock.originHeight
    }

    Component.onCompleted: {
        codeBlock.readOnly = true;
        codeBlock.originHeight = codeBlock.height
        codeBlock.height = Theme.dp(30)
    }

}
