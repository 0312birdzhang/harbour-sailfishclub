#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""pynodebb/__init__.py

Copyright (c) 2015 David Vuong <david.vuong256@gmail.com>
Licensed MIT
"""
from __future__ import unicode_literals

# NOTE: Avoid initial import errors.
#
# `setup.py` imports tvm (__version__) before installing dependencies. As a result,
# there are dependencies imported in `pynodebb.client` which may not exist yet.
#
# e.g. `import requests`.
try:
    from pynodebb.client import Client
except ImportError as e:
    print(e)
    Client = None


__version_info__ = (0, 0, 13,)
__version__ = '.'.join(map(str, __version_info__))
