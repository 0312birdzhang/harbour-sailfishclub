import QtQuick 2.0
import Sailfish.Silica 1.0

TextField{
    text: content
    width: parent.width
    readOnly: true
    focusOnClick: true
    font.weight: Font.Light
    label: "CodeBlock"
    horizontalAlignment: TextInput.AlignLeft
    EnterKey.onClicked: parent.focus = true
    anchors{
        left:parent.left
        right:parent.right
        leftMargin: Theme.paddingMedium
        rightMargin: Theme.paddingMedium
    }

    onClicked: {
        notification.show(qsTr("Long press to copy"))
    }
    onPressAndHold: {
        Clipboard.text = content;
        notification.show(qsTr("Copied to clipboard"));
    }
}
