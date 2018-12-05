import QtQuick 2.0
import Sailfish.Silica 1.0

Item{
    id:toolbar
    clip: true;

    signal openShare();
    signal openBrowser();

    function hideExbar(){
        toolbar.showExbar=false;
        toolbar.height=toolbar.iheight;
        mebubtn.visible=true;
        mebubtn_down.visible=false;
    }

    anchors{
        bottom: topicPage.bottom
    }
    height: 0;
    property int iheight: showExbar ? iconbar.height+exbar.height : iconbar.height;
    property bool showExbar: false
    width: topicPage.width;

    Rectangle{
        id:exbar
        anchors.bottom: iconbar.top;
        color: Theme.colorScheme?Theme.lightSecondaryColor:Theme.darkSecondaryColor
        height: (Theme.iconSizeMedium+Theme.paddingMedium *2) * 2 + 4;
        width: topicPage.width;
        Column{
            width: topicPage.width;
            height: parent.height;
//                TabButton{//Author only-只看楼主
//                    icon.source:"image://theme/icon-m-people"
//                    text:qsTr("Author only");
//                    onClicked: {
//                        currentTab.isReverse = false;
//                        currentTab.isLz = !currentTab.isLz;
//                        currentTab.getlist();
//                        toolbar.hideExbar();
//                    }
//                }
//                Rectangle{
//                    width: parent.width;
//                    height: 1;
//                    color: Theme.rgba(Theme.highlightColor, 0.2)
//                }
//                TabButton{//Reverse-倒叙查看
//                    icon.source: "image://theme/icon-m-transfer";
//                    text:qsTr("Reverse")
//                    onClicked: {
//                            currentTab.isLz = false;
//                            currentTab.isReverse = !currentTab.isReverse;
//                            currentTab.getlist();
//                        toolbar.hideExbar();
//                    }
//                }
//                Rectangle{
//                    width: parent.width;
//                    height: 1;
//                    color: Theme.rgba(Theme.highlightColor, 0.2)
//                }
            TabButton{
                icon.source: "image://theme/icon-m-share";
                text:qsTr("Share");
                onClicked: {
                    openShare();
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
                    openBrowser();
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
        color: Theme.colorScheme?Theme.lightSecondaryColor:Theme.darkSecondaryColor
        height: Theme.iconSizeMedium+Theme.paddingMedium*2;
        width: topicPage.width;
        Row{
            TabButton{
                icon.source: "image://theme/icon-m-edit"
                width: (topicPage.width-Theme.iconSizeMedium-Theme.paddingMedium*2)/2
                text:userinfo.logined?qsTr("New post"):qsTr("Login to post")
                onClicked: {
                    if(userinfo.logined){
                        pageStack.push(postComponent, {
                                       "tid":tid,
                                       "parentpage":topicPage,
                                       "replaysTmpModel":topicModel
                                   });
                    }else{
                        pageStack.push(loginDialog);
                        toLoginPage();
                    }

                    toolbar.hideExbar();
                }
            }
            TabButton{
                icon.source: "image://theme/icon-m-refresh"
                width: (topicPage.width-Theme.iconSizeMedium-Theme.paddingMedium*2)/2
                text:qsTr("Refresh");
                onClicked: {
                    load();
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
