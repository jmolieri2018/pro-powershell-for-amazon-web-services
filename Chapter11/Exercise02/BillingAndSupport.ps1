$Policy = @"
{
 "Statement": [
   {
    "Action": [
    	"aws-portal:ViewBilling",
       "aws-portal:ViewUsage"
    ],
    "Effect": "Allow",
    "Resource": "*"
   }
  ]
}
"@

New-IAMGroup -GroupName "BILLING"
Write-IAMGroupPolicy -GroupName "BILLING" -PolicyName "BILLING-BillingAndUsage" -PolicyDocument $Policy

$Policy = @"
{
 "Statement": [
   {
    "Action": "support:*",
    "Effect": "Allow",
    "Resource": "*"
   }
  ]
}
"@

New-IAMGroup -GroupName "SUPPORT"
Write-IAMGroupPolicy -GroupName "SUPPORT" -PolicyName "SUPPORT-FullAccess" -PolicyDocument $Policy
