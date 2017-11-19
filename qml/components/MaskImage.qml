import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id:maskImage
    width: parent.width
    height: width
    property string msource
    property string name


    Image{
        id: img
        source: msource
        sourceSize: Qt.size(maskImage.width, maskImage.height)
        smooth: true
        visible: false
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
