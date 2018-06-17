.pragma library

var py;
var app;
// login function
function login(uid, token, username, password){
    if(uid && token){
        py.validate(uid, token)
    }else{
        py.login(username, password)
    }
}


function splitContent(topic_content, parent) {
    var model = Qt.createQmlObject('import QtQuick 2.0; ListModel {}', parent);
    topic_content = app.formathtml(topic_content);
    topic_content = topic_content.replace(/<a[^<>]*href=\"([^<>"]*)\"\s+rel=\"nofollow\"><img\s+src=\"([^<>"]*)\".*?a>/g,"<img src=\"$2\" />"); //去掉图片上的超链接
    topic_content = topic_content.replace(/<img[^<>]*class=\"[^<>]*emoji-emoji-one[^<>]*\"[^<>]*alt=\"([^<>"]*)\"[^<>]*\/>/g,"$1"); // emoji 直接用图片alt中的
    var img_model = [];
    var iframe_model = [];
    var _replace_img_ = "__REPLACE_IMG__";
    var _replace_iframe_ = "__REPLACE_IFRAME__";
    var imgReg = /<img.*?src=\"(.*?)\"/gi;
    var iframeReg = /<iframe.*?src=\"(.*?)\"/gi;

    var srcReg = /src=[\'\"]?([^\'\"]*)[\'\"]?/i;
    var arr_img = topic_content.match(imgReg);
    var arr_iframe = topic_content.match(iframeReg);
    if(!arr_img && !arr_iframe){
        model.append({
            "type": "Text",
            "content": topic_content
        })
        return model;
    }
    for (var i = 0; arr_img && i < arr_img.length; i++) {
        var src = arr_img[i].match(srcReg);
        if(src){
            if(src[1]){
                img_model.push(src[1]);
            }
        }
    }

    for (var i = 0; arr_iframe && i < arr_iframe.length; i++) {
        var src = arr_iframe[i].match(srcReg);
        if(src){
            if(src[1]){
                iframe_model.push(src[1]);
            }
        }
    }

    topic_content = topic_content.replace(/<img.*?src=\"([^<>"]*)\".*?>/g,_replace_img_);

    var contents = topic_content.split(_replace_img_);
    for(var i = 0 ; i < contents.length; i++ ){
        // text 中处理iframe
        var text_content = contents[i];
        var text_contents = text_content.replace(/<iframe.*?src=\"([^<>"]*)\".*?iframe>/g,_replace_iframe_).split(_replace_iframe_);
        for(var j = 0; j < text_contents.length; j++){
            model.append({
                "type": "Text",
                "content": text_contents[j].replace("\\n","<br/>")
            })
            if(text_contents[j].indexOf("embed-responsive") > -1 || text_contents[j].indexOf("video-container") > -1){
                model.append({
                    "type": "Webview",
                    "content": iframe_model[j]
                })
            }else{

            }

        }

        if ( i < contents.length - 1){
            var src = img_model[i];
            if(src.lastIndexOf("gif") > 0){
                model.append({
                    "type": "AnimatedImage",
                    "content": src
                })
            }else{
                model.append({
                    "type": "Image",
                    "content": src
                })
            }

        }
    }
    return model;
}
