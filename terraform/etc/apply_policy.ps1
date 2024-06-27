param (
    [string]$dynamodbArn,
    [string]$roleArn
)

try {
    $policy = @{
        "Version" = "2012-10-17"
        "Statement" = @(
            @{
                "Effect" = "Allow"
                "Principal" = @{
                    "AWS" = $roleArn
                }
                "Action" = "dynamodb:*"
                "Resource" = $dynamodbArn
            }
        )
    } | ConvertTo-Json -Compress

    $command = "aws dynamodb put-resource-policy --resource-arn $dynamodbArn --policy '$policy'"

    Write-Host "Executing command: $command"

    Invoke-Expression $command
}
catch {
    Write-Error "An error occurred: $_"
    exit 1
}
