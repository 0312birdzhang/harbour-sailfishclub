import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfishclub 1.0
import "../js/ApiCore.js" as Api

Item {
    id:loginComponent
    width: parent.width
    height: parent.height

    property bool twofactorenabled: false
    signal loginSucceed()
    signal loginFailed(string fail)


    function goto2FAPage(username, password) {
        pageStack.push(Qt.resolvedUrl("2FAPage.qml"),{
                "username": username,
                "password": password
            });
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge * 2
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
                id: rectangle
                width: input.width + Theme.paddingMedium*2
                height: input.height + Theme.paddingMedium*2
                border.color:Theme.highlightColor
                color: "#00000000"
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
                        visible: !twofactorenabled
                        placeholderText: qsTr("Enter UserName/Email")
                        label: qsTr("UserName")
                        text: settings.get_username();
                        EnterKey.enabled: text || inputMethodComposing
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: password.focus = true
                    }


                    PasswordField {
                        id: password
                        width:loginComponent.width - Theme.paddingLarge*4
                        height:implicitHeight
                        font.pixelSize: Theme.fontSizeMedium
                        visible: !twofactorenabled
                        placeholderText: qsTr("Enter Password")
                        // text: {
                        //     var password = settings.get_password();
                        //     return Api.decrypt(password, py.getSecretKey());
                        // }
                        label: qsTr("Password")
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: {
                            if(twofactorenabled){
                                twofactor.focus = true;
                            }else{
                                timer.start();
                                submitButton.enabled = false;
                                submitButton.focus = true
                                errorLabel.visible = false;
                                py.login(userName.text, password.text);
                            }
                        }
                    }

                    TextField {
                        id: twofactor
                        width: loginComponent.width - Theme.paddingLarge*4
                        height: implicitHeight
                        visible: twofactorenabled
                        inputMethodHints: Qt.ImhDigitsOnly
                        font.pixelSize: Theme.fontSizeMedium
                        placeholderText: qsTr("Enter 2FA code")
                        label: qsTr("2FA")
                        EnterKey.enabled: text || inputMethodComposing
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: {
                            timer.start();
                            submitButton.enabled = false;
                            submitButton.focus = true
                            errorLabel.visible = false;
                            py.login(userName.text,password.text, twofactor.text);
                        }
                    }
                }
            }

            Button {
                id:submitButton
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Login")
                enabled: userName.text && password.text && (twofactorenabled?twofactor.text:true)
                onClicked: {
                    timer.start();
                    submitButton.enabled = false;
                    errorLabel.visible = false;
                    py.login(userName.text, password.text, twofactorenabled?twofactor.text:"");
                }
            }
            Label{
                id: regester
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
                    // onClicked: pageStack.push(Qt.resolvedUrl("../pages/RegisterPage.qml"))
                    onClicked: {
                        Qt.openUrlExternally(appwindow.siteUrl+"/register");
                    }
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
                loginComponent.loginSucceed();
            }
            onLoginFailed: {
                errorLabel.visible = true;
                errorLabel.text = qsTr("Login fail")+" [ "+fail+" ]. "
                        + "\n"
                        + qsTr("Please try again later.");
            }
            onLoginTwofactor: {
                // 2fa enabled
                twofactorenabled = true;
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
