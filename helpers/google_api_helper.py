"""Google API helper module"""
import json
import uuid
from datetime import datetime

from googleapiclient.discovery import build

from dynamo_db_helper import DynamoDbHelper


class GoogleApiHelper:
    """Google API wrapper class"""

    def __init__(self, creds, log_table_name=None):
        self.service = build('people',
                             'v1',
                             credentials=creds,
                             cache_discovery=False)
        if log_table_name:
            self.log_table = DynamoDbHelper(log_table_name)

    @staticmethod
    def get_guid():
        """Return the random UID."""
        return str(uuid.uuid4())

    @classmethod
    def datetime_serializer(cls, obj):
        """Serialize datetime to string"""
        if isinstance(obj, datetime):
            return obj.strftime("%Y-%m-%dT%H:%M:%SZ")

    @classmethod
    def build_response(cls, status_code, body):
        """Build http response"""
        return {
            "statusCode": status_code,
            'headers': {'Content-Type': 'application/json'},
            "body": json.dumps(body,
                               default=GoogleApiHelper.datetime_serializer)
        }

    @classmethod
    def build_error_response(cls, error_message, status_code=400):
        """Build error http response"""
        return GoogleApiHelper.build_response(status_code, {'Error': error_message})

    def item_prepare(self, contact):
        """Return the item for the insertion into DynamoDb table"""
        new_item = {}
        new_item['task_id'] = GoogleApiHelper.get_guid()
        new_item['task_ts'] = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
        new_item['item'] = contact
        print('new_item', new_item)
        return new_item

    def save_task(self, contact):
        """Save the info in DB"""
        return self.log_table.put_item(**self.item_prepare(contact))

    def get_contact_list(self, num_items=10):
        """Return a list of contacts"""
        items = {'items': []}

        try:
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
        except Exception as err:
            return GoogleApiHelper.build_error_response(str(err))

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

        try:
            # Save the task
            self.save_task(new_contact)

            # Save in Google Contacts
            response = (self.service.people()
                        .createContact(body=new_contact)
                        .execute())

            return GoogleApiHelper.build_response(200,
                                                  {'google_api_response': response})
        except Exception as err:
            return GoogleApiHelper.build_error_response(str(err))
