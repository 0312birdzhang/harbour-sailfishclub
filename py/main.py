#!/usr/bin/python3
# -*- coding: utf-8 -*-

from __future__ import print_function
import requests
import http.cookiejar as cookielib
from pynodebb import Client
from sfctoken import access_token,secret_key
import logging
import sys,os
import binascii
import shutil
#from cache import *
from basedir import *
import codecs
import threading

logger = logging.getLogger("sfcpython")
formatter = logging.Formatter('%(asctime)s %(levelname)-8s: %(message)s')
console_handler = logging.StreamHandler(sys.stdout)
console_handler.formatter = formatter
logger.addHandler(console_handler)
logger.setLevel(logging.DEBUG)
UnOfficalBlogURL = "https://notexists.top/api/post"
savePath = os.path.join(HOME, "Pictures","SailfishClub")
max_token_size = 4
siteUrl = 'https://sailfishos.club'

if not os.path.exists(savePath):
    os.mkdir(savePath)

client = Client(siteUrl, access_token)
client.configure(**{
    'page_size': 20,
    'ips': [
            '104.31.87.173',
            '104.31.86.173',
            '172.67.181.63'
            ],
    'domain': 'sailfishos.club'
})

def errMsg(message, code = 400):
    return {
        "code": code,
        "message": message
    }

def login(user, password):
    if not validatePwd(user, password):
        return False
    userinfo = getuserinfo(user)
    if not userinfo:
        logger.error("no such user: %s", user)
        return False
    uid = userinfo.get("uid")
    if not uid:
        logger.error("get uid failed: %s", user)
        return False
    token = createToken(uid, password)
    if not token:
        logger.error("create token failed")
        return False
    logger.debug(token)
    userinfo["token"] = token
    return userinfo
    
def logout(uid, token):
    status_code, response = client.users.remove_token(uid, token)
    if not status_code or status_code != 200:
        return False
    return True


def validate(uid, token, username):
    """
    validate user token
    """
    status_code, tokens = client.users.get_tokens(uid)
    if not status_code or status_code != 200:
        return False
    if token not in tokens.get("tokens"):
        return False
    else:
        return getuserinfo(username)

def validatePwd(user, password):
    sess = requests.Session()
    postData = {
        "username": user,
        "password": password,
        "remember": "on",
        "noscript": False
    }
    resp = sess.post('%s/login' % (siteUrl,), data=postData)
    ret_code = resp.status_code
    if ret_code != 200:
        return False
    return True

def createToken(uid, password):
    status_code, playload = client.users.grant_token(uid, password)
    if not status_code or status_code != 200:
        return False
    token = playload.get("token")
    try:
        threading.Thread(target=remove_oldtokens, args=(uid, token)).start()
    except:
        pass
    return token


def remove_oldtokens(uid, newtoken):
    status_code, tokens = client.users.get_tokens(uid)
    if not status_code or status_code != 200:
        return
    tokenList = tokens.get("tokens")
    if len(tokenList) > max_token_size:
        for oldtoken in tokenList[max_token_size:]:
            if oldtoken == newtoken:
                continue
            client.users.remove_token(uid, oldtoken)


def getuserinfo(user, is_username = True):
    status_code, userinfo = client.users.get(user, is_username)
    if not status_code or status_code != 200:
        return False
    return userinfo

def createUser(user,password,email):
    logger.debug("start register");
    status_code, userInfo = client.users.create(user,**{
        "password":password,
        "email":email
    })
    if not status_code or status_code != 200:
        return False
    else:
        return userInfo

def post(title, content, uid, cid):
    status_code, response = client.topics.create(int(uid), int(cid), title, content)
    if not status_code or status_code != 200:
        return False
    return response

def replay(tid,uid,content):
    status_code, response = client.posts.create(uid,tid,content)
    if not status_code or status_code != 200:
        return False
    return response

def replayTo(tid, uid, toPid, content):
    status_code, response = client.topics.post(tid, uid, toPid, content)
    if not status_code or status_code != 200:
        return False
    return response

def getrecent(slug):
    logger.debug("get recent")
    status_code, topics = client.topics.get_recent(slug=slug)
    logger.debug("got topics")
    if not status_code or status_code != 200:
        return False
    return topics

def getpopular(slug):
    status_code, topics = client.topics.get_popular(slug=slug)
    if not status_code or status_code != 200:
        return False
    return topics

def listcategory():
    status_code, categories = client.categories.list()
    if not status_code or status_code != 200:
        return False
    return categories

def getTopic(tid, slug, token = access_token ):
    status_code, topic = client.topics.get(tid, slug=slug, **{"_token" : token})
    if not status_code or status_code != 200:
        return False
    return topic

def getNotifications(token):
    status_code, notices = client.topics.get_notification(**{"_token" : token})
    if not status_code or status_code != 200:
        return False
    return notices

def getUnread(token):
    status_code, notices = client.topics.get_unread(**{"_token" : token})
    if not status_code or status_code != 200:
        return False
    return notices


def uploadImgQiyu(path):
    """Seems Dead
    """
    domain = "https://img.qiyuos.cn"
    url = '%s/upload' % (domain, )
    try:
        files = {'file' : open(path, 'rb')}
        r = requests.post(url, files = files, timeout=5.0)
        # {"code":200,"msg":"","data":"logo.png"}
        return "%s%s" % (domain, r.json().get("msg"))
    except Exception as e:
        logger.error(str(e))
        return None

def uploadNiuPic(path):
    if path.startswith("file:"):
        path = path.replace("file://","")
    url = 'https://www.niupic.com/index/upload/process'
    headers = {
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36"
    }
    try:
        with codecs.open(path, 'rb') as f:
            files = {'image_field': f.read()}
            r = requests.post(url, files = files, headers = headers, timeout=5.0)
            if r.status_code == 200:
                return "https://%s" %(r.json().get("data"))
            else:
                logger.error(r.text)
    except Exception as e:
        logger.error(str(e))
        return uploadImgQiyu(path)
    return None


def previewMd(text):
    import mistune
    return mistune.markdown(text)


def search(term, slug, token):
    status_code, posts = client.topics.search(term, slug, **{"_token" : token})
    # logger.debug(status_code)
    # logger.debug(str(posts))
    if not status_code or status_code != 200:
        return False
    return posts


def getSecretKey():
    return secret_key

def resizeImg():
    pass

def downloadFile(url, filename):
    readlPath = "%s/%s" % (savePath, url.split('/')[-1])
    try:
        r = requests.get(url, stream=True)
        with open(readlPath, 'wb') as f:
            shutil.copyfileobj(r.raw, f)
    except Exception as e:
        return False
    return True
