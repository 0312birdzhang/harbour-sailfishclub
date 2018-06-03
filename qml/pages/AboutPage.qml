import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfishclub.settings 1.0
import "../components"

Page{
    id:page
    allowedOrientations:Orientation.All

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: aboutRectangle.height + Theme.paddingLarge * 4

        VerticalScrollDecorator { flickable: flickable }

        Column {
            id: aboutRectangle
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("About")
            }
            Image{
                id:logo
                fillMode: Image.Stretch;
                source:"image://theme/harbour-sailfishclub"
                anchors.horizontalCenter: parent.horizontalCenter;
            }

            Item { width: 1; height: Theme.paddingMedium }
            Label{
                id:version
                anchors.horizontalCenter: parent.horizontalCenter
                text:qsTr("Version")+" 0.2.0"

            }
            Item{width: 1;height: Theme.paddingMedium}

            LabelText{
                label: qsTr("ArtWork")
                text: "Cover跟图标均有设计师<b>蔡司</b>重新制作, 👍"
            }

            Item { width: 1; height: Theme.paddingMedium }
            LabelText{
                label: qsTr("Thanks")
                text: qsTr("Thanks")+ " nodebb,pynodebb,harbour-storeman,orn-warehouse,sm.ms "+qsTr("and other projects") +
                        "<br/><a href=\"https://community.nodebb.org/\" >nodebb</a><br/>" +
                        "<a href=\"https://github.com/davidvuong/pynodebb\" >pynodebb</a><br/>" +
                        "<a href=\"https://github.com/mentaljam/harbour-storeman\" >harbour-storeman</a><br/>" +
                        "<a href=\"https://github.com/custodian/orn-warehouse\" >orn-warehouse</a><br/>" +
                        "<a href=\"https://sm.ms/\" >sm.ms</a><br/>" +
                        "<a href=\"https://github.com/communi/communi-sailfish\" >communi-sailfish</a><br/>";


            }
            Item{width: 1;height: Theme.paddingMedium}

            LabelText{
                label: qsTr("About this app")
                text: qsTr("This app is a client for https://sailfishos.club ,an unofficial Chinese community.")
            }
            Item{width: 1;height: Theme.paddingMedium}

        }

    }

    
}
