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
 }
