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

QT += dbus quick

CONFIG += sailfishapp link_pkgconfig

PKGCONFIG += sailfishapp

QMAKE_CXXFLAGS += -Wno-unused-parameter -Wno-psabi
QMAKE_CFLAGS += -Wno-unused-parameter

LIBS += -ldl

# Directories
HARBOUR_LIB_REL = harbour-lib
HARBOUR_LIB_DIR = $${_PRO_FILE_PWD_}/$${HARBOUR_LIB_REL}
HARBOUR_LIB_INCLUDE = $${HARBOUR_LIB_DIR}/include
HARBOUR_LIB_SRC = $${HARBOUR_LIB_DIR}/src


INCLUDEPATH += \
    src \
    $${HARBOUR_LIB_INCLUDE}

SOURCES += src/harbour-sailfishclub.cpp \
            src/settings.cpp \
            src/cache.cpp \
            src/FoilPicsGalleryPlugin.cpp

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
    qml/pages/AboutPage.qml \
    qml/components/TabButton.qml \
    qml/components/TopicToolBar.qml \
    qml/pages/CategoriesPage.qml \
    qml/pages/NotificationsPage.qml \
    qml/components/ActivityTopicBanner.qml \
    qml/js/ApiCore.js \
    qml/js/ApiMain.js \
    qml/cacert.pem \
    qml/pages/TopicPage.qml \
    qml/components/HorizontalFontAwesomeTextButton.qml \
    rpm/harbour-sailfishclub.spec \
    rpm/harbour-sailfishclub.yaml \
    translations/harbour-sailfishclub.ts \
    translations/harbour-sailfishclub-zh_CN.ts \
    harbour-sailfishclub.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-sailfishclub.ts \
                translations/harbour-sailfishclub-zh_CN.ts



RESOURCES += \
    harbour-sailfishclub.qrc




HEADERS += \
    src/settings.h \
    src/cache.h \
    src/FoilPicsGalleryPlugin.h

# harbour-lib
HEADERS += \
    $${HARBOUR_LIB_INCLUDE}/HarbourDebug.h \
    $${HARBOUR_LIB_INCLUDE}/HarbourImageProvider.h \
    $${HARBOUR_LIB_INCLUDE}/HarbourPluginLoader.h \
    $${HARBOUR_LIB_INCLUDE}/HarbourSystemState.h \
    $${HARBOUR_LIB_INCLUDE}/HarbourTask.h \
    $${HARBOUR_LIB_INCLUDE}/HarbourTheme.h \
    $${HARBOUR_LIB_INCLUDE}/HarbourTransferMethodInfo.h \
    $${HARBOUR_LIB_INCLUDE}/HarbourTransferMethodsModel.h \
    $${HARBOUR_LIB_SRC}/HarbourMce.h

SOURCES += \
    $${HARBOUR_LIB_SRC}/HarbourImageProvider.cpp \
    $${HARBOUR_LIB_SRC}/HarbourMce.cpp \
    $${HARBOUR_LIB_SRC}/HarbourPluginLoader.cpp \
    $${HARBOUR_LIB_SRC}/HarbourSystemState.cpp \
    $${HARBOUR_LIB_SRC}/HarbourTask.cpp \
    $${HARBOUR_LIB_SRC}/HarbourTheme.cpp \
    $${HARBOUR_LIB_SRC}/HarbourTransferMethodInfo.cpp \
    $${HARBOUR_LIB_SRC}/HarbourTransferMethodsModel.cpp

DISTFILES += \
    qml/pages/PostPage.qml \
    qml/components/HtmlTagButton.qml \
    qml/components/ImagePreviewGrid.qml \
    qml/components/ShareToPage.qml \
    rpm/harbour-sailfishclub.changes \
    qml/components/ImageHandle.qml \
    qml/components/TextDelegate.qml \
    qml/components/ImageDelegate.qml \
    qml/components/AnimatedImageDelegate.qml \
    qml/components/WebviewDelegate.qml \
    qml/pages/SearchPage.qml \
    qml/components/UnOfficalBlogListComponent.qml \
    qml/pages/UnOfficalCNBlog.qml \
    qml/pages/UnOfficalBlogContent.qml \
    qml/pages/PreviewPage.qml \
    qml/components/ShareMethodList.qml

#dbus.files = dbus/harbour.sailfishclub.service
#dbus.path = $$INSTALL_ROOT/usr/share/dbus-1/services

#INSTALLS += dbus






