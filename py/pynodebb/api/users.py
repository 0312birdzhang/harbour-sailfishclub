#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""pynodebb/api/users.py

Copyright (c) 2015 David Vuong <david.vuong256@gmail.com>
Licensed MIT
"""
from __future__ import unicode_literals

from pynodebb.api import Resource


class User(Resource):
    def create(self, username, **kwargs):
        """Creates a new NodeBB user.

        Args:
            username (str): A unique string used to identify the new user.
                If the username already exists, NodeBB will automatically
                append random numbers after `username` to ensure uniqueness.
            **kwargs: All other accepted user properties. You can find out
                what they are by referring to `updateProfile`.

        Returns:
            tuple: Tuple in the form (response_code, json_response)

        """
        kwargs.update({'username': username})
        return self.client.post('/api/v1/users', **kwargs)

    def _update(self, uid, endpoint, **kwargs):
        kwargs.update({'_uid': uid})
        return self.client.put(endpoint, **kwargs)

    def update(self, uid, **kwargs):
        """Updates the user's NodeBB user properties.

        Accepted user properties can be found by referring to `updateProfile`.
        For a quick reference these are the accepted fields:

        username, email, fullname, website, location, birthday, signature

        Args:
            uid (str): The NodeBB uid for the user we are updating.
            **kwargs: A dictionary of user properties we are updating.

        Returns:
            tuple: Tuple in the form (response_code, json_response)

        """
        return self._update(uid, '/api/v1/users/%s' % uid, **kwargs)

    def update_settings(self, uid, **kwargs):
        """Updates the user's NodeBB settings.

        All settings can be updated. They can be found here:
        https://github.com/NodeBB/NodeBB/blob/master/src/user/settings.js#L102-L118

        Args:
            uid (str): The NodeBB uid for the user we are updating.
            **kwargs: A dictionary of settings we are updating.

        Returns:
            tuple: Tuple in the form (response_code, json_response)

        """
        return self._update(uid, '/api/v1/users/%s/settings' % uid, **{
            # NodeBB stores booleans as integers in their Redis instance.
            k: (int(v) if isinstance(v, bool) else v) for k, v in kwargs.iteritems()
        })

    def delete(self, uid):
        """Removes the associated NodeBB user.

        Warning! This operation is irreversible. Note that if `uid` is None
        then, no requests will be made and a 404 will be returned.

        Args:
            uid (str): The NodeBB uid for the user we are deleting

        Returns:
            tuple: Tuple in the form (response_code, json_response)

        """
        return self.client.delete('/api/v1/users/%s' % uid, **{'_uid': uid})

    def change_password(self, uid, new, current=None):
        """Changes the user's password from `current` to `new`.

        If a `master_token` was generated then `current=None` is accepted. However
        if not, the `current` password is required.

        Args:
            uid (str): The NodeBB uid for the user we are changing the pw for.
            new (str): The new password we want to change to.
            current (Optional[str]): The current password we're changing from.

        Returns:
            tuple: Tuple in the form (response_code, json_response)

        """
        payload = {'new': new, 'current': current, '_uid': uid}
        return self.client.put('/api/v1/users/%s/password' % uid, **payload)[0]

    def get(self, id_, is_username=False):
        """Retrieves the NodeBB user given the user's `id_`.

        Fetches for the entire NodeBB user object (only user properties) given the
        `id_`. The `id_` can be the user's uid or username. If the `id_` is
        expected to be a username, `is_username` must be set to `True`.

        Args:
            id_ (str): The NodeBB user's email or username.
            is_username (Optional[bool]): Whether or not the first argument
                is the user's username or not. Defaults to False.

        Returns:
            tuple: Tuple in the form (response_code, json_response)

        """
        return self.client.get(
            ('/api/user/%s' if is_username else '/api/user/uid/%s') % id_
        ) if id_ else (404, 'Not Found')

    def grant_token(self, id_, password ):
        """Creates a new user token for the passed in uid

        """
        return self.client.post(
            '/api/v2/users/%s/tokens' % ( id_ ,) ,**{
                'password': password,
                '_uid': id_
            }
        ) if id_ else (404, 'id_ is need')

    def get_tokens(self, id_ ):
        """Retrieves a list of active tokens for that user
        """
        return self.client.get(
            '/api/v2/users/%s/tokens' % (id_ ,), **{
                "_uid": id_
            }
        )

    def remove_token(self, id_, token):
        """Revokes an active user token
        """
        settings = {
            "master_token": token
        }
        self.client.update_settings(settings)
        return self.client.delete(
            '/api/v2/users/%s/tokens/%s' % (id_, token), **{
                "_uid": id_
            }
        )

    def login(self, username, password):
        """You must install nodebb-plugin-ns-login first

        Simple API endpoint for external login. 
        Special use case: external login check if user's credentials are valid.

        Args:
            username (str): The NodeBB user's email or username.
            password (str): The NodeBB user's password

        Returns:
            Successful login returns user data
            Failure login returns result message
        """
        return self.client.post('api/ns/login', **{'username': username, 'password': password})
