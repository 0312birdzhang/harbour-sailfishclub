from __future__ import print_function
from pynodebb import Client
from sfctoken import access_token
from sfctoken import secret_key
import logging
import sys
import requests
from cache import *
import wrapcache


logger = logging.getLogger("sfcpython")
formatter = logging.Formatter('%(asctime)s %(levelname)-8s: %(message)s')
console_handler = logging.StreamHandler(sys.stdout)
console_handler.formatter = formatter
logger.addHandler(console_handler)
logger.setLevel(logging.DEBUG)

client = Client('https://sailfishos.club', access_token)
client.configure(**{
    'page_size': 20
})


# def login(user, password):
#     status_code, userInfo = client.users.login(user, password)
#     if not status_code or status_code != 200:
#         return False
#     return userInfo

def login(user, password):
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


def validate(uid, token):
    """validate user token
    """
    status_code, tokens = client.users.get_tokens(uid)
    if not status_code or status_code != 200:
        return False
    if token not in tokens.get("tokens"):
        return False
    else:
        return getuserinfo(uid,False)

def createToken(uid, password):
    status_code, playload = client.users.grant_token(uid, password)
    if not status_code or status_code != 200:
        return False
    return playload.get("token")

@wrapcache.wrapcache(timeout = 600)
def getuserinfo(user,is_username = True):
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
    status_code, response = client.topics.create(uid, cid, title, content)
    if not status_code or status_code != 200:
        return False
    else:
        pass
        # clean wrapcache
        # cache_key = wrapcache.keyof(getrecent, slug) TODO
        # wrapcache.remove(cache_key, adapter = wrapcache.MemoryAdapter)
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

@wrapcache.wrapcache(timeout = 60)
def getrecent(slug):
    status_code, topics = client.topics.get_recent(slug=slug)
    if not status_code or status_code != 200:
        return False
    return topics

@wrapcache.wrapcache(timeout = 600)
def getpopular(slug):
    status_code, topics = client.topics.get_popular(slug=slug)
    if not status_code or status_code != 200:
        return False
    return topics

@wrapcache.wrapcache(timeout = 60)
def listcategory():
    status_code, categories = client.categories.list()
    if not status_code or status_code != 200:
        return False
    return categories

@wrapcache.wrapcache(timeout = 60)
def getTopic(tid, slug, token = access_token ):
    status_code, topic = client.topics.get(tid, slug=slug, **{"_token" : token})
    if not status_code or status_code != 200:
        return False
    return topic

@wrapcache.wrapcache(timeout = 60)
def getNotifications(token):
    status_code, notices = client.topics.get_notification(**{"_token" : token})
    if not status_code or status_code != 200:
        return False
    return notices

@wrapcache.wrapcache(timeout = 60)
def getUnread(token):
    status_code, notices = client.topics.get_unread(**{"_token" : token})
    if not status_code or status_code != 200:
        return False
    return notices


UnOfficalBlogURL = "https://notexists.top/api/post"

@wrapcache.wrapcache(timeout = 600)
def getUnOfficalBlog(page):
    if not page:
        page = 0
    params = {
        "limit": 20,
        "offset": page * 20
    }
    try:
        r = requests.get(UnOfficalBlogURL, params = params, timeout = 5.0)
        return r.json()
    except Exception as e:
        logger.debug(str(e))
    return False

@wrapcache.wrapcache(timeout = 600)
def getUnOfficalBlogContent(slug):
    url = "{}/{}".format(UnOfficalBlogURL, slug)
    try:
        r = requests.get(url, timeout = 5.0)
        return r.json()
    except Exception as e:
        logger.debug(str(e))
    return False




def uploadImgSm(path):
    if path.startswith("file:"):
        path = path.replace("file://","")
    url = 'https://sm.ms/api/upload'
    try:
        files = {'smfile' : open(path.encode("utf-8"), 'rb')}
        r = requests.post(url, files = files, timeout=5.0)
        data1 = eval(r.text.encode('utf-8'))
        smurl = data1['data']['url']
        logger.info(smurl)
        return smurl
    except Exception as e:
        return uploadVimCN(path)

def uploadVimCN(file):
    url = 'http://img.vim-cn.com/'
    try:
        files = {'file' : open(file.encode("utf-8"), 'rb')}
        r = requests.post(url, files = files, timeout=5.0)
        return r.text
    except Exception as e:
        
        logger.error(str(e))
        return None

def previewMd(text):
    import mistune
    return mistune.markdown(text)


@wrapcache.wrapcache(timeout = 1200)
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