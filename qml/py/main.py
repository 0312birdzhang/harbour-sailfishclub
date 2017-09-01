from __future__ import print_function
from pynodebb import Client
from token import *
import pyotherside


client = Client('https://sailfishos.club', token)
client.configure(**{
  'page_size': 20
})



#pyotherside.send('loadStarted')
#pyotherside.send('loadFinished')
#pyotherside.send('loadFailed',str(e))
