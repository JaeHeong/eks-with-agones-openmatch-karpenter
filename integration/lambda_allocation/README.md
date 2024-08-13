## Build your lambda go function
```
GOOS=linux GOARCH=arm64 go build -tags lambda.norpc -o bootstrap main.go
```

## Copy your auth files
```
kubectl get secret open-match-tls-server -n open-match -o jsonpath="{.data.public\.cert}" | base64 -d > public.cert
kubectl get secret open-match-tls-server -n open-match -o jsonpath="{.data.private\.key}" | base64 -d > private.key
kubectl get secret open-match-tls-rootca -n open-match -o jsonpath="{.data.public\.cert}" | base64 -d > publicCA.cert
```

## Zip your files to upload to AWS lambda
```
zip myFunction.zip bootstrap private.key public.cert publicCA.cert
```

## Upload your binary to AWS lambda
```
aws lambda create-function --function-name get_server \
--runtime provided.al2023 --handler bootstrap \
--architectures arm64 \
--role arn:aws:iam::xxxxxx:role/service-role/xxxxxx \
--zip-file fileb://myFunction.zip \
--timeout 30
```