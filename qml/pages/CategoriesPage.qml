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
    //                height: Screen.height/3.5
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
                bannerItem.model = bannerModel;
            }else{

            }

        }
    }

    Component.onCompleted: {
        py.getCategories();
    }
}
