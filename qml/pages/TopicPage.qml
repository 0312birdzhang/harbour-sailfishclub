import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3
import "../components"
import "../js/ApiCore.js" as JS
import "../js/fontawesome.js" as FONT
Page{
    id:topicPage

    property int tid;
    property string topic_title;
    property string slug;
    property string user;
    property string category_icon;
    property string category;

    property int current_page:1;
    property int pageCount:1;
    property string next_page;
    property bool next_active:false;
    property string prev_page;
    property bool prev_active:false;


    ListModel{
        id:topicModel
    }


    SilicaListView{
        id:topicView
        anchors.fill: parent
        header: PageHeader {
            title: topic_title;
            _titleItem.font.pixelSize: Theme.fontSizeSmall
            description: FONT.Icon[category_icon.replace(/-/g,"_")]  + category;
        }
        spacing: Theme.paddingSmall
        delegate: ListItem {
            contentHeight: topicHeader.height +contentLabel.height + Theme.paddingMedium * 4
            width: topicView.width

            TopicHeader{
                id: topicHeader
                avatar: picture?(siteUrl+picture):""
                user: username
                groupTitle:"" == user_group_name?"":("["+user_group_name+"]")
                index: floor+"#"
                text: user_text
                color: user_color
                time:JS.humanedate(timestamp)
                width: parent.width
                height: parent.width/8
            }

            Label{
                id:contentLabel
                text:formathtml(content)
                textFormat: Text.RichText
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                linkColor:Theme.primaryColor
                font.letterSpacing: 2;
                anchors{
                    top:topicHeader.bottom
                    left:parent.left
                    right:parent.right
                    topMargin: Theme.paddingMedium
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingSmall
//                    bottomMargin: Theme.paddingLarge
                }
            }

            Separator {
                visible:(index > 0?true:false)
                width:parent.width;
                color: Theme.highlightColor
            }
            menu: contextMenu
            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text: qsTr("Replay")
                        onClicked:{
                            pageStack.push(postComponent, {
                                               "tid":tid,
                                               "replayTo":userslug,
                                               "parentpage":topicPage,
                                               "replaysTmpModel":topicModel
                                           });
                            toolbar.hideExbar();
                        }
                    }
                }
            }

        }

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: topicView.count === 0
        }

        footer: Component{

            Item {
                id: loadMoreID
                anchors {
                    left: parent.left;
                    right: parent.right;
                }
                height: Theme.itemSizeMedium
                Row {
                    id:footItem
                    spacing: Theme.paddingLarge
                    anchors.horizontalCenter: parent.horizontalCenter
                    Button {
                        text: qsTr("Prev Page")
                        visible: prev_active
                        onClicked: {
                            current_page--;
                            load();
                        }
                    }
                    Button{
                        text:qsTr("Next Page")
                        visible: next_active
                        onClicked: {
                            current_page++;
                            load();
                        }
                    }
                }
            }

        }

        property int flpy0: 0
        onMovementStarted:{
            flpy0=topicView.contentY;
            toolbar.hideExbar();
        }
        onContentYChanged:{
            if(contentY-flpy0<0){
                toolbar.visible=true
                toolbar.height=toolbar.iheight;
            }else{
                toolbar.height=0;
            }
        }



        ViewPlaceholder {
            enabled: topicView.count == 0 && !PageStatus.Active
            text: qsTr("Empty,Click to retry")
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    load();
                }
            }
        }


    }

    Item{
        id:toolbar
        clip: true;
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
            color: "#08202c"
//            height: (Theme.iconSizeMedium+Theme.paddingMedium*2)*4+4;
            height: Theme.iconSizeMedium+Theme.paddingMedium*2;
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
//                TabButton{//Jump to page-跳转
//                    icon.source: "image://theme/icon-m-rotate-right";
//                    text:qsTr("Jump to page");
//                    onClicked: {
//                        internal.jumpToPage();
//                        toolbar.hideExbar();
//                    }
//                }
//                Rectangle{
//                    width: parent.width;
//                    height: 1;
//                    color: Theme.rgba(Theme.highlightColor, 0.2)
//                }
                TabButton{//Open browser-用浏览器打开本帖
                    icon.source: "image://theme/icon-m-computer"
                    text:qsTr("Open browser");
                    onClicked: {
                        Qt.openUrlExternally(siteUrl+"/topic/"+tid);
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
            width: topicPage.width;
            Row{
                TabButton{
                    icon.source: "image://theme/icon-m-edit"
                    width: (topicPage.width-Theme.iconSizeMedium-Theme.paddingMedium*2)/2
                    text:qsTr("New post");
                    onClicked: {
                        pageStack.push(postComponent, {
                                           "tid":tid,
                                           "parentpage":topicPage,
                                           "replaysTmpModel":topicModel
                                       });
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
    function load(){
        var topicData = py.getTopic(tid,slug+"?page="+current_page);
        if (topicData && topicData != "Forbidden"){
            var posts = topicData.posts;
            var pagination = topicData.pagination;
            current_page = pagination.currentPage;
            pageCount = pagination.pageCount;
            if(pageCount > 1){
                next_page = pagination.next.qs;
                next_active = pagination.next.active;
                prev_page = pagination.prev.qs;
                prev_active = pagination.prev.active;
            }
            topicModel.clear();
            for(var i = 0;i<posts.length; i ++){
                //过滤掉删除的
                if(posts[i].deleted){
                    continue;
                }
                topicModel.append({
                                      "timestamp":posts[i].timestampISO,
                                      "content":posts[i].content,
                                      "uid":posts[i].uid,
                                      "username":posts[i].user.username,
                                      "userslug":posts[i].user.userslug,
                                      "picture":posts[i].user.picture,
                                      "floor":posts[i].index,
                                      "user_group_icon":posts[i].user.selectedGroup?posts[i].user.selectedGroup.icon:"",
                                      "user_group_name":posts[i].user.selectedGroup?posts[i].user.selectedGroup.userTitle:"",
                                      "user_text":posts[i].user["icon:text"],
                                      "user_color":posts[i].user["icon:bgColor"]

                                  });
                topicView.model = topicModel;
            }
            topicView.scrollToTop();
        }else{
            console.log("load failed!!!");
        }
    }

    

    Component{
        id: postComponent
        Dialog  {
            id:dialog
            property string replayTo:"";
            property int tid;
            property ListModel replaysTmpModel
            property Page parentpage;
            canAccept: subcomments.text.length > 2
            acceptDestination: parentpage
            acceptDestinationAction: PageStackAction.Pop
            acceptDestinationProperties:replaysTmpModel
            onAccepted: {

                //replay
                var ret = py.replayTopic(dialog.tid,userinfo.uid,subcomments.text);
                console.log(JSON.stringify(ret));
                if(!ret || ret == "false"){
                    notification.showPopup(qsTr("ReplayError"),JSON.stringify(ret),"image://theme/icon-lock-warning");
                    return;
                }else{
                    replaysTmpModel.append({
                                         "timestamp":ret.timestampISO,
                                         "content":subcomments.text,
                                         "uid":userinfo.uid.toString(),
                                         "username":userinfo.username,
                                         "picture":userinfo.avatar,
                                         "floor":ret.index,
                                         "user_group_icon":userinfo.groupIcon,
                                         "user_group_name":userinfo.groupTitle,
                                         "user_text":userinfo.user_text,
                                         "user_color":userinfo.user_color
                                       })
                }

            }

            Flickable {
                // ComboBox requires a flickable ancestor
                width: parent.width
                height: parent.height
                interactive: false
                anchors.fill: parent
                Column{
                    id: column
                    width: parent.width
                    height: rectangle.height
                    DialogHeader {
                        title:qsTr("Replay")
                    }
                    anchors{
                        //top:dialogHead.bottom
                        left:parent.left
                        right:parent.right
                    }

                    spacing: Theme.paddingLarge
                    Rectangle{
                        id:rectangle
                        width: parent.width-Theme.paddingLarge
                        height: subcomments.height + Theme.paddingLarge
                        anchors.horizontalCenter: parent.horizontalCenter
                        border.color:Theme.highlightColor
                        color:"#00000000"
                        radius: 30

                        TextArea {
                            id:subcomments
                            anchors{
                                top:parent.top
                                topMargin: Theme.paddingMedium
                            }
                            //validator: RegExpValidator { regExp: /.{1,128}/ }
                            width:window.width - Theme.paddingLarge*4
                            height: Math.max(dialog.width/3, implicitHeight)
                            text: "@"+dialog.replayTo+" "
                            font.pixelSize: Theme.fontSizeMedium
                            wrapMode: Text.WordWrap
                            placeholderText: qsTr("markdown is supported")
                            label: qsTr("Comments")
                            focus: true
                        }
                    }

                }


            }
        }

    }

    Component.onCompleted: {
        load();
    }
}
