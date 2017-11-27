import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root;

    property string iconName;
    property string title;
    property string subTitle;
    property bool markVisible: false;

    signal clicked;

    width: parent.width / 3;
    height: 160;
    opacity: mouseArea.pressed ? 0.7 : 1;

    Rectangle{
        anchors.fill: parent;
        color: "#00ffffff"
    }

    Column {
        id: logo;
        anchors.centerIn: parent;
        Image {
            anchors.horizontalCenter: parent.horizontalCenter;
            source: "../gfx/cent_icon_"+root.iconName+constant.invertedString;
            Image {
                anchors { top: parent.top; right: parent.right; }
                source: root.markVisible ? "../gfx/ico_mbar_news_point.png" : "";
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter;
            font.pixelSize: constant.fontXXSmall;
            color: constant.colorLight;
            text: root.title;
        }
    }
    Text {
        anchors { top: logo.bottom; horizontalCenter: parent.horizontalCenter; }
        font.family: "Nokia Pure Text";
        font.pixelSize: constant.fontXXSmall;
        color: constant.colorMid;
        text: root.subTitle;
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent;
        onClicked: root.clicked();
    }
}
