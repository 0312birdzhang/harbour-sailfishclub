import QtQuick 2.0
import Sailfish.Silica 1.0
//import io.thp.pyotherside 1.3

QtObject{
    id:signalcenter;
    signal loadStarted;
    signal loadFinished;
    signal loadFailed(string errorstring);
    signal loginSuccessed;
    signal loginFailed(string fail);
    signal registerSucceed;
    signal registerFailed(string fail);

    signal getRecent(var result);
    signal getTopic(var result);
    signal getCategories(var result);

    signal replayTopic(var result);
    signal replayFloor(var result);
    signal newTopic(var result);
    signal previewMd(var result);
    signal uploadImage(var result, var desc);

    signal loadImage(var result);
    signal getUserInfo(var result);

    signal getUnread(var result);

    signal getSearch(var result);

    signal getUnOfficalList(var result);
    signal getUnOfficalContent(var result);

    signal imageSelected(var url, var desc);

    signal loadUserToken(var result);
}




