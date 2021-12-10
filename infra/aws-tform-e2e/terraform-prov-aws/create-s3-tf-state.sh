S3_NAME="$(basename $PWD)-tfstate"

sed -i "/bucket = /s/\".*\"/\"${S3_NAME}\"/" backend.tf

aws s3api create-bucket --bucket ${S3_NAME} --region us-east-1

if [[ $? -eq 0 ]]; then
    echo -e "S3 Bucket Created with name: ${S3_NAME}\n\n"
else
    echo -e "Error. Check Logs bellow"
fi
