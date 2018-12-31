import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
   width: parent.width
   height: img.height
   Label{
       id: titleid
       text: title
       font.pixelSize: Theme.fontSizeMedium
       truncationMode: TruncationMode.Fade
       wrapMode: Text.WordWrap
       color: Theme.highlightColor
       font.bold:true;
       anchors {
           top:parent.top;
           left: parent.left
           right: parent.right
           topMargin: Theme.paddingMedium
           leftMargin: Theme.paddingMedium
           rightMargin: Theme.paddingMedium
       }
   }

   Label{
       id:latestPost
       text: appwindow.formatFirstPagehtml(description)
       textFormat: Text.StyledText
       font.pixelSize: Theme.fontSizeSmall
       wrapMode: Text.WordWrap
       linkColor:Theme.primaryColor
       maximumLineCount: 3
       anchors {
           top: titleid.bottom
           left: parent.left
           right: parent.right
           topMargin: Theme.paddingMedium
           leftMargin: Theme.paddingMedium
           rightMargin: Theme.paddingMedium
       }
   }

   Label{
       id:timeid
       text: inserted_at
       font.pixelSize: Theme.fontSizeSmall
       color: Theme.secondaryColor
       anchors {
           right: parent.right
           bottom: parent.bottom
           topMargin: Theme.paddingMedium
           leftMargin: Theme.paddingMedium
       }
   }

   CacheImage{
       id: img
       asynchronous: true
       sourceUncached: cover
       smooth: true
       opacity: 0.2
       width: parent.width
       sourceSize.width: width // photoSourceSize
       sourceSize.height: width/16*9   //photoSourceSize
       clip: true
   }

   onClicked: {
        pageStack.push(Qt.resolvedUrl("../pages/UnOfficalBlogContent.qml"),{
                            "slug":slug,
                            "cover": cover,
                            "_title": title
                        });
    }
}
