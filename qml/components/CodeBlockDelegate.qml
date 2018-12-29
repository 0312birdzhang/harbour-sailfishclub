import QtQuick 2.0
import Sailfish.Silica 1.0

TextArea{
    id: codeBlock
    text: content
    width: parent.width
    focusOnClick: true
    font.pixelSize: Theme.fontSizeSmall
    font.weight: Font.Light
    color: Theme.secondaryHighlightColor
    horizontalAlignment: TextInput.AlignLeft
    EnterKey.onClicked: parent.focus = true
    anchors{
        left:parent.left
        right:parent.right
        leftMargin: Theme.paddingMedium
        rightMargin: Theme.paddingMedium
    }

    Component.onCompleted: {
        codeBlock.readOnly = true;
    }

}
