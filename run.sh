# validate input
if [ ! -n "$WERCKER_PACKER_EC2_BAKER_AWS_KEY" ]; then
  error 'Please specify aws_key property'
  exit 1
fi

if [ ! -n "$WERCKER_PACKER_EC2_BAKER_AWS_SECRET" ]; then
  error 'Please specify aws_secret property'
  exit 1
fi

if [ ! -n "$WERCKER_PACKER_EC2_BAKER_AMI_TAG" ]; then
  error 'Please specify ami_tag property'
  exit 1
fi

if [ ! -n "$WERCKER_PACKER_EC2_BAKER_PACKER_FILE" ]; then
  error 'Please specify packer_file property'
  exit 1
fi

# assign input
AWS_KEY=${WERCKER_PACKER_EC2_BAKER_AWS_KEY}
AWS_SECRET=${WERCKER_PACKER_EC2_BAKER_AWS_SECRET}
AMI_TAG=${WERCKER_PACKER_EC2_BAKER_AMI_TAG}
AMI_TAG_KEY=${TAG%:*} # derived
AMI_TAG_VALUE=${TAG#*:} # derived
AMI_TAG_DELETE=${WERCKER_PACKER_EC2_BAKER_AMI_TAG_DELETE:-false}
PACKER_FILE=${WERCKER_PACKER_EC2_BAKER_PACKER_FILE}


# export secrets into env
export AWS_KEY
export AWS_SECRET

# Create Packer Log
PACKER_LOG=base_`date +%Y%m%d-%H%M%S`.log
echo $PACKER_LOG

# Get Last Base AMI
LAST_AMI_ID=`aws ec2 describe-images --query "Images[0].ImageId" --filters "Name=tag:${AMI_TAG_KEY}, Values=$AMI_TAG_VALUE" --output text`
echo "[LAST_AMI_ID: ${LAST_AMI_ID}]"

# Bake Base AMI
packer -machine-readable build packer/${PACKER_FILE} | tee ${PACKER_LOG}

PACKER_EXEC_ERROR=${PIPESTATUS[0]}

# exit on packer error
if [ ${PACKER_EXEC_ERROR} != 0 ]; then
  exit ${PACKER_EXEC_ERROR}
fi

# Delete tag from Last Base AMI
if [ "${WERCKER_PACKER_EC2_BAKER_AMI_TAG_DELETE}" == true ]; then
  if [ "${LAST_AMI_ID}" != "None" ]; then
    aws ec2 delete-tags --resources $LAST_BASE_AMI_ID --tags "Key=Latest"
  fi
fi

# Get Current Base AMI
CURR_AMI_ID=`aws ec2 describe-images --query "Images[0].ImageId" --filters "Name=tag:${AMI_TAG_KEY}, Values=$AMI_TAG_KEY" --output text`
echo "[AMI-TAG]: ${AMI_TAG_KEY}:${AMI_TAG_VALUE}"
echo "[AMI-ID: ${CURR_AMI_ID}]"
