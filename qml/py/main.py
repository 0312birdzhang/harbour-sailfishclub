from __future__ import print_function
from pynodebb import Client
from token import *

client = Client('https://sailfishos.club', token)
client.configure(**{
  'page_size': 20
})

