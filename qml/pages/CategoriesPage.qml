import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../js/fontawesome.js" as FONT

Page{
    id: page
    property alias contentItem:column
    allowedOrientations:Orientation.All
    objectName: "cateogriesPage"
    ListModel{
        id: bannerModel
    }

    ListModel{
        id: categoriesModel
    }

    Column{
        id:column
        z: -2
        width: page.width
        height: page.height

        SilicaFlickable{
            id: flickable
            PageHeader{
                id: header
                title: qsTr("Categories")
            }
            width: parent.width
            height: parent.height
            clip: true
            contentWidth: width;
            contentHeight: content.height + Theme.itemSizeExtraLarge
            Column{
                id: content
                width: parent.width
                anchors{
                    left: parent.left
                    right: parent.right
                    top:header.bottom
                    margins: Theme.paddingSmall
                }
                spacing: Theme.paddingMedium

                //banner
                ActivityTopicBanner{
                    id:bannerItem
                }

//                Item{
//                    width: parent.width
//                    height: Theme.paddingSmall
//                }

                Repeater{
                    id: listView
                    delegate: ListItem{
                        height: nameLabel.height + descLabel.height
                        width: parent.width
                        Label{
                            id: nameLabel
                            text:  cname + FONT.Icon[icon.replace(/-/g,"_")]
                            color: Theme.primaryColor
                            font.bold:true;
                            font.pixelSize: Theme.fontSizeMedium
                            anchors{
                                leftMargin: Theme.paddingMedium
                            }
                        }
                        Label{
                            id: descLabel
                            text: description
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeTiny
                            anchors{
                                top: nameLabel.bottom
                                leftMargin: Theme.paddingMedium
                            }
                        }
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                pageStack.push(Qt.resolvedUrl("./FirstPage.qml"),{
                                                   "cid":cid,
                                                   "cname":cname + FONT.Icon[icon.replace(/-/g,"_")]
                                               });
                            }
                        }

                    }
                }

            }

            ViewPlaceholder {
                enabled: bannerModel.count === 0 && categoriesModel.count === 0 && !PageStatus.Active
                text: qsTr("Load Failed,Click to retry")
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        py.getCategories();
                    }
                }
            }

            VerticalScrollDecorator{
                flickable: flickable
            }

        }
    }

    Connections{
        target: signalCenter
        onGetCategories:{
            if(result && result != "Forbidden"){
                var banners = result.topics;
                var categories = result.categories;
//                console.log(JSON.stringify(categories))
                for(var i = 0;i<banners.length;i++){
                    bannerModel.append({
                                       "title":banners[i].title,
                                       "user":banners[i].user.username,
                                       "viewcount":banners[i].viewcount,
                                       "postcount":banners[i].postcount,
                                       "latestpost":banners[i].teaser?banners[i].teaser.content:"",
                                       "latestuser":banners[i].teaser?banners[i].teaser.user.username:"",
                                       "tid":banners[i].tid,
                                       "timestamp":banners[i].timestampISO,
                                       "slug":banners[i].slug,
                                       "mainPid":banners[i].mainPid,
                                       "category":banners[i].category.name,
                                       "category_icon":banners[i].category.icon,
                                       "category_bgColor":banners[i].category.bgColor
                                   });
                }
                fillCategoryModel(categories);
                bannerItem.model = bannerModel;
                listView.model = categoriesModel;
            }else{

            }

        }
    }


    function fillCategoryModel(categories){
        for(var i=0;i<categories.length;i++){
            if(categories[i].parentCid != "0"){
                categories[i].name = "   " + categories[i].name;
                categories[i].description = "    " + categories[i].description;
            }
            categoriesModel.append({
                "cid":  categories[i].cid,
                "cname": categories[i].name,
                "description":categories[i].description,
                "icon":categories[i].icon,
                "slug":categories[i].slug,
                "parentCid":categories[i].parentCid
                });
            if(categories[i].children && categories[i].children.length > 0){
                fillCategoryModel(categories[i].children);
            }

        }
    }

    Component.onCompleted: {
        py.getCategories();
    }
}
