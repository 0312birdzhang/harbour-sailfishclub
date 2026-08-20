import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/fontawesome.js" as FONT
import "../js/ApiCore.js" as JS

Item{
    property alias model:banner.model
    property bool landscape: false
    property real portraitHeight: Screen.height/4
    width: landscape ? Screen.height / 2 : parent.width
    height: banner.count > 0 ? (landscape ? parent.height : banner.height) : 0
    anchors.left: parent.left
    PathView {
        z:10
        id: banner;
        width: parent.width;
        height: banner.count > 0 ? (landscape ? parent.height : portraitHeight):0
        preferredHighlightBegin: 0.5;
        preferredHighlightEnd: 0.5;
        path: Path {
            // landscape: vertical carousel (up/down), portrait: horizontal carousel
            startX: landscape ? banner.width/2 : (-banner.width*banner.count/2 + banner.width/2)
            startY: landscape ? (banner.height/2 + (banner.count-1)/2 * banner.height/2) : banner.height/2
            PathLine {
                x: landscape ? banner.width/2 : (banner.width*banner.count/2 + banner.width/2)
                y: landscape ? (banner.height/2 - (banner.count-1)/2 * banner.height/2) : banner.height/2
            }
        }

        clip: true
        delegate: Item {
            implicitWidth: banner.width;
            implicitHeight: landscape ? (banner.height/2 * 0.85) : banner.height;
            clip:true

            Rectangle{
                id: rectColor
                width: parent.width
                height: parent.height
                color: category_bgColor
                opacity: 0.8
            }
            Label{
                id:topicTitle
                anchors{
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    topMargin: Theme.paddingLarge * 2
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                }
                text: JS.decodeHTMLEntities(model.title)
                font.pixelSize: Theme.fontSizeLarge;
                maximumLineCount: 2
                wrapMode: Text.WrapAnywhere;
                font.letterSpacing: 2;
                color: Theme.primaryColor
            }
            Label{
                id: summaryLabel
                visible: !landscape
                anchors{
                    top: topicTitle.bottom
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text: appwindow.formatFirstPagehtml(model.latestpost)
                font.pixelSize: Theme.fontSizeSmall
                maximumLineCount: 3
                linkColor: Theme.highlightColor
                wrapMode: Text.WrapAnywhere
                font.letterSpacing: 2;
                color: Theme.primaryColor
            }

            Label{
                id:timeid
                text:FONT.Icon[category_icon.replace(/-/g,"_")]  + category + " "+ JS.humanedate(timestamp)
                //opacity: 0.7
                font.pixelSize: Theme.fontSizeSmall
                //font.italic: true
                color: Theme.secondaryColor
                //horizontalAlignment: Text.AlignRight
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    bottomMargin: Theme.paddingMedium
                    leftMargin: Theme.paddingLarge
                }
            }

            Label{
                id:viewinfo
                text:qsTr("comments: ") +postcount+" / " + qsTr("views: ") +viewcount
                //opacity: 0.7
                font.pixelSize: Theme.fontSizeSmall
                //font.italic: true
                color: Theme.secondaryColor
                //horizontalAlignment: Text.AlignRight
                anchors {
                    bottom :parent.bottom
                    right: parent.right
                    bottomMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingLarge
                }
            }
            Rectangle {
                anchors.fill: parent;
                color: "black";
                opacity: mouseArea.pressed ? 0.3 : 0;
            }
            MouseArea {
                id: mouseArea;
                anchors.fill: parent;
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../pages/TopicPage.qml"),{
                                   "tid":tid,
                                   "topic_title": title,
                                   "slug":slug,
                                   "user":user,
                                   "category":category,
                                   "category_icon":category_icon
                               });
                }
            }
        }
        Timer {
            running: Qt.application.active && banner.count > 1 && !banner.moving
            interval: 3000;
            repeat: true;
            onTriggered: banner.incrementCurrentIndex();
        }
    }
    Row{
        z:11
        anchors.left: parent.left;
        anchors.bottom: banner.bottom
        visible: banner.count > 0 && !landscape
        Repeater{
            model: banner.count
            Rectangle{
                width:  landscape?Screen.width/banner.count*2:Screen.width/banner.count
                height: Theme.paddingSmall
                color: banner.currentIndex==index?"#22ffffff":"#44000000"
                MouseArea {
                    anchors.fill: parent;
                    onClicked: {
                        banner.currentIndex=index;
                    }
                }
            }
        }
    }
}
