import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/fontawesome.js" as FONT

Page{
    id:postPage

    ListModel{
        id:categoryModel
    }

    SilicaFlickable{
        id:filckable
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge * 4
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
                height: Math.max(filckable.width/3, implicitHeight)
                text: ""
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
