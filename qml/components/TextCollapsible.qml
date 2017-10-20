import QtQuick 2.0
import Sailfish.Silica 1.0
Text {
    id: root
    clip: true
    property int maxHeight: Screen.height /4

    property int __fullHeight: 0
    property bool __overflow: false
    property bool __collapsed: false

    onLinkActivated: {
        Qt.openUrlExternally(link);
    }
    color: Theme.primaryColor
    function updateHeight() {
        if (__overflow) {
            if (__collapsed) {
                root.height = maxHeight;
            } else {
                root.height = __fullHeight;
            }
        }
    }

    onTextChanged: {
        if (root.height > maxHeight) {
            __overflow = true;
            __collapsed = true;
            __fullHeight = root.height;
            updateHeight();
        }
    }

    Item {
    //Rectangle {
        width: parent.width
        height: Theme.itemSizeMedium
        anchors {
            bottom: root.bottom
        }
        /*gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: "white"}
        }*/
        Image {
            id: imageArrowz
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
            source: __collapsed?"image://theme/icon-m-down":"image://theme/icon-m-up"
        }

        visible: __overflow
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            __collapsed = !__collapsed;
            updateHeight();
        }
    }
}