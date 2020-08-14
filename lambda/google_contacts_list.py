from __future__ import print_function
import os
import logging

from google.oauth2 import credentials as cre

from google_api_helper import GoogleApiHelper


logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, _):
    """Main Lambda handler."""
    logger.info('Got event: %s', event)

    cred = cre.Credentials(event['headers']['google_api_token'])

    google_api = GoogleApiHelper(cred)

    return google_api.get_contact_list(event['queryStringParameters'].get('num'))