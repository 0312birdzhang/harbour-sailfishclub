# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-sailfishclub

CONFIG += sailfishapp

SOURCES += src/harbour-sailfishclub.cpp \
            src/settings.cpp \
    src/cache.cpp

DEFINES += Q_OS_SAILFISH

OTHER_FILES += qml/harbour-sailfishclub.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/Signalcenter.qml \
    qml/pages/NavigationPanel.qml \
    qml/pages/objects/UserInfo.qml \
    qml/pages/objects/TopicInfo.qml \
    qml/js/main.js \
    qml/pages/LoginDialog.qml \
    qml/components/HorizontalIconTextButton.qml \
    qml/components/ImagePage.qml \
    qml/components/LabelText.qml \
    qml/components/TextCollapsible.qml \
    qml/components/Panel.qml \
    qml/components/PanelView.qml \
    qml/pages/RegisterPage.qml \
    qml/components/LoginComponent.qml \
    qml/components/RegisterComponent.qml \
    qml/components/TopicHeader.qml \
    qml/components/FontAvatar.qml \
    qml/components/Avatar.qml \
    qml/components/MaskImage.qml \
    qml/components/CommentField.qml \
    qml/pages/SettingPage.qml \
    qml/components/TabButton.qml \
    qml/components/TopicToolBar.qml \
    qml/pages/CategoriesPage.qml \
    qml/components/ActivityTopicBanner.qml \
    qml/js/ApiCore.js \
    qml/js/ApiMain.js \
    qml/pages/TopicPage.qml \
    qml/components/HorizontalFontAwesomeTextButton.qml \
    rpm/harbour-sailfishclub.spec \
    rpm/harbour-sailfishclub.yaml \
    translations/harbour-sailfishclub-zh_CN.ts \
    harbour-sailfishclub.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-sailfishclub-de.ts \
                translations/harbour-sailfishclub-zh_CN.ts



RESOURCES += \
    harbour-sailfishclub.qrc




HEADERS += \
    src/settings.h \
    src/cache.h

DISTFILES += \
    qml/pages/PostPage.qml \
    qml/components/HtmlTagButton.qml \
    qml/components/ImagePreviewGrid.qml \
    qml/components/ShareToPage.qml \
    rpm/harbour-sailfishclub.changes \
    qml/components/ImageHandle.qml







