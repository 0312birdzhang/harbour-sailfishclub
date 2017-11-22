import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../js/fontawesome.js" as FONT

Page{
    id: page
    property alias contentItem:column
    allowedOrientations:Orientation.All

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
            width: page.width
            height: page.height
            PageHeader{
                id: header
                title: qsTr("Categories")
            }
//            anchors.fill: parent
            contentHeight: content.height + header.height + Theme.paddingLarge
            Item{
                id: content
                width: parent.width
                height: bannerItem.height + Theme.paddingMedium
                anchors.top: header.bottom

                //banner
                ActivityTopicBanner{
                    id:bannerItem
                    anchors.top:parent.top
                    width: parent.width
                }

                SilicaListView{
                    anchors{
                        top: bannerItem.bottom
                        left: parent.left
                        right: parent.right
                    }
                    id: listView
                    clip: true
                    delegate: Label{
                        text: name + " "+ FONT.Icon[icon.replace(/-/g,"_")]
                        
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

            VerticalScrollDecorator{}

        }
    }

    Connections{
        target: signalCenter
        onGetCategories:{
            if(result && result != "Forbidden"){
                var banners = result.topics;
                var categories = result.categories;
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


    function fillCategoryModel(result){
        var categories = result.categories;
        if(!categories || categories == "Forbidden" || categories == "false"){
            return;
        }

        for(var i=0;i<categories.length;i++){
            if(categories[i].parentCid != "0"){
                categories[i].name = "  - " + categories[i].name;
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
                fillCategoryModel(categories[i].children);
            }

        }
    }

    Component.onCompleted: {
        py.getCategories();
    }
}
