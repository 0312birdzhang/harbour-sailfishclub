.pragma library

function humanedate(datestr){
    var _dateline = new Date(datestr).getTime();
    var thatday=new Date(parseInt(_dateline));
    var now=parseInt(new Date().valueOf());
    var cha=(now-_dateline)/1000;
    if(cha<180){
        return "刚刚";
    }else if(cha<3600){
        return Math.floor(cha/60)+" 分钟前";
    }else if(cha<86400){
        return Math.floor(cha/3600)+" 小时前";
    }else if(cha<172800){
        return "昨天 "+Qt.formatDateTime(thatday,"hh")+':'+Qt.formatDateTime(thatday,"mm");
    }else if(cha<259200){
        return "前天 "+Qt.formatDateTime(thatday,"hh")+':'+Qt.formatDateTime(thatday,"mm");
    }else if(cha<345600){
        return Math.floor(cha/86400)+" 天前";
    }else{
        var year = thatday.getFullYear();
        var mon = thatday.getMonth()+1;
        var day = thatday.getDate();
        return year+"-"+(mon<10?('0'+mon):mon)+"-"+(day<10?('0'+day):day)
    }
}

function parse_url(_url){ //定义函数
     var pattern = /(\w+)=(\w+)/ig;//定义正则表达式
     var parames = {};//定义数组
     _url.replace(pattern, function(a, b, c){parames[b] = c;});
    /*这是最关键的.当replace匹配到classid=9时.那么就用执行function(a,b,c);其中a的值为:classid=9,b的值为classid,c的值为9;(这是反向引用.因为在定义
      正则表达式的时候有两个子匹配.)然后将数组的key为classid的值赋为9;然后完成.再继续匹配到id=2;
      此时执行function(a,b,c);其中a的值为:id=2,b的值为id,c的值为2;然后将数组的key为id的值赋为2.
      from:http://blog.csdn.net/openn/article/details/8793457
    */
     return parames;//返回这个数组.
}


// http:&#x2F;&#x2F;birdzhang.xyz to http://birdzhang.xyz
function decodeHTMLEntities(text) {
    var entities = [
        ['amp', '&'],
        ['apos', '\''],
        ['#x27', '\''],
        ['#x2F', '/'],
        ['#39', '\''],
        ['#47', '/'],
        ['lt', '<'],
        ['gt', '>'],
        ['nbsp', ' '],
        ['quot', '"']
    ];

    for (var i = 0, max = entities.length; i < max; ++i) 
        text = text.replace(new RegExp('&'+entities[i][0]+';', 'g'), entities[i][1]);

    return text;
}

var objs = new Object();

objs._privs = {};

objs.save = function(key) {
    var h = key.toString();
    var o = objs._privs[h];
    if (!o) {
        o = {};
        objs._privs[h] = o;
    }
    return o;
}

objs.get = function(key) {
    var h = key.toString();
    return objs._privs[h];
}

objs.remove = function(key) {
    var h = key.toString();
    var o = objs._privs[h];
    if (o !== undefined) {
        delete objs._privs[h];
    }
}
