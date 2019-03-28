import QtQuick 2.0
import Sailfish.Silica 1.0
//import QtDocGallery 5.0
import harbour.sailfishclub.QtDocGallery 1.0
import harbour.sailfishclub 1.0
import Nemo.Thumbnailer 1.0

Page {
    signal selectImage(string url,string desc)
    allowedOrientations:Orientation.All
    
    DocumentGalleryModel {
        id: galleryModel
        rootType: DocumentGallery.Image
        properties: [ "url", "title", "dateTaken" ]
        autoUpdate: true
        sortProperties: ["-dateTaken"]
    }


    // Gridview with Sailfish Silica specific
    SilicaGridView {
        id: grid
        header: PageHeader { title: qsTr("Select an image") }
        cellWidth: isLandscape? width / 5 : width / 3
        cellHeight: cellWidth
        anchors.fill: parent
        model: galleryModel

        // Sailfish Silica PulleyMenu on top of the grid
        PullDownMenu {
            MenuItem {
                text: qsTr("Latest first")
                onClicked: galleryModel.sortProperties = [ "-dateTaken" ]
            }
            MenuItem {
                text: qsTr("Oldest first")
                onClicked: galleryModel.sortProperties = [ "dateTaken" ]
            }
        }

        delegate: Image {
            asynchronous: true

            // From org.nemomobile.thumbnailer
            source:  "image://nemoThumbnail/" + url

            sourceSize.width: grid.cellWidth
            sourceSize.height: grid.cellHeight

            MouseArea {
                anchors.fill: parent
                onClicked: {
//                    console.log("path:"+url+",title:"+galleryModel.get(index).title)
                    selectImage(url,galleryModel.get(index).title);
                }
            }
        }
        ScrollDecorator {}
    }
}
