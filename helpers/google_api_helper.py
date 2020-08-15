"""Google API helper module"""
import json
from datetime import datetime

from googleapiclient.discovery import build


class GoogleApiHelper:
    """Google API wrapper class"""

    def __init__(self, creds):
        self.service = build('people',
                             'v1',
                             credentials=creds,
                             cache_discovery=False)

    @staticmethod
    def datetime_serializer(obj):
        """Serialize datetime to string"""

        if isinstance(obj, datetime):
            return obj.strftime("%Y-%m-%dT%H:%M:%SZ")

    @staticmethod
    def build_response(status_code, body):
        """Build http response"""

        return {
            "statusCode": status_code,
            'headers': {'Content-Type': 'application/json'},
            "body": json.dumps(body,
                               default=GoogleApiHelper.datetime_serializer)
        }

    def get_contact_list(self, num_items=10):
        """Return a list of contacts"""
        items = {'items': []}

        results = self.service.people().connections().list(
            resourceName='people/me',
            pageSize=num_items,
            personFields='names,emailAddresses').execute()

        connections = results.get('connections', [])

        for person in connections:
            names = person.get('names', [])
            if names:
                name = names[0].get('displayName')
                items['items'].append(name)

        return GoogleApiHelper.build_response(200,
                                              {'google_api_response': items})

    def add_new_contact(self, **kwargs):
        """Add a new contact record"""

        given_name = kwargs.get('givenName')
        family_name = kwargs.get('familyName')
        phone_numbers = kwargs.get('phoneNumbers')
        email_addresses = kwargs.get('emailAddresses')

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

        response = (self.service.people()
                    .createContact(body=new_contact)
                    .execute())

        return GoogleApiHelper.build_response(200,
                                              {'google_api_response': response})
