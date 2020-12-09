import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.5
import "../components"
import "../js/ApiCore.js" as JS
import "../js/fontawesome.js" as FONT
Page{
    id:topicPage
    objectName: "TopicPage"
    property int tid;
    property string topic_title: "";
    property string slug;
    property string user;
    property string category_icon;
    property string category: "";

    property int current_page:1;
    property int pageCount:1;
    property string next_page;
    property bool next_active:false;
    property string prev_page;
    property bool prev_active:false;


    allowedOrientations: Orientation.Portrait

    ListModel{
        id: topicModel
    }



    SilicaListView{
        id:topicView
        anchors.fill: parent
        enabled: PageStatus.Active
        header: PageHeader {
            title: topic_title?JS.decodeHTMLEntities(topic_title):"";
            _titleItem.font.pixelSize: Theme.fontSizeSmall
            description: category? (FONT.Icon[category_icon.replace(/-/g,"_")]  + category) : "";
        }
        delegate: ListItem {
            enabled: !isAnswer
            contentHeight: topicHeader.height + contentLabel.height
                        + signatureLabel.height + topicRepliesId.height
                        + Theme.paddingMedium * 4
                        + (contextMenu.active?contextMenu.height:0)

            width: topicView.width

            TopicHeader{
                id: topicHeader
                avatar: appwindow.getPicture(picture)
                user: username
                user_id: uid
                groupTitle:"" == user_group_name?"":("["+user_group_name+"]")
                index: isAnswer?FONT.Icon.fa_check_circle:(floor + 1 )+"#"
                text: user_text
                color: user_color
                time: JS.humanedate(timestamp)
                width: parent.width
                height: isLandscape?parent.width/12:parent.width/8
            }



            Column{
                id: contentLabel
                width: parent.width;
                spacing: Theme.paddingSmall
                anchors.top: topicHeader.bottom;
                anchors.topMargin: Theme.paddingMedium;
                Repeater {
                    model: splitContent(content, topicView)
                    Loader {
                        anchors {
                            left: parent.left; right: parent.right;
                            margins: Theme.paddingSmall;
                        }
                        source: Qt.resolvedUrl("../components/" +type + "Delegate.qml");
                    }
                }
            }

            Rectangle {
                id: subject
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                color: "#1affffff"
                radius: 5;
                visible: isAnswer
            }
            

            TopicReplies{
                id: topicRepliesId
                replies: userReplies
                visible: userReplies || userReplies.hasMore
                width: parent.width;
                height: Theme.itemSizeExtraSmall/2
                anchors.top: contentLabel.bottom
                anchors.leftMargin: Theme.paddingMedium
            }

            Label{
                id: signatureLabel
                anchors{
                    top: topicRepliesId.bottom
                    right: parent.right
                    rightMargin: Theme.paddingMedium
                }
                color: parent.highlighted ? Theme.secondaryColor : Theme.highlightColor
                horizontalAlignment: Text.AlignRight
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall * 0.8
                font.italic: true
                text: signature||""
                visible: signature||false
                onLinkActivated: {
                    appwindow.openLink(link)
                }
            }


            Separator {
                visible:(index > 0?true:false)
                width:parent.width;
                color: Theme.secondaryHighlightColor
            }
            menu: contextMenu
            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text: userinfo.logined ? qsTr("Replay") :qsTr("Login to replay")
                        onClicked:{
                            if(userinfo.logined){
                                pageStack.push(postComponent, {
                                               "tid":tid,
                                               "replayTo":"@"+userslug+" ",
                                               "pid":pid,
                                               "parentpage":topicPage,
                                               "replaysTmpModel":topicModel
                                           });
                            }else{
                                toLoginPage();
                            }

                            toolbar.hideExbar();
                        }
                    }
                    // MenuItem{
                    //     text: qsTr("Copy")
                    //     onClicked: {
                    //         Clipboard.text = contentLabel.text;
                    //         notification.show(qsTr("Copied!"))
                    //     }
                    // }
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

    TopicToolBar{
        id:toolbar
        onOpenBrowser:{
            Qt.openUrlExternally(siteUrl+"/topic/"+tid);
        }
        onOpenShare:{
            pageStack.push(Qt.resolvedUrl("../components/ShareToPage.qml"),{
                "link":siteUrl+"/topic/"+tid,
                "linkTitle":topic_title
            })
        }

    }

    Connections{
        target: signalCenter
        onGetTopic:{
            var topicData = result;
            console.log(result)
            if (topicData && topicData != "Forbidden"){
                var posts = topicData.posts;
                var pagination = topicData.pagination;
                current_page = pagination.currentPage;
                pageCount = pagination.pageCount;
                topic_title = topicData.title;
                slug = topicData.slug;
                category = topicData.category.name;
                category_icon = topicData.category.icon;

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
                    console.log("avatar:"+posts[i].user.picture)
                    topicModel.append({
                                          "timestamp":posts[i].timestampISO,
                                          "content":posts[i].content,
                                          "signature":posts[i].user.signature?posts[i].user.signature:"",
                                          "uid":posts[i].uid.toString(),
                                          "pid":posts[i].pid,
                                          "username":posts[i].user.username,
                                          "userslug":posts[i].user.userslug,
                                          "picture":posts[i].user.picture||"",
                                          "floor":posts[i].index,
                                          "user_group_icon":posts[i].user.selectedGroup?posts[i].user.selectedGroup.icon:"",
                                          "user_group_name":posts[i].user.selectedGroup?posts[i].user.selectedGroup.userTitle:"",
                                          "user_text":posts[i].user["icon:text"],
                                          "user_color":posts[i].user["icon:bgColor"],
                                          "userReplies": posts[i].replies,
                                          "isAnswer": posts[i].index == -1

                    });
                }
                topicView.model = topicModel;
                topicView.scrollToTop();
            }else{
                console.log("load failed!!!", result);
                appwindow.loading = false;
                notification.show(qsTr("Load failed,try again later"),
                                  "image://theme/icon-lock-warning"
                                  )
            }
        }
    }

    function load(force_refresh){
        console.log("slug:", slug?slug+"?page="+current_page:undefined,", tid:"+tid)
//        if(force_refresh){
            py.getTopic(tid,slug?slug+"?page="+current_page:undefined);
//        }else{
//            py.get_query_from_cache(appwindow.router_topic,
//            slug?slug+"?pa/*ge="+current_page:undefined,
//            tid)
//        }
    }

    

    Component{
        id: postComponent
        Dialog  {
            id:dialog
            orientation: Orientation.All
            property string replayTo:"";
            property string tid;
            property string pid;

            property ListModel replaysTmpModel
            property Page parentpage;
            canAccept: false
            acceptDestination: parentpage
            acceptDestinationAction: PageStackAction.Pop
            acceptDestinationProperties:replaysTmpModel

            onRejected: {
                var tmpdraft = commentField.children[3].text;
                // @birdzhang test to test
                if(tmpdraft){
                    tmpdraft = tmpdraft.replace(/\@\w+\s/m,"");
                }else{
                    tmpdraft = "";
                }
                appwindow.topicdraft = tmpdraft;
            }

            SilicaFlickable {
                // ComboBox requires a flickable ancestor
                width: parent.width
                height: parent.height
                anchors.fill: parent
                contentHeight: column.height + Theme.paddingLarge * 2
                Column{
                    id: column
                    width: parent.width
                    height: commentField.height
                    DialogHeader{
                         acceptText: ""
                    }
                    anchors{
                        //top:dialogHead.bottom
                        left:parent.left
                        right:parent.right
                    }

                    spacing: Theme.paddingLarge

                    CommentField{
                        id: commentField
                        replayUser: replayTo
                        _replyToId: tid;
                        onSendButtonClicked: {
                            var subcomments = commentField.children[3].text;
                            //replay
                            if(pid){
                                py.replayFloor(dialog.tid, pid, subcomments);
                            }else{
                                py.replayTopic(dialog.tid, subcomments);
                            }

                        }
                    }

                }

            }

            Connections{
                target: signalCenter
                onReplayFloor:{
                    replayCallback(result);
//                    topicPage.load(true);
                }
                onReplayTopic:{
                    replayCallback(result);
//                    topicPage.load(true);
                }
            }

            function replayCallback(result){
                if(!result || result.code !== "ok"){
                    notification.showPopup(qsTr("ReplayError"),JSON.stringify(ret),"image://theme/icon-lock-warning");
                }else{
                    console.log(result)
                    var ret = result.payload;
                    replaysTmpModel.append({
                                         "timestamp":ret.timestampISO,
                                         "content":ret.content,
                                         "uid":userinfo.uid.toString(),
                                         "username":userinfo.username,
                                         "picture":userinfo.avatar||"",
                                         "floor":ret.index,
                                         "user_group_icon":userinfo.groupIcon,
                                         "user_group_name": (ret.user && ret.user.selectedGroup)?
                                                                ret.user.selectedGroup:"",
                                         "user_text":userinfo.user_text,
                                         "user_color":userinfo.user_color,
                                         "userReplies": ret.replies || {},
                                         "isAnswer": false
                                       });
                    pageStack.pop();
                }
            }
        }

    }

    Component{
        id:loginDialog
        LoginDialog{
            anchors.fill: parent
            onAccepted: {
                pageStack.pop();
            }
        }
    }

    Component.onCompleted: {
        load();
    }
    Component.onDestruction: {
        appwindow.topicdraft = "";
        appwindow.loading = false;
    }
}
