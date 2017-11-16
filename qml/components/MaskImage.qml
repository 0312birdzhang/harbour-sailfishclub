import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    width: parent.width
    height: width
    property string msource

    // Image {
    ImageHandle {
        id: img
        source: msource
        sourceSize: Qt.size(parent.width, parent.height)
        smooth: true
        visible: false
        asynchronous: true
    }

    Rectangle{
        id:mask
        anchors.fill: parent
        radius: width/2.
    }

    OpacityMask {
        anchors.fill: parent
        source: img
        maskSource: mask
    }
}
