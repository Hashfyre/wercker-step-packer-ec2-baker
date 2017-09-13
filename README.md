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
          aws_key: **OPTIONAL** // "$AWS_KEY"
          aws_secret: **OPTIONAL** // "$AWS_SECRET"
          ami_tag:  **OPTIONAL** // "$AMI_TAG_KEY:$AMI_TAG_VALUE"// example: latest:xenial-16-04
          ami_tag_delete: **OPTIONAL** // allowed values: [true | false] // default: false // set to "true", if tag from older AMI is to be deleted
          packer_file: "$PATH_TO_PACKER_JSON_TEMPLATE.json" // packer/base.json // example
```

Optional AWS Creds
------------------
You may not specify `AWS_KEY` & `AWS_SECRET` in the step, however you'll have to
add these two variable in the `wercker` global app environment
or, in the pipeline environment.

Your packer definition would look like:
```
{
    "description": "Builds xenial AMI",
    "variables": {
        "aws_access_key": "{{env `AWS_KEY`}}",
        "aws_secret_key": "{{env `AWS_SECRET`}}",
        "<key>": "{{env `value`}}",
        ...
    },
    ...
}
```
Please go through [Packer/amazon ami builder](https://www.packer.io/docs/builders/amazon.html)
for details on how to write a packer JSON template.

Optional AMI Tag Deletion for Old AMIs
--------------------------------------
In some cases you may want to have an image tagged with a unique sets of:
`<tag-keys>:<tag-values>`, and if you're building a latest version of the same,
the older tag has to be deleted.

In these use-cases, optinally specify:
 - `ami_tag`
 - `ami_vpc_tag`
this'd find out the older ami with the same tag,

Specify:
 - `ami_tag_delete`
to delete the old AMI tags once the new AMI is built.
