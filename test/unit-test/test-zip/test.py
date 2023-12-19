import sys


def lambda_handler(event, context):
    return 'Hello from AWS Lambda using Python' + sys.version + '!'
