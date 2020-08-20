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
            py.newTopic(title.text, comments, userinfo.uid, cid);

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
                var topicData = result.topicData;
                listModel.insert(0,{
                                     "title":topicData.title,
                                     "titleRaw":topicData.titleRaw,
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
        for(var i=0;i<categories.length;i++){
            if(categories[i].parentCid != "0"){
                categories[i].name = "  - " + categories[i].name;
                categories[i].description = "    " + categories[i].description;
            }

            console.log("name:", categories[i].name)
            // Hardcode, because no api
            if(categories[i].name === "公告"||categories[i].name === "新闻"){
                continue;
            }

            categoriesModel.append({
                "cid":  categories[i].cid,
                "name": categories[i].name,
                "description":categories[i].description,
                "icon":categories[i].icon,
                "slug":categories[i].slug,
                "parentCid":categories[i].parentCid
                });
            if(categories[i].children && categories[i].children.length > 0){
                fillModel(categories[i].children);
            }

        }

    }

    Component.onCompleted: {
        py.get_query_from_cache(router_categories, "")
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
