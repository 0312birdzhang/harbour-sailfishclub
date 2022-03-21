#!/usr/bin/python3
# -*- coding: utf-8 -*-

from __future__ import print_function
import requests
import http.cookiejar as cookielib
import logging
import sys,os
import binascii
import shutil
#from cache import *
from basedir import *
from config import DOMAIN_NAME
import codecs
import threading

logger = logging.getLogger("sfcpython")
formatter = logging.Formatter('%(asctime)s %(levelname)-8s: %(message)s')
console_handler = logging.StreamHandler(sys.stdout)
console_handler.formatter = formatter
logger.addHandler(console_handler)
logger.setLevel(logging.DEBUG)
savePath = os.path.join(HOME, "Pictures","SailfishClub")
max_token_size = 4
# siteUrl = 'https://sailfishos.club'
siteUrl = "https://%s" % (DOMAIN_NAME,)

if not os.path.exists(savePath):
    os.mkdir(savePath)

def errMsg(message, code = 400):
    return {
        "code": code,
        "message": message
    }


def logout(uid, token):
    return True


def validate(uid, token, username):
    return True


def uploadImgQiyu(path):
    domain = "http://159.75.45.226"
    url = '%s:8082/upload' % (domain, )
    visturl = '%s:8083' % (domain, )
    try:
        files = {'file' : open(path, 'rb')}
        r = requests.post(url, files = files, timeout=5.0)
        # {"code":200,"msg":"","data":"logo.png"}
        return "%s%s" % (visturl, r.json().get("msg"))
    except Exception as e:
        logger.error(str(e))
        return None

def uploadNiuPic(path):
    if path.startswith("file:"):
        path = path.replace("file://","")
    url = 'https://catbox.moe/user/api.php'
    headers = {
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36"
    }
    try:
        with codecs.open(path, 'rb') as f:
            files = { 
                'fileToUpload': f.read()
            }
            datas = {
                'reqtype': 'fileupload'
            }
            r = requests.post(url, data = datas, files= files, headers = headers, timeout=10.0)
            if r.status_code == 200:
                return  r.text
            else:
                logger.error(r.text)
    except Exception as e:
        logger.error(str(e))
    return None


def previewMd(text):
    import mistune
    return mistune.markdown(text)


def getSecretKey():
    return "keyskeyskeyskeys"


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

if __name__ == "__main__":
    print(uploadNiuPic("C:\\Users\\99188\\Pictures\\volte-sfos.jpg"))