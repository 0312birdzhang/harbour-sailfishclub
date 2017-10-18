#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""pynodebb/api/groups.py

Copyright (c) 2015 David Vuong <david.vuong256@gmail.com>
Licensed MIT
"""
from __future__ import unicode_literals

from pynodebb.api import Resource


class Group(Resource):
    def create(self, slug, name, **kwargs):
        raise NotImplementedError

    def delete(self, slug, **kwargs):
        raise NotImplementedError

    def join(self, slug, uid):
        raise NotImplementedError

    def leave(self, slug, uid):
        raise NotImplementedError
