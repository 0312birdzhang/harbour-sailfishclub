# -*- coding: utf-8 -*-

"""
certifi.py
~~~~~~~~~~

This module returns the installation location of cacert.pem.
"""
import os

def where():
#    f = os.path.dirname(__file__)
#   hard code
    f = "/usr/share/"

    return os.path.join(f,'harbour-sailfishclub','qml', 'cacert.pem')


if __name__ == '__main__':
    print(where())