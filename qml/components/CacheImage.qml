import QtQuick 2.0

import "../js/ApiCore.js" as Api

Image {
    id: root

    property string sourceUncached: ""
    property string __sourceUncached: ""

    Image {
        id: loader
        anchors.centerIn: root
        source: "image://theme/icon-m-refresh"
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        visible: (root.status != Image.Ready && sourceUncached != "")
    }

    onStatusChanged: {
        loader.visible = (root.status != Image.Ready)
        if (root.status == Image.Error) {
            //Error loading
            imageCache.removeUrl(__sourceUncached);
            cacheLoad();
        }
    }

    onSourceUncachedChanged: {
        //console.log("New url arrived: " + sourceUncached + " Old was: " + __sourceUncached);
        //Remove old queue (if any)
        if (__sourceUncached !== "") {
            imageCache.dequeueObject(__sourceUncached,root.toString());
            Api.objs.remove(root);
        }
        //setup new url
        __sourceUncached = sourceUncached;
        //load cached image
        cacheLoad();
    }

    function cacheLoad() {
        if (__sourceUncached !== ""
                && (__sourceUncached.indexOf("http") !== -1
                || __sourceUncached.indexOf("base64://") !== -1 )) {
            //if valid url - queue cache
            Api.objs.save(root).cacheCallback = cacheCallback;
            imageCache.queueObject(__sourceUncached,root.toString());
        } else {
            //just reset source
            source = __sourceUncached;
        }
    }

    Component.onDestruction: {
        //remove queue (if any)
        if (__sourceUncached !== "") {
            //console.log("Dequeue cache for: " + __sourceUncached);
            imageCache.dequeueObject(__sourceUncached,root.toString());
            Api.objs.remove(root);
        }
    }

    function cacheCallback(status, url) {
        //console.log("CacheImage callback: " + url);
        if (status) {
            root.source = url;
        }
    }
}
