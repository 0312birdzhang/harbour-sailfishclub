.pragma library
Qt.include("ApiCore.js")
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
    topic_content = topic_content.replace(/<img[^<>]*class=\"[^<>]*emoji-customizations[^<>]*\"[^<>]*alt=\"([^<>"]*)\"[^<>]*\/>/g,"$1") // 自定义表情
    var img_model = [];
    var iframe_model = [];
    
    var _replace_img_ = "__REPLACE_IMG__";
    var _replace_iframe_ = "__REPLACE_IFRAME__";

    var imgReg = /<img.*?src=\"(.*?)\"/gi;
    var iframeReg = /<iframe.*?src=\"(.*?)\"/gi;
    // var codeReg = /<pre><code>(.*?)<\/code><\/pre>/gi;

    var srcReg = /src=[\'\"]?([^\'\"]*)[\'\"]?/i;
    var arr_img = topic_content.match(imgReg);
    var arr_iframe = topic_content.match(iframeReg);
    
    if(!arr_img && !arr_iframe){
        parseCode(model,topic_content);
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

    for (var ii = 0; arr_iframe && ii < arr_iframe.length; ii++) {
        var srci = arr_iframe[ii].match(srcReg);
        if(srci){
            if(srci[1]){
                iframe_model.push(srci[1]);
            }
        }
    }



    topic_content = topic_content.replace(/<img.*?src=\"([^<>"]*)\".*?>/g,_replace_img_);

    var contents = topic_content.split(_replace_img_);
    for(var iii = 0 ; iii < contents.length; iii++ ){
        // text 中处理iframe
        var text_content = contents[i];
        var text_contents = text_content.replace(/<iframe.*?src=\"([^<>"]*)\".*?iframe>/g,_replace_iframe_).split(_replace_iframe_);
        for(var j = 0; j < text_contents.length; j++){
            var text_contents_tmp = text_contents[j];
            // 处理代码块
            parseCode(model, text_contents_tmp);

            if(text_contents_tmp.indexOf("embed-responsive") > -1 || text_contents_tmp.indexOf("video-container") > -1){
                model.append({
                                 "type": "Webview",
                                 "content": iframe_model[j]
                             })
            }else{

            }

        }

        if ( iii < contents.length - 1){
            var imgsrc = img_model[i];
            if(imgsrc.lastIndexOf("gif") > 0){
                model.append({
                                 "type": "AnimatedImage",
                                 "content": imgsrc
                             })
            }else{
                model.append({
                                 "type": "Image",
                                 "content": imgsrc
                             })
            }

        }
    }
    return model;
}


function parseCode(model, topic_content){
//    console.log("content:",topic_content)
    var codeReg = /<pre><code>.*?[\d\D]*?<\/code><\/pre>/g;
    var _replace_code_ = "__REPLACE_CODE__";
    if(topic_content.indexOf("<code>") > -1 ){
        var codes_model = [];
        var arr_codes = topic_content.match(codeReg);
        for (var ii = 0; arr_codes && ii < arr_codes.length; ii++) {
            var codecontent = arr_codes[ii];
            codecontent = codecontent.replace("<pre>","").replace("<code>","").replace("<\/pre>","").replace("<\/code>","");
            codes_model.push(codecontent);
        }
        var code_contents = topic_content.replace(/<pre><code>.*?[\d\D]*?<\/code><\/pre>/g,_replace_code_).split(_replace_code_);
//        console.log("code_contents length",arr_codes?arr_codes.length:0)
        for(var k = 0; k < code_contents.length; k++){
            model.append({
                             "type": "Text",
                             "content": code_contents[k].replace("\\n","<br/>")
                         })
            if(k <= codes_model.length - 1){
                var codeline = codes_model[k];
                model.append({
                                 "type": "CodeBlock",
                                 "content": decodeHTMLEntities(codeline)
                             })
            }
        }
    }else{
        model.append({
                         "type": "Text",
                         "content": topic_content.replace("\\n","<br/>")
                     })
    }
}
