"""DynamoDB helper module"""
import boto3
from botocore.exceptions import ClientError

DYNAMO_DB = boto3.resource('dynamodb')


class DynamoDbHelper:
    """DynamoDB wrapper class"""

    def __init__(self, table_name):
        self.table = DYNAMO_DB.Table(table_name)

    def put_item(self, **kwargs):
        resp = None
        try:
            resp = self.table.put_item(
                Item=kwargs
            )
        except ClientError as err:
            if err.response['Error'].get('Code'):
                print('Put operation failed! Error: ',
                      err.response['Error'].get('Message'))
            raise err.response['Error'].get('Message')
        return resp
