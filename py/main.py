#!/usr/bin/python3
# -*- coding: utf-8 -*-

from __future__ import print_function
import requests
import http.cookiejar as cookielib
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


def getSecretKey():
    return secret_key

def getToken():
    return access_token

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
