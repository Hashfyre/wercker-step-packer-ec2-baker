packer-ec2-baker
================

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
          ami_tag:  "$AMI_TAG_KEY:$AMI_TAG_VALUE"// example: latest:xenial-16-04
          ami_tag_delete: **OPTIONAL** // allowed values: [true | false] // default: false // set to "true", if tag from older AMI is to be deleted
          packer_file: "$PATH_TO_PACKER_JSON_TEMPLATE.json" // packer/base.json // example
```
