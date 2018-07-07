import QtQuick 2.0
import Sailfish.Silica 1.0

 Label{
     text: content
     textFormat: Text.RichText
     font.pixelSize: Theme.fontSizeExtraSmall
     wrapMode: Text.WordWrap
     linkColor:Theme.primaryColor
     font.letterSpacing: 2;
     anchors{
         left:parent.left
         right:parent.right
         leftMargin: Theme.paddingMedium
         rightMargin: Theme.paddingMedium
     }
     onLinkActivated: {
         appwindow.openLink(link);
     }
     //暂时屏蔽掉
//     MouseArea{
//         anchors.fill: parent
//         onClicked: {
//             if(content && content.indexOf("<code>") > 0 ){
//                notification.show(qsTr("Long press to copy"))
//             }
//         }
//         onPressAndHold: {
//             if(content && content.indexOf("<code>") > 0){
//                 Clipboard.text = content;
//                 notification.show(qsTr("Copied to clipboard"));
//             }
//         }
//     }
 }
