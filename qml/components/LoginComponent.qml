import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/main.js" as Script
import io.thp.pyotherside 1.3
Item {
    id:loginComponent

    signal loginSucceed()
    signal loginFailed(string fail)

    Python{
        id:py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../../py')); // adds import path to the directory of the Python script
                py.importModule('main', function () { // imports the Python module
           });
        }
        function login(username,password){
             call('main.login',[username,password],function(result){
                    if(result){

                    }else{
                        loginFailed("登录失败！");
                    }
             })
        }
    }


    SilicaFlickable {
        anchors.fill: parent
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
                        EnterKey.enabled: text || inputMethodComposing
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: password.focus = true
                    }
                    TextField {
                        id:password
                        width:loginComponent.width - Theme.paddingLarge*4
                        height:implicitHeight
                        echoMode: TextInput.Password
                        font.pixelSize: Theme.fontSizeMedium
                        placeholderText: qsTr("Enter Password")
                        label: qsTr("Password")
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: {
                            submitButton.focus = true
                            errorLabel.visible = false;
                            busyIndicator.running = true;
                            Script.app = window
                            Script.logIn(userName.text,password.text)
                        }
                    }
                }
            }
            TextSwitch {
                 text: qsTr("Show Password")
                 onCheckedChanged: {
                     checked ? password.echoMode = TextInput.Normal
                             : password.echoMode = TextInput.Password
                 }
             }
            Button {
                id:submitButton
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Login")
                enabled: userName.text && password.text
                onClicked: {
                    errorLabel.visible = false;
                    busyIndicator.running = true;
//                    Script.app = window
//                    Script.logIn(userName.text,password.text)

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
            onLoginSucceed: {
                errorLabel.visible = false;
                busyIndicator.running = false;
                loginComponent.loginSucceed();
            }
            onLoginFailed: {
                busyIndicator.running = false;
                errorLabel.visible = true;
                errorLabel.text = qsTr("Login fail")+" [ "+fail+" ]. " + qsTr("Please try again.");
            }
        }

    }
}
