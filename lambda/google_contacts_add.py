from __future__ import print_function
import os
import logging

from google.oauth2 import credentials as cre

from google_api_helper import GoogleApiHelper

LOG_TABLE_NAME = os.environ.get('LOG_TABLE_NAME')

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)


def lambda_handler(event, _):
    """Main Lambda handler."""
    LOGGER.info('Got event: %s', event)

    cred = cre.Credentials(event['headers'].get('google_api_token'))

    try:
        google_api = GoogleApiHelper(cred, LOG_TABLE_NAME)
    except Exception as err:
        return GoogleApiHelper.build_error_response('Please, check the google API credentials!', str(err))

    return google_api.add_new_contact(**event['queryStringParameters'])
