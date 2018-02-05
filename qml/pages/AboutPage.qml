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
                text:qsTr("Version")+" 0.1.6-2"

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

//            Button{
//                text:qsTr("Logout")
//                enabled: userinfo.logined
//                visible: enabled
//                anchors.horizontalCenter: parent.horizontalCenter
//                onClicked: {
//                    remorse.execute(qsTr("Start logout..."), function() {
//                        userinfo.logined = false;
//                        userinfo.uid = "";
//                        userinfo.userslug = "";
//                        userinfo.username = "";
//                        userinfo.avatar = "";
//                        userinfo.user_text = "";
//                        py.logout();
//                        toIndexPage();
//                    },3000)

//                }
//            }

        }


        Component.onDestruction: {
//            settings.set_pagesize(slider.value);
//            py.initPagesize();
        }
    }

    
}