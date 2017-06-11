newrelic-deployment
===================

Bake an AWS AMI in EC2 using [hashicorp/packer](https://www.packer.io/)


Wercker Box Requirement
-----------------------
[hashfyre/containers:packer](https://github.com/Hashfyre/containers/blob/packer/Dockerfile),
or, any docker box containing the following packages:

- awscli
- packer
- ansible

Example:
--------

```
<your-pipeline-name>:
    box: hashfyre/containers:packer // or any box with necessary packages
    steps:
      - hashfyre/packer-ec2-baker:
          aws_key: "$AWS_KEY"
          aws_secret: "$AWS_SECRET"
          ami_tag_key: latest // example
          ami_tag_value: xenial-16-04 // example
          packer_file: "$PATH_TO_PACKER_JSON_TEMPLATE.json" // packer/base.json // example
```
