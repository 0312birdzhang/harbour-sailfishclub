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

            Item { width: 1; height: 1 }
            Label{
                id:version
                anchors.horizontalCenter: parent.horizontalCenter
                text:qsTr("Version")+" 0.1.4-2"

            }
            Item { width: 1; height: 1 }
            LabelText{
                label: qsTr("Thanks")
                text: qsTr("Thanks nodebb,pynodebb,harbour-storeman,sm.ms and other projects")
            }
            Item{width: 1;height: 1}

            LabelText{
                label: qsTr("About this app")
                text: qsTr("This app is a client for https://sailfishos.club ,an unofficial Chinese community.")
            }
            Item{width: 1;height: 1}
            SectionHeader {
                text: qsTr("Settings")
            }

            Slider {
                id:slider
                value:settings.get_pagesize()
                minimumValue:10
                maximumValue:50
                stepSize: 5
                width: parent.width
                valueText: value
                label: qsTr("Every page size")
            }

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
            settings.set_pagesize(slider.value);
            py.initPagesize();
        }
    }

    
}
