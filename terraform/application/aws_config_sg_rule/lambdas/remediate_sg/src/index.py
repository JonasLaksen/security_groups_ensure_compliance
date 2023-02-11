import boto3

ec2_client = boto3.client('ec2')

def revoke_security_group_rules_allowing_all(security_group_id):
    security_group_rules_response = ec2_client.describe_security_group_rules(
        Filters=[{
            'Name': 'group-id',
            'Values': [security_group_id]
        }]
    )
    security_group_ids_allowing_all_ingress = [
        security_group_rule['SecurityGroupRuleId']
        for security_group_rule in security_group_rules_response['SecurityGroupRules']
        if security_group_rule['IsEgress'] == False
        and security_group_rule['CidrIpv4'] == '0.0.0.0/0'
    ]
    return ec2_client.revoke_security_group_ingress(
        GroupId=security_group_id,
        SecurityGroupRuleIds=security_group_ids_allowing_all_ingress
    )

def handler(event, context):
    print(event)

    non_compliant_security_group_ids = [
        record['Sns']['Message']
        for record in event['Records']
    ]

    return [
        revoke_security_group_rules_allowing_all(security_group_id)
        for security_group_id in non_compliant_security_group_ids
    ]
