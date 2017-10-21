import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id:horizontalIconTextButton

    property bool down: pressed && containsMouse
    property alias text: buttonText.text
    property int fontSize: Math.max(fs.width, fs.height)
    property bool _showPress: down || pressTimer.running
    property color color: Theme.primaryColor
    property color highlightColor: Theme.highlightColor
    property int spacing: Theme.paddingMedium
    property alias icon: fs.text
    property real iconSize: Theme.iconSizeSmall

    onPressedChanged: {
        if (pressed) {
            pressTimer.start()
        }
    }
    onCanceled: pressTimer.stop()

    width: fs.width + buttonText.width + horizontalIconTextButton.spacing
    height: Math.max(fs.height, buttonText.height)

    Timer {
        id: pressTimer
        interval: 50
    }
    Row {
        id: row
        spacing: horizontalIconTextButton.spacing
        Label {
            id:fs
            width: horizontalIconTextButton.iconSize
            height: fs.width
            font.pixelSize: horizontalIconTextButton.fontSize
        }
        Label {
            id:buttonText
            anchors.verticalCenter: fs.verticalCenter
            color: _showPress ? horizontalIconTextButton.highlightColor : horizontalIconTextButton.color
            font.pixelSize: horizontalIconTextButton.fontSize
        }
    }
}
