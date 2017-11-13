from __future__ import print_function
from pynodebb import Client
import pyotherside
from sfctoken import access_token
import logging
import sys

logger = logging.getLogger("sfcpython")
formatter = logging.Formatter('%(asctime)s %(levelname)-8s: %(message)s')
console_handler = logging.StreamHandler(sys.stdout)
console_handler.formatter = formatter  # 也可以直接给formatter赋值
logger.addHandler(console_handler)
logger.setLevel(logging.DEBUG)

client = Client('https://sailfishos.club', access_token)

def initClient(page_size):
    client.configure(**{
        'page_size': page_size
    })


def login(user, password):
    status_code, userInfo = client.users.login(user, password)
    logger.debug(str(userInfo))
    if not status_code or status_code != 200:
        return False
    return userInfo

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
    return response

def replay(tid,uid,content):
    status_code, response = client.posts.create(uid,tid,content)
    if not status_code or status_code != 200:
        return False
    return response

def getrecent():
    status_code, topics = client.topics.get_recent()
    if not status_code or status_code != 200:
        return False
    return topics

def getpopular():
    status_code, topics = client.topics.get_popular()
    if not status_code or status_code != 200:
        return False
    return topics

def listcategory():
    status_code, categories = client.categories.list()
    if not status_code or status_code != 200:
        return False
    return categories

def getTopic(tid,slug):
    status_code, topic = client.topics.get(tid,slug=slug)
    if not status_code or status_code != 200:
        return False
    return topic



def uploadImgSm(path):
    if path.startswith("file:"):
        path = path.replace("file://","")
    import requests
    import sys
    url = 'https://sm.ms/api/upload'
    try:
        files = {'smfile' : open(path.encode("utf-8"), 'rb')}
        r = requests.post(url, files = files, timeout=5000)
        data1 = eval(r.text.encode('utf-8'))
        smurl = data1['data']['url']
        logger.info(smurl)
        return smurl
    except Exception as e:
        logger.error(str(e))
        return None


def previewMd(text):
    import mistune
    return mistune.markdown(text)
