
# Technical Assignment

## Task
### Abstract

For this exercise we want you to work on a scenario which comes up quite often – Security Groups are created and attached to EC2 instances. And these SecurityGroups may include ingress that could be considered insecure. Create a Lambda that is deployed with Terraform and executed on SecurityGroup change or attachment and remediate the issue.

Please write a terraform module that includes Lambda(s) for handling this scenario.

### Details

An existing or launched instance should not be allowed to have ingress with 0.0.0.0/0 and port any nor any other specific port.

Any time the security group is modified the Lambda should be called to check the ingress rules of the Security Group and modify the Security group if necessary.

In terraform do the following the following:

* Create event handlers for the events
* Create the lambda deployment
* Add logging in cloudwatch
    
In Python:

* Write the Lambda event handler which is responding to the events
* Check if the CIDR is 0.0.0.0/0
* Remove the rule if it is added
* Write to a predefined SNS Topic for reporting
    
If possible have the lambda remediate on security group being attached to an EC2 instance in a public subnet / with public ip.

## Solution

1. An AWS config rule that listens to all security group changes and uses a lambda to evaluate compliance. Here is the logic:
```
If security group has no `0.0.0.0/0` ingress rules:
	Return COMPLIANT
If security group not attached to an EC2 instance:
	Return COMPLIANT
Else:
	Return NON_COMPLIANT
```

2. A remediation lambda attached to the rule in step 1 that will remove the security group rule containing the `0.0.0.0/0` ingress if the resource is `NON_COMPLIANT` 

3. Also we need a way to trigger the AWS config rule when security groups are attached to the ENI of the EC2 instances. What I did here was to create an EventBridge rule which listens for any ENI change from `aws.config`  and calls another lambda. In this lambda we check to see whether the ENI is attached to an instance, and we identify which security groups were attached. In order to evaluate/remediate these we can trigger the config rule in step 1 and remediate using the lambda in step 2. The way I did this was to add a tag to the security group with the current timestamp in order to trigger the AWS config evaluation/remediation
