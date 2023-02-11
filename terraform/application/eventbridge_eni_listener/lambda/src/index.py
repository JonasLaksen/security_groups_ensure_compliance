import os
import boto3
from datetime import datetime, timezone

resource_groups_tagging_client = boto3.client('resourcegroupstaggingapi')


def handler(event, context):
    detail = event['detail']
    configuration_item = detail['configurationItem']
    changed_properties = detail['configurationItemDiff']['changedProperties']

    is_attached_to_ec2_instance = len(
        [relationship
         for relationship in configuration_item['relationships']
         if relationship['resourceType'] == 'AWS::EC2::Instance'
         and relationship['name'] == 'Is attached to Instance']) > 0

    if is_attached_to_ec2_instance == False:
        print(
            'ENI is not attached to ec2 instance, we dont need to check the security groups')
        return

    try:
        public_ip = configuration_item['configuration']['association']['publicIp']
        print(f'Public ip is {public_ip}')
    except KeyError:
        print('ENI does not have a public ip address. We dont need to check the security groups')
        return

    changed_security_groups = [
        v for k, v in changed_properties.items()
        if k.startswith('Configuration.Groups')]
    newly_attached_security_groups_arns = [
        f"arn:aws:ec2:{os.environ['REGION']}:{os.environ['ACCOUNT_ID']}:security-group/{changed_security_group['updatedValue']['groupId']}"
        for changed_security_group in changed_security_groups
        if changed_security_group['changeType'] == 'CREATE'
    ]

    if len(newly_attached_security_groups_arns) == 0:
        print('No newly attached security groups')
        return

    print(newly_attached_security_groups_arns)
    add_tags_to_security_groups_response = resource_groups_tagging_client.tag_resources(
        ResourceARNList=newly_attached_security_groups_arns,
        Tags={
            'SecurityGroupAttachedToEniAt': datetime.now(timezone.utc).isoformat()
        }
    )

    print(add_tags_to_security_groups_response)
    return add_tags_to_security_groups_response
