from __future__ import print_function
import pickle
import os.path
import json
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

# If modifying these scopes, delete the file token.pickle.
# SCOPES = ['https://www.googleapis.com/auth/contacts.readonly']
SCOPES = 'https://www.googleapis.com/auth/contacts'
# CLIENT_SECRET_FILE = r'd:/_MY_DEV/UPWORK/Net Habbit/sample/gdata-python-client/samples/contacts/credentials.json'
# CLIENT_SECRET_FILE = r'D:/_MY_DEV/UPWORK/Net Habbit/credentials.json'
# CLIENT_SECRET_FILE = r'd:/_MY_DEV/UPWORK/Net Habbit/_out/nathabit_creds.json'
CLIENT_SECRET_FILE = r'./nathabit_creds.json'

def main():
    """Shows basic usage of the People API.
    Prints the name of the first 10 connections.
    """
    creds = None
    # The file token.pickle stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists('token.pickle'):
        with open('token.pickle', 'rb') as token:
            creds = pickle.load(token)
            print('1. creds', creds)
            print('1. creds', creds.to_json())
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
            print('2. creds', creds)
            print('2. creds', creds.to_json())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                CLIENT_SECRET_FILE, SCOPES)
            creds = flow.run_local_server(port=0)
            print('3. creds', creds)
            print('3. creds', creds.to_json())
        # Save the credentials for the next run
        with open('token.pickle', 'wb') as token:
            pickle.dump(creds, token)


if __name__ == '__main__':
    main()
