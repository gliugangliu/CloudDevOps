Param (
[Parameter(Mandatory=$false)]
[String] $organization = "azadmhgzl",
[Parameter(Mandatory=$false)]
[String] $projectName = "Chuckweb",
[Parameter(Mandatory=$false)]
[String] $repoName = "ChuckWeb",
[Parameter(Mandatory=$false)]
[String] $ScopePath = "/MetricJson",
[Parameter(Mandatory=$false)]
[String] $token = "vehm7xlazdgge2ajdru7o6tfda7s5hgzefws32a5h6pd32unnzmq"
)
Connect-AzAccount
# Encode the Personal Access Token (PAT) to Base64 String
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "",$token)))
# Construct the download URL
$url = "https://dev.azure.com/$organization/$projectName/_apis/git/repositories/$repoName/items?scopePath=$ScopePath&recursionLevel=Full&api-version=6.0"
$Files = Invoke-RestMethod -Uri $url -Method Get  -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
$Files.value | ForEach-Object {
    if ($_.gitObjectType -eq "blob") {
        $FileURL = $_.url
        $Var = Invoke-RestMethod -Uri $FileURL -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
        & "C:\Users\Cloudscheduler\Desktop\2021-July\Deploy-MetricAlert.ps1" -AlertRuleRG $Var.AlertRuleRG -AlertRuleName $Var.AlertRuleName -AlertRuleDescription $Var.AlertRuleDescription -AlertRuleSeverity $Var.AlertRuleSeverity -ActionGroupName $Var.ActionGroupName -MonitorScopeLARG $Var.MonitorScopeLARG -MonitorScopeLAName $Var.MonitorScopeLAName -DimensionName $Var.DimensionName -DimensionValue $Var.DimensionValue -Signal $Var.Signal -TimeAggregation $Var.TimeAggregation -Operator $Var.Operator -Threshold $Var.Threshold -AggregationGranularityMins $Var.AggregationGranularityMins -FrequencyMins $Var.FrequencyMins
    }
}