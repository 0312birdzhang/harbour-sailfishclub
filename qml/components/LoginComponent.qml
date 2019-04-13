import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfishclub 1.0
import "../js/ApiCore.js" as Api

Item {
    id:loginComponent
    width: parent.width
    height: parent.height


    signal loginSucceed()
    signal loginFailed(string fail)

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge * 2
        BusyIndicator {
            id:busyIndicator
            parent: loginComponent
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
        }

        Column {
            id:column
            anchors{
                top:parent.top
                topMargin: Theme.paddingLarge*4
                horizontalCenter: parent.horizontalCenter
            }

            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Login")
            }

            Rectangle {
                id:rectangle
                width: input.width + Theme.paddingMedium*2
                height: input.height + Theme.paddingMedium*2
                border.color:Theme.highlightColor
                color:"#00000000"
                radius: 30
                Column {
                    id:input
                    anchors{
                        top:rectangle.top
                        topMargin: Theme.paddingMedium
                    }

                    spacing: Theme.paddingMedium

                    TextField {
                        id:userName
                        width:loginComponent.width - Theme.paddingLarge*4
                        height:implicitHeight
                        inputMethodHints:Qt.ImhNoAutoUppercase | Qt.ImhUrlCharactersOnly
                        font.pixelSize: Theme.fontSizeMedium
                        placeholderText: qsTr("Enter UserName/Email")
                        label: qsTr("UserName")
                        text: settings.get_username();
                        EnterKey.enabled: text || inputMethodComposing
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: password.focus = true
                    }


                    PasswordField {
                        id:password
                        width:loginComponent.width - Theme.paddingLarge*4
                        height:implicitHeight
                        font.pixelSize: Theme.fontSizeMedium
                        placeholderText: qsTr("Enter Password")
                        text: {
                            var password = settings.get_password();
                            return Api.decrypt(password, py.getSecretKey());
                        }
                        label: qsTr("Password")
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: {
                            timer.start();
                            submitButton.enabled = false;
                            submitButton.focus = true
                            errorLabel.visible = false;
                            busyIndicator.running = true;
                            py.login(userName.text,password.text);
                        }
                    }
                }
            }

            Button {
                id:submitButton
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Login")
                enabled: userName.text && password.text
                onClicked: {
                    timer.start();
                    submitButton.enabled = false;
                    errorLabel.visible = false;
                    busyIndicator.running = true;
                    py.login(userName.text,password.text);
                }
            }
            Label{
                id:regester
                text:qsTr("Don't have accounts?")
                anchors{
                    right: parent.right
                    rightMargin: Theme.paddingMedium
                }
                font {
                    pixelSize: Theme.fontSizeSmall
                    family: Theme.fontFamilyHeading
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: pageStack.push(Qt.resolvedUrl("../pages/RegisterPage.qml"))
                }
            }
        }

        Label {
            id:errorLabel
            anchors{
                top:column.bottom
                topMargin: Theme.paddingLarge * 2
                bottom: parent.bottom
                bottomMargin: Theme.paddingLarge
                horizontalCenter: parent.horizontalCenter
            }
            width: column.width
            color: Theme.highlightColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.pixelSize: Theme.fontSizeExtraSmall
        }

        Connections {
            target: signalCenter
            onLoginSuccessed: {
                errorLabel.visible = false;
                busyIndicator.running = false;
                loginComponent.loginSucceed();
            }
            onLoginFailed: {
                busyIndicator.running = false;
                errorLabel.visible = true;
                errorLabel.text = qsTr("Login fail")+" [ "+fail+" ]. " + qsTr("Please try again later.");
            }
        }

        Timer{
            id:timer
            interval: 8000;
            running: false;
            onTriggered: {
                submitButton.enabled = true;
            }
        }

        VerticalScrollDecorator{}
    }
}
