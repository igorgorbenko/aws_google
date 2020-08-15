"""Authentication lambda"""
import os
import boto3
import logging
import json
from datetime import datetime

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

COGNITO_REGION = os.environ.get('COGNITO_REGION')
CLIENT_ID = os.environ.get('CLIENT_ID')

boto3.setup_default_session(region_name=COGNITO_REGION)
COGNITO = boto3.client('cognito-idp')


class CognitoAuth:
    """Authentification via AWS Cognito."""

    def __init__(self, username=None, password=None, refresh_token=None):
        self.username = username
        self.password = password
        self.refresh_token = refresh_token

    def initiate_auth(self):
        """Authentification by username/password."""
        try:
            resp = COGNITO.initiate_auth(
                ClientId=CLIENT_ID,
                AuthFlow='USER_PASSWORD_AUTH',
                AuthParameters={
                    'USERNAME': self.username,
                    'PASSWORD': self.password
                    },
                ClientMetadata={
                    'username': self.username,
                    'password': self.password
                    }
                )
        except COGNITO.exceptions.NotAuthorizedException as err:
            return err, 'The username or password is incorrect'
        except COGNITO.exceptions.UserNotFoundException as err:
            return err, 'The username or password is incorrect'
        except Exception as err:
            print(err)
            return err, 'Unknown error'
        return resp, None

    def refresh_auth(self):
        """Authentification by refresh_token."""
        try:
            resp = COGNITO.initiate_auth(
                ClientId=CLIENT_ID,
                AuthFlow='REFRESH_TOKEN_AUTH',
                AuthParameters={
                    'REFRESH_TOKEN': self.refresh_token
                    },
                ClientMetadata={}
                )
        except COGNITO.exceptions.NotAuthorizedException as err:
            return err, 'The username or password is incorrect'
        except COGNITO.exceptions.UserNotFoundException as err:
            return err, 'The username or password is incorrect'
        except Exception as err:
            print(err)
            return err, 'Unknown error'
        return resp, None


def datetime_serializer(obj):
    """Serialize datetime to string"""
    if isinstance(obj, datetime):
        return obj.strftime("%Y-%m-%dT%H:%M:%SZ")


def build_response(status_code, body):
    """Build http response"""
    return {
        "statusCode": status_code,
        'headers': {'Content-Type': 'application/json'},
        "body": json.dumps(body, default=datetime_serializer)
    }


def build_error_response(error_message, status_code=400):
    """Build error http response"""
    return build_response(status_code, {'Error': error_message})


def get_credentials_from_event(event):
    """Get passed credentials from the event."""

    username = event.get('username')
    password = event.get('password')
    refresh_token = event.get('refresh_token')
    return username, password, refresh_token


def lambda_handler(event, context):
    """Lambda authentication entry point."""
    username, password, refresh_token = get_credentials_from_event(event)

    cogn = CognitoAuth(username, password, refresh_token)

    if refresh_token:
        resp, error_message = cogn.refresh_auth()
    elif username and password:
        resp, error_message = cogn.initiate_auth()
    else:
        LOGGER.error('The passed credentials are empty!')
        return build_error_response('The passed credentials are empty!')

    if error_message:
        return build_error_response(error_message)

    response = {
        'id_token': resp['AuthenticationResult'].get('IdToken')
    }

    if password:
        response['refresh_token'] = resp['AuthenticationResult']['RefreshToken']

    return response
