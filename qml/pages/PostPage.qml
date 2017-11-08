import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/fontawesome.js" as FONT

Dialog  {
    id:postPage
    property ListModel listModel;
    property Page parentpage;
    canAccept: false
    acceptDestination: parentpage
    acceptDestinationAction: PageStackAction.Pop
    acceptDestinationProperties:listModel

    ListModel{
        id:categoryModel
    }

    SilicaFlickable{
        id:filckable
//        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge * 4
        PullDownMenu {
            MenuItem {
                text: qsTr("Post")
                onClicked: {
                    var cid = categoryModel.get(categoryCombo.currentIndex).cid;
                    console.log("cid:"+cid);
                    if(cid && title.text && content.text){
                        var ret = py.newTopic(title.text, content.text, userinfo.uid, cid);
                        console.log(JSON.stringify(ret));
                        if(ret){
                            var topicData = ret.topicData;
                            listModel.append({
                                                 "title":topicData.title,
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
                                                 "category_icon":topicData.category.icon
                                             })
                            postPage.accept();
                        }
                    }else{
                        notification.showPopup(
                                    qsTr("Error"),
                                    qsTr("Field not completed"),
                                    "image://theme/icon-lock-warning"
                                    );
                    }
                    
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
                        model: categoryModel
                        MenuItem {
                            text: name + " "+ FONT.Icon[icon.replace(/-/g,"_")]
                        }
                    }
                }
                description: "This combobox comes with an extra description."
            }


            TextArea {
                id:content
                anchors { left: parent.left; right: parent.right }
                width:window.width - Theme.paddingLarge*4
                height: Math.max(filckable.width/2, implicitHeight)
                // text: ""
                font.pixelSize: Theme.fontSizeMedium
                wrapMode: Text.WordWrap
                placeholderText: qsTr("markdown is supported")
                label: qsTr("Comments")
                focus: true
            }
        }
    }


    Component.onCompleted: {
        var categories = py.getCategories();
        console.log("ret:"+categories)
        if(categories && categories != "Forbidden"){
            for(var i=0;i<categories.length;i++){
                categoryModel.append({
                                       "cid":  categories[i].cid,
                                       "name":categories[i].name,
                                       "description":categories[i].description,
                                       "icon":categories[i].icon,
                                       "slug":categories[i].slug,
                                       "parentCid":categories[i].parentCid

                                     });
            }

        }
    }
}
