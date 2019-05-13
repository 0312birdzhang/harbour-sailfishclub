import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/twemoji.js" as Emoji

 Label{
//     text: content
     text: Emoji.emojify(content, Theme.fontSizeExtraSmall)
     textFormat: Text.StyledText
     font.pixelSize: Theme.fontSizeExtraSmall
     wrapMode: Text.WordWrap
     linkColor: Theme.highlightColor
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
