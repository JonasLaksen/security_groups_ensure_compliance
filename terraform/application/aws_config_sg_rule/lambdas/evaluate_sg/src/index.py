import boto3
import json
from datetime import datetime

config_client = boto3.client('config')
ec2_client = boto3.client('ec2')


def handler(event, context):
    print(event)
    configuration_item = json.loads(event['invokingEvent'])[
        'configurationItem']

    resource_id = configuration_item['resourceId']
    resource_type = configuration_item['resourceType']
    resource_name = configuration_item['resourceName']
    configuration = configuration_item['configuration']

    def put_evaluation(compliance_type):
        config_client.put_evaluations(
            Evaluations=[{
                'ComplianceResourceId': resource_id,
                'ComplianceResourceType': resource_type,
                'ComplianceType': compliance_type,
                'OrderingTimestamp': datetime.now()
            }],
            ResultToken=event['resultToken']
        )

    def security_group_is_attached_to_ec2_instance():
        response = ec2_client.describe_instances(
            Filters=[{
                'Name': "instance.group-name",
                'Values': [resource_name]
            }]
        )

        ec2_instances_attached_to = sum(
            [[instance['InstanceId'] for instance in reservation['Instances']]
             for reservation in response['Reservations']],
            [])
        return len(ec2_instances_attached_to) > 0

    security_group_allows_all_ips_inbound = any([
        True for permission in configuration['ipPermissions']
        if '0.0.0.0/0' in permission['ipRanges']
    ])

    if security_group_allows_all_ips_inbound == False:
        print(
            f'security_group_allows_all_ips_inbound: {security_group_allows_all_ips_inbound}')
        print('COMPLIANT')
        return put_evaluation('COMPLIANT')

    compliance_type = 'NON_COMPLIANT'\
        if security_group_is_attached_to_ec2_instance()\
        else 'COMPLIANT'

    print(f'compliance_type: {compliance_type}')
    return put_evaluation(compliance_type)
