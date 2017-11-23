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
        contentHeight: aboutRectangle.height

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
                text:qsTr("Version")+" 0.1.5"

            }
            Item { width: 1; height: Theme.paddingMedium }
            LabelText{
                label: qsTr("Thanks")
                text: qsTr("Thanks nodebb,pynodebb,harbour-storeman,orn-warehouse,sm.ms and other projects") + 
                        "<style>a:link { color: " + Theme.highlightColor + "; }</style><br/><a href=\"https://community.nodebb.org/\" >nodebb</a><br/>" +
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
//            SectionHeader {
//                text: qsTr("Settings")
//            }

//            Slider {
//                id:slider
//                value:settings.get_pagesize()
//                minimumValue:10
//                maximumValue:50
//                stepSize: 5
//                width: parent.width
//                valueText: value
//                label: qsTr("Every page size")
//            }

            Button{
                text:qsTr("Logout")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    remorse.execute(qsTr("Start logout..."), function() {
                        settings.set_username("");
                        settings.set_password("");
                        userinfo.logined = false;
                        userinfo.uid = "";
                        userinfo.userslug = "";
                        userinfo.username = "";
                        userinfo.avatar = "";
                        userinfo.user_text = "";

                        toIndexPage();
                    },3000)

                }
            }

        }


        Component.onDestruction: {
//            settings.set_pagesize(slider.value);
//            py.initPagesize();
        }
    }

    
}
