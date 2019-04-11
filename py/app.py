"""
Copyright (C) 2018-2019 Nguyen Long.
All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
"""

import os
import traceback
import urllib.parse
import json
import pprint
import pyotherside
from datetime import datetime, timezone, timedelta
from diskcache import Cache

DOMAIN_NAME = 'sailfishos.club'
BASE_URL = 'https://%s' % (DOMAIN_NAME, )
TIMEZONE = timezone(timedelta(hours=2), 'Europe/Helsinki')
HARBOUR_APP_NAME = 'harbour-sailfishclub'
HOME = os.path.expanduser('~')
XDG_DATA_HOME = os.environ.get('XDG_DATA_HOME', os.path.join(HOME, '.local', 'share'))
XDG_CONFIG_HOME = os.environ.get('XDG_CONFIG_HOME', os.path.join(HOME, '.config'))
XDG_CACHE_HOME = os.path.join('XDG_CACHE_HOME', os.path.join(HOME, '.cache'))
COOKIE_PATH = os.path.join(XDG_DATA_HOME, HARBOUR_APP_NAME, HARBOUR_APP_NAME, '.QtWebKit', 'cookies.db')
CACHE_PATH = os.path.join(XDG_CACHE_HOME, HARBOUR_APP_NAME, HARBOUR_APP_NAME)

class Api:
    def __init__(self):
        self.userId = 0
        try:
            if not os.path.exists(CACHE_PATH):
                os.makedirs(CACHE_PATH)
            self.cache = Cache(CACHE_PATH)
        except:
            Utils.log(traceback.format_exc())
            self.cache = None
    def set_query_list_data(self, router='recent', topic={}, expire=3600.00):
        """
        Set recent,popular,etc json string to cache
        """
        try:
            if type(self.cache) is Cache:
                self.cache.set(router, json.dumps(topic), expire = expire)
            return True
        except:
            Utils.log(traceback.format_exc())
            # utils.error('Could not save to cache. Please try again.')

    def get_query_list_data(self, router='recent'):
        """
        Get recent,popular,etc json string in cache
        """
        if type(self.cache) is Cache:
            try:
                return json.loads(self.cache.get(router))
            except:
                Utils.log(traceback.format_exc())
        return None

class Utils:
    def __init__(self):
        pass

    @staticmethod
    def log(str):
        """
        Print log to console
        """

        Utils.send('log', str)

    @staticmethod
    def error(str):
        """
        Send error string to QML to show on banner
        """

        Utils.send('error', str)

    @staticmethod
    def send(event, msg=None):
        """
        Send data to QML
        """

        pyotherside.send(event, msg)

api = Api()
utils = Utils()