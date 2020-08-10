from __future__ import print_function
import pickle
import json
import sys
from datetime import datetime
import os
import boto3
from googleapiclient.discovery import build
from google.oauth2 import credentials as cre


def datetime_serializer(obj):
    """Serialize datetime to string."""
    if isinstance(obj, datetime):
        return obj.strftime("%Y-%m-%dT%H:%M:%SZ")

def build_response(status_code, body):
    """Build http response."""
    return {
        "statusCode": status_code,
        'headers': {'Content-Type': 'application/json'},
        "body": json.dumps(body, default=datetime_serializer)
    }

def lambda_handler(event, _):
    """Main Lambda handler."""
    LOGGER.log.info('X-Forwarded-For: %s, User-Agent: %s',
                    event['headers'].get('X-Forwarded-For', ''),
                    event['headers'].get('User-Agent', ''))


    cred = cre.Credentials(event['headers']['google_api_token'])
    # cred = cre.Credentials(
    #     token=event['token'],
    #     refresh_token=event['refresh_token'],
    #     token_uri=event['token_uri'],
    #     client_id=event['client_id'],
    #     client_secret=event['client_secret'],
    #     scopes=[event['scopes']]
    # )

    given_name = event['queryStringParameters']['givenName']
    family_name = event['queryStringParameters']['familyName']
    phone_numbers = event['queryStringParameters']['phoneNumbers']
    email_addresses = event['queryStringParameters']['emailAddresses']

    new_contact = {
        'names': [{
            'givenName': given_name,
            'familyName': family_name,
        }],
        'phoneNumbers': [
            {
                'value': phone_numbers
            }
        ],
        'emailAddresses': [
            {
                'value': email_addresses
            }
        ]
    }

    service = build('people', 'v1', credentials=cred, cache_discovery=False)
    response = service.people().createContact(body=new_contact).execute()

    return build_response(200, {'google_api_response': response})
