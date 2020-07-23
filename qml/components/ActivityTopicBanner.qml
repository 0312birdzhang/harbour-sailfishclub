import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/fontawesome.js" as FONT
import "../js/ApiCore.js" as JS

Item{
    property alias model:banner.model
    width: parent.width
    height: banner.height //+ (isLandscape?Screen.height/10:Screen.height/8)
    anchors{
        left:parent.left
        right:parent.right
    }
    PathView {
        z:10
        id: banner;
        //y:-newappItem.contentY;
        //            opacity: view.contentY/height > 1 ? 0 : 1-view.contentY/height;
        //            visible: opacity>0.0;
        width: parent.width;
        height: banner.model > 0 ? (isLandscape?Screen.height/5.5:Screen.height/4):0
        preferredHighlightBegin: 0.5;
        preferredHighlightEnd: 0.5;
        path: Path {
            startX: isLandscape?(-banner.width*banner.count/4 + banner.width/4):(-banner.width*banner.count/2 + banner.width/2)
            startY: banner.height/2;
            PathLine {
                x: isLandscape?(banner.width*banner.count/4 + banner.width/4 ):(banner.width*banner.count/2 + banner.width/2)
                y: banner.height/2;
            }
        }

        clip: true
        delegate: Item {
            implicitWidth: isLandscape?banner.width/2:banner.width;
            implicitHeight: banner.height;
            clip:true

            Rectangle{
                id: rectColor
                width: parent.width
                height: parent.height
                color: category_bgColor
                opacity: 0.8
            }
            OpacityRampEffect {
                id: effect
                slope: 0.60
                offset: 0.10
                sourceItem: rectColor
            }
            Label{
                id:topicTitle
                anchors{
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingMedium
                }
                text: JS.decodeHTMLEntities(model.title)
                font.pixelSize: Theme.fontSizeSmall;
                maximumLineCount: 2
                wrapMode: Text.WrapAnywhere;
                font.letterSpacing: 2;
                color: Theme.primaryColor
            }
            Label{
                id: summaryLabel
                anchors{
                    top: topicTitle.bottom
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingMedium
                }
                text: appwindow.formatFirstPagehtml(model.latestpost)
                font.pixelSize: Theme.fontSizeTiny
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
                font.pixelSize: Theme.fontSizeTiny
                //font.italic: true
                color: Theme.secondaryColor
                //horizontalAlignment: Text.AlignRight
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    bottomMargin: Theme.paddingLarge
                    leftMargin: Theme.paddingMedium
                }
            }

            Label{
                id:viewinfo
                text:qsTr("comments: ") +postcount+" / " + qsTr("views: ") +viewcount
                //opacity: 0.7
                font.pixelSize: Theme.fontSizeTiny
                //font.italic: true
                color: Theme.secondaryColor
                //horizontalAlignment: Text.AlignRight
                anchors {
                    bottom :parent.bottom
                    right: parent.right
                    bottomMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingMedium
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
    Rectangle{
        z:8
        anchors.top:banner.bottom
        //            opacity: view.contentY/banner.height > 1 ? 0 : 1-view.contentY/banner.height;
        //            visible: opacity>0.0;
        width: parent.width;
        height: isLandscape?Screen.height/10:Screen.height/4/2
        gradient: Gradient {
            GradientStop { position: 0; color: "#08202c" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }
    Row{
        z:11
        anchors.left: parent.left;
        anchors.bottom: banner.bottom
        //            opacity: view.contentY/banner.height > 1 ? 0 : 1-view.contentY/banner.height;
        //            visible: opacity>0.0;
        Repeater{
            model: banner.count
            Rectangle{
                width:  isLandscape?Screen.width/banner.count*2:Screen.width/banner.count
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
