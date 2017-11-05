import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../js/main.js" as Script

Item{
    property alias model:banner.model
//    property Page name: value
    anchors{
        left:parent.left
        right:parent.right
        top:parent.top
    }
    PathView {
        z:10
        id: banner;
        //y:-newappItem.contentY;
        //            opacity: view.contentY/height > 1 ? 0 : 1-view.contentY/height;
        //            visible: opacity>0.0;
        width: parent.width;
        height: Screen.height/3.5
        preferredHighlightBegin: 0.5;
        preferredHighlightEnd: 0.5;
        path: Path {
            startX: -banner.width*banner.count/2 + banner.width/2;
            startY: banner.height/2;
            PathLine {
                x: banner.width*banner.count/2 + banner.width/2;
                y: banner.height/2;
            }
        }
        // model:coverModel
        clip: true
        delegate: Item {
            implicitWidth: banner.width;
            implicitHeight: banner.height;
            clip:true
            Image {
                anchors.centerIn: parent;
                fillMode: Image.PreserveAspectCrop;
                source: previewImg.status === Image.Ready
                        ? "" : "image://theme/icon-m-refresh";
            }
            CacheImage {
                id: previewImg;
                anchors.fill: parent;
                fillMode: Image.PreserveAspectCrop
                width: parent.width
                height: parent.height
                cacheurl: Script.getPostericon(uploader.uid,_id)
            }
            Rectangle{
                width: parent.width;
                height: parent.height;
                //anchor.fill:parent;
                gradient: Gradient {
                    GradientStop { position: 0.5; color: "#00000000" }
                    GradientStop { position: 1.0; color:"#08202c" }
                }
            }
            Label{
                id:articatitle
                anchors{
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: Theme.paddingMedium
                }
                text:""/*appname*/
                font.pixelSize: Theme.fontSizeSmall;
                wrapMode: Text.WrapAnywhere;
                font.letterSpacing: 2;
                color: Theme.highlightColor
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
                    pageStack.push(Qt.resolvedUrl("TopicPage.qml"),{
                                   "tid":tid,
                                   "topic_title":title,
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
        height: Screen.height/4/2
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
            model: 5
            Rectangle{
                width: Screen.width/5
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
