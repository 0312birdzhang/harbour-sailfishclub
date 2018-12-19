# -*- coding: utf-8 -*-
import sqlite3
import base64
from basedir import *
import hashlib
import logging
import traceback
try:
    import pyotherside
except:
    pass


__appname__ = "harbour-sailfishclub"
dbPath = os.path.join(XDG_DATA_HOME, __appname__,
                      __appname__, "QML", "OfflineStorage", "Databases")
logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.DEBUG)


def sumMd5(str):
    h = hashlib.md5()
    h.update(str.encode("utf-8"))
    md5name = h.hexdigest()
    return md5name

def getDbname():
    dbname = sumMd5(__appname__)
    return dbPath+"/"+dbname+".sqlite"

def insertDatas(router, data):
    data_encoded = base64.b64encode(data.encode("utf-8"))
    conn = sqlite3.connect(getDbname())
    try:
        cur = conn.cursor()
        cur.execute("INSERT INTO datas(router,jsontext) VALUES (?, ?)",(router,data_encoded))
        conn.commit()
    except Exception as e:
        logging.debug("Insert error")
        logging.debug(str(e))
    finally:
        conn.close()

def initDB():
    conn = sqlite3.connect(getDbname())
    try:
        cur = conn.cursor()
        cur.execute('''CREATE TABLE IF NOT EXISTS datas
                (router text PRIMARY Key, jsontext text) ''')
        conn.commit()
        return True
    except Exception as e:
        logging.debug("error")
        logging.debug(traceback.format_exc())
        return False
    finally:
        conn.close()

def getRecentDatas(router):
    conn = sqlite3.connect(getDbname())
    try:
        cur = conn.cursor()
        cur.execute('SELECT json FROM datas WHERE router = %s ' % router)
        result = cur.fetchone()
        if result:
            return base64.b64decode(result[0])
        else:
            return False
    except Exception as e:
        logging.debug("error")
        logging.debug(traceback.format_exc())
        return False
    finally:
        conn.close()