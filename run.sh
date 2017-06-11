# name: Create Packer Log
PACKER_LOG=base_`date +%Y%m%d-%H%M%S`.log
echo $PACKER_LOG

# name: Get Last Base AMI
LAST_AMI_ID=`aws ec2 describe-images --query "Images[0].ImageId" --filters "Name=tag:${AMI_TAG_KEY}, Values=$AMI_TAG_VALUE" --output text`
echo "[LAST_AMI_ID: ${LAST_AMI_ID}]"

# name: Bake Base AMI
packer -machine-readable build packer/${PACKER_FILE} | tee ${PACKER_LOG}
PACKER_EXEC_ERROR=${PIPESTATUS[0]}
if [ ${PACKER_EXEC_ERROR} != 0 ]; then exit ${PACKER_EXEC_ERROR}; fi

# name: Delete Latest tag from Last Base AMI
if [ "${LAST_AMI_ID}" != "None" ]; then
  aws ec2 delete-tags --resources $LAST_BASE_AMI_ID --tags "Key=Latest"
fi

# name: Get Current Base AMI
CURR_AMI_ID=`aws ec2 describe-images --query "Images[0].ImageId" --filters "Name=tag:${AMI_TAG_KEY}, Values=$AMI_TAG_KEY" --output text`
echo "[CURR_AMI_ID: ${CURR_AMI_ID}]"
