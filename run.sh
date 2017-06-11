# validate input
if [ ! -n "$WERCKER_PACKER_EC2_BAKER_AWS_KEY" ]; then
  error '[ERROR] Please specify aws_key property'
  exit 1
fi

if [ ! -n "$WERCKER_PACKER_EC2_BAKER_AWS_SECRET" ]; then
  error '[ERROR] Please specify aws_secret property'
  exit 1
fi

if [ ! -n "$WERCKER_PACKER_EC2_BAKER_AMI_TAG" ]; then
  error '[ERROR] Please specify ami_tag property'
  exit 1
fi

if [ ! -n "$WERCKER_PACKER_EC2_BAKER_PACKER_FILE" ]; then
  error '[ERROR] Please specify packer_file property'
  exit 1
fi

# assign input
AWS_KEY=${WERCKER_PACKER_EC2_BAKER_AWS_KEY}
AWS_SECRET=${WERCKER_PACKER_EC2_BAKER_AWS_SECRET}
AMI_TAG=${WERCKER_PACKER_EC2_BAKER_AMI_TAG}
AMI_TAG_DELETE=${WERCKER_PACKER_EC2_BAKER_AMI_TAG_DELETE:-false}
PACKER_FILE=${WERCKER_PACKER_EC2_BAKER_PACKER_FILE}

# derived
AMI_TAG_KEY=${AMI_TAG%:*}
AMI_TAG_VALUE=${AMI_TAG#*:}

if [ ! -n "$AMI_TAG_KEY" ]; then
  error '[ERROR] AMI_TAG_KEY generation failed.'
  exit 1
fi

if [ ! -n "$AMI_TAG_KEY" ]; then
  error '[ERROR] AMI_TAG_VALUE generation failed.'
  exit 1
fi

# export secrets into env
export AWS_KEY
export AWS_SECRET

# Create Packer Log
PACKER_LOG=base_`date +%Y%m%d-%H%M%S`.log
echo $PACKER_LOG

# Get Last Base AMI
if [ "${WERCKER_PACKER_EC2_BAKER_AMI_TAG_DELETE}" == true ]; then
  echo "[AMI-TAG]: ${AMI_TAG_KEY}:${AMI_TAG_VALUE}"
  OLD_AMI_ID=`aws ec2 describe-images --query "Images[0].ImageId" --filters "Name=tag:${AMI_TAG_KEY}, Values=${AMI_TAG_VALUE}" --output text`
  echo "[OLD_AMI_ID: ${OLD_AMI_ID}]"
fi

# Bake Base AMI
packer -machine-readable build ${PACKER_FILE} | tee ${PACKER_LOG}
PACKER_EXEC_ERROR=${PIPESTATUS[0]}

# exit on packer error
if [ ${PACKER_EXEC_ERROR} != 0 ]; then
  error '[ERROR] Packer build failed with ${PACKER_EXEC_ERROR}'
  exit ${PACKER_EXEC_ERROR}
fi

# Delete tag from Last Base AMI
if [ "${WERCKER_PACKER_EC2_BAKER_AMI_TAG_DELETE}" == true ]; then
  if [ "${OLD_AMI_ID}" != "None" ]; then
    aws ec2 delete-tags --resources $OLD_AMI_ID --tags "Key=Latest"
  fi
fi

# Get Current Base AMI
CURR_AMI_ID=`aws ec2 describe-images --query "Images[0].ImageId" --filters "Name=tag:${AMI_TAG_KEY}, Values=${AMI_TAG_VALUE}" --output text`
echo "[AMI-TAG]: ${AMI_TAG_KEY}:${AMI_TAG_VALUE}"
echo "[AMI-ID: ${CURR_AMI_ID}]"
