GOOS=linux GOARCH=arm64 go build -tags lambda.norpc -o bootstrap main.go

zip myFunction.zip bootstrap private.key public.cert publicCA.cert

aws lambda create-function --function-name get_server \
--runtime provided.al2023 --handler bootstrap \
--architectures arm64 \
--role arn:aws:iam::xxxxxx:role/service-role/xxxxxx \
--zip-file fileb://myFunction.zip