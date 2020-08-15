from __future__ import print_function
import logging

from google.oauth2 import credentials as cre

from google_api_helper import GoogleApiHelper


LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)


def lambda_handler(event, _):
    """Main Lambda handler."""
    LOGGER.info('Got event: %s', event)

    cred = cre.Credentials(event['headers']['google_api_token'])

    google_api = GoogleApiHelper(cred)

    return google_api.add_new_contact(**event['queryStringParameters'])
