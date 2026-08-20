import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/fontawesome.js" as FONT
import "../components"

Dialog  {
    id:postPage

    allowedOrientations: Orientation.Portrait
    objectName: "postPage"

    property ListModel listModel;
    property Page parentpage;
    canAccept: false
    // acceptDestination: parentpage
    acceptDestinationAction: PageStackAction.Pop
    acceptDestinationProperties:listModel

    ListModel{
        id:categoriesModel
    }

    function send(){
        var cid = categoriesModel.get(categoryCombo.currentIndex).cid;
        // console.log(commentfield.children.length)
        var comments = commentfield.children[3].text;

        //  console.log("comments:"+comments);
        if(cid && title.text && comments){
//            console.log(title.text)
//            console.log(comments)
//            console.log(userinfo.uid)
//            console.log(cid);
            api.createTopic(cid, title.text, comments);

        }else{
            appwindow.postdraft = comments;
            notification.showPopup(
                        qsTr("Error"),
                        qsTr("Field not completed"),
                        "image://theme/icon-lock-warning"
                        );
        }

    }

    SilicaFlickable{
        id:filckable
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge * 4
        PullDownMenu {
            
            MenuItem {
                text: qsTr("Recovery from draft")
                visible: appwindow.postdraft || appwindow.post_title_draft
                onClicked: {
                    title.text = appwindow.post_title_draft
                    commentfield.children[3].text = appwindow.postdraft;
                    categoryCombo.currentIndex = appwindow.post_category;
                    appwindow.post_title_draft = "";
                    appwindow.postdraft = "";
                    appwindow.post_category = 0;
                }
            }
            MenuItem {
                text: qsTr("Post")
                onClicked: {
                    send();
                }
            }
        }
        VerticalScrollDecorator {}
        Column{
            id:column
            anchors { left: parent.left; right: parent.right }
            PageHeader {
                id:header
                title: qsTr("New Topic")
            }
            spacing: Theme.paddingMedium

            TextField {
                id: title
                anchors { left: parent.left; right: parent.right }
                label: qsTr("Topic");
                focus: true;
                validator: RegExpValidator { regExp: /.{4,30}/ }
                placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
            }

            ComboBox {
                id:categoryCombo
                anchors { left: parent.left; right: parent.right }
                width: parent.width
                label: qsTr("Categories")
                menu: ContextMenu {
                    Repeater {
                        model: categoriesModel
                        MenuItem {
                            text: name + " "+ FONT.Icon[icon.replace(/-/g,"_")]
                        }
                    }
                }


            }

            CommentField{
                id:commentfield
                onSendButtonClicked: {
                    send();
                }
            }
        }
    }



    Connections{
        target: signalCenter

        onGetCategories:{
            var categories = result.categories;
            if(!categories || categories === "Forbidden" || categories === "false"){
                return;
            }

            fillModel(categories);
        }

        onNewTopic:{
            if(result && (result !== "false" || result !== "Forbidden") ){
                var topicData = result.payload.topicData;
                listModel.insert(0,{
                                     "title":topicData.title,
                                     "titleRaw":topicData.title,
                                     "user":topicData.user.username,
                                     "viewcount":topicData.viewcount,
                                     "postcount":topicData.postcount,
                                     "latestpost":"",
                                     "latestuser":"",
                                     "tid":topicData.tid,
                                     "timestamp":topicData.timestampISO,
                                     "slug":topicData.slug,
                                     "mainPid":topicData.mainPid,
                                     "category":topicData.category.name,
                                     "category_icon":topicData.category.icon,
                                     "isAnswer": false
                                 });
                commentfield.children[3].text = "";
                pageStack.pop();
            }else{
                notification.showPopup(
                        qsTr("Error"),
                        result.toString(),
                        "image://theme/icon-lock-warning"
                        );
            }
        }
    }

    function fillModel(categories){
        // v4.15 returns a flat list; group children under their parent by parentCid
        var byParent = {};
        var roots = [];
        for(var i=0;i<categories.length;i++){
            var c = categories[i];
            // skip the "uncategorised" pseudo category (cid -1)
            if(String(c.cid) === "-1" ||
               String(c.name).indexOf("uncategorized") >= 0){
                continue;
            }
            // Hardcode, because no api
            if(c.name === "公告"||c.name === "新闻"){
                continue;
            }
            var pid = String(c.parentCid);
            if(pid === "0"){
                roots.push(c);
            }else{
                if(!byParent[pid]) byParent[pid] = [];
                byParent[pid].push(c);
            }
        }
        for(var r=0; r<roots.length; r++){
            appendPostCategory(roots[r], byParent, "");
        }
    }

    function appendPostCategory(c, byParent, indent){
        categoriesModel.append({
            "cid":  c.cid,
            "name": indent + c.name,
            "description":indent + c.description,
            "icon":c.icon,
            "slug":c.slug,
            "parentCid":c.parentCid
            });
        var kids = byParent[String(c.cid)];
        for(var k=0; kids && k<kids.length; k++){
            appendPostCategory(kids[k], byParent, indent + "  ");
        }
    }

    Component.onCompleted: {
        appwindow.get_query_from_cache(router_categories, "")
    }

    Component.onDestruction: {
        appwindow.loading = false;
//        console.log(commentfield.children.length)
        appwindow.postdraft = commentfield.children[3].text;
        appwindow.post_title_draft = title.text;
        appwindow.post_category = categoryCombo.currentIndex;
//        console.log(categoryCombo.currentIndex)
    }
}
