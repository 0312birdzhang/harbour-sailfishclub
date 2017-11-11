import QtQuick 2.0
import Sailfish.Silica 1.0
//import io.thp.pyotherside 1.3

QtObject{
    id:signalcenter;
    signal loadStarted;
    signal loadFinished;
    signal loadFailed(string errorstring);
    signal loginSucceed;
    signal loginSuccessed;
    signal loginFailed(string fail);
    signal registerSucceed;
    signal registerFailed(string fail);

    signal getRecent(var result);
    signal getTopic(var result);
    signal getCategories(var result);
}




