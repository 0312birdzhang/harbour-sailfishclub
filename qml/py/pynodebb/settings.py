#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""pynodebb/settings.py

Copyright (c) 2015 David Vuong <david.vuong256@gmail.com>
Licensed MIT
"""
from __future__ import unicode_literals


__all__ = ['settings']

settings = {
    # Default pagination size. This should be the same as the value defined in your ACP.
    'page_size': 20,

    # `nodebb-plugin-write-api` dependency:
    #
    # All requests must be made with a `_uid`. The `_uid` is the id of the user you are
    # impersonating. In the case where a `_uid` isn't provided, an admin `uid` should be
    # used instead. This `uid` represents that admin uid.
    'admin_uid': 1,

    # The URL of your NodeBB instance, defaults to localhost (+ default NodeBB port).
    'api_endpoint': 'http://localhost:4567',

    # The master token used to authenticate write API requests.
    'master_token': None,
}
