import QtQuick 2.0
import Sailfish.Silica 1.0

Item{
    id:toolbar
    property Page page
    clip: true;
    function hideExbar(){
        toolbar.showExbar=false;
        toolbar.height=toolbar.iheight;
        mebubtn.visible=true;
        mebubtn_down.visible=false;
    }

    anchors{
        bottom: page.bottom
    }
    height: 0;
    property int iheight: showExbar ? iconbar.height+exbar.height : iconbar.height;
    property bool showExbar: false
    width: page.width;

    Rectangle{
        id:exbar
        anchors.bottom: iconbar.top;
        color: "#08202c"
        height: (Theme.iconSizeMedium+Theme.paddingMedium*2)*4+4;
        width: page.width;
        Column{
            width: page.width;
            height: parent.height;
            TabButton{//Author only-只看楼主
                icon.source:"image://theme/icon-m-people"
                text:qsTr("Author only");
                onClicked: {
                    currentTab.isReverse = false;
                    currentTab.isLz = !currentTab.isLz;
                    currentTab.getlist();
                    toolbar.hideExbar();
                }
            }
            Rectangle{
                width: parent.width;
                height: 1;
                color: Theme.rgba(Theme.highlightColor, 0.2)
            }
            TabButton{//Reverse-倒叙查看
                icon.source: "image://theme/icon-m-transfer";
                text:qsTr("Reverse")
                onClicked: {
                        currentTab.isLz = false;
                        currentTab.isReverse = !currentTab.isReverse;
                        currentTab.getlist();
                    toolbar.hideExbar();
                }
            }
            Rectangle{
                width: parent.width;
                height: 1;
                color: Theme.rgba(Theme.highlightColor, 0.2)
            }
            TabButton{//Jump to page-跳转
                icon.source: "image://theme/icon-m-rotate-right";
                text:qsTr("Jump to page");
                onClicked: {
                    internal.jumpToPage();
                    toolbar.hideExbar();
                }
            }
            Rectangle{
                width: parent.width;
                height: 1;
                color: Theme.rgba(Theme.highlightColor, 0.2)
            }
            TabButton{//Open browser-用浏览器打开本帖
                icon.source: "image://theme/icon-m-computer"
                text:qsTr("Open browser");
                onClicked: {
                    signalCenter.openBrowser("http://tieba.baidu.com/p/"+currentTab.threadId);
                    toolbar.hideExbar();
                }
            }
            Rectangle{
                width: parent.width;
                height: 1;
                color: Theme.rgba(Theme.highlightColor, 0.2)
            }
        }
    }

    Rectangle{
        id:iconbar
        anchors.bottom: parent.bottom
        color: "#08202c"
        height: Theme.iconSizeMedium+Theme.paddingMedium*2;
        width: page.width;
        Row{
            TabButton{
                icon.source: "image://theme/icon-m-edit"
                width: (page.width-Theme.iconSizeMedium-Theme.paddingMedium*2)/2
                text:qsTr("New post");
                onClicked: {
                    var prop = { isReply: true, caller: currentTab }
                    pageStack.push(Qt.resolvedUrl("../Post/PostPage.qml"), prop);
                    toolbar.hideExbar();
                }
            }
            TabButton{
                icon.source: "image://theme/icon-m-refresh"
                width: (page.width-Theme.iconSizeMedium-Theme.paddingMedium*2)/2
                text:qsTr("refresh");
                onClicked: {
                    currentTab.getlist();
                    toolbar.hideExbar();
                }
            }
            IconButton{
                id:mebubtn
                width: Theme.iconSizeMedium+Theme.paddingMedium*2
                icon.source: "image://theme/icon-m-menu"
                onClicked: {
                    toolbar.showExbar=true;
                    toolbar.height=toolbar.iheight;
                    mebubtn.visible=false;
                    mebubtn_down.visible=true;
                }
            }
            IconButton{
                id:mebubtn_down
                width: Theme.iconSizeMedium+Theme.paddingMedium*2
                icon.source: "image://theme/icon-m-down"
                onClicked: {
                    toolbar.showExbar=false;
                    toolbar.height=toolbar.iheight;
                    mebubtn.visible=true;
                    mebubtn_down.visible=false;
                }
            }
        }
    }
    Behavior on height {NumberAnimation{duration: 150}}
    Connections {
        target: pageStack
        onCurrentPageChanged: {
            toolbar.hideExbar();
        }
    }
}