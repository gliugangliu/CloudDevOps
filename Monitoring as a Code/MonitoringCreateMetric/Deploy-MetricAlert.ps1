Param (
[Parameter(Mandatory=$true)]
[String] $AlertRuleRG,
[Parameter(Mandatory=$true)]
[String] $AlertRuleName,
[Parameter(Mandatory=$true)]
[String] $AlertRuleDescription,
[Parameter(Mandatory=$true)]
[ValidateSet(0,1,2,3,4)]
[Int32] $AlertRuleSeverity,
[Parameter(Mandatory=$true)]
[string] $ActionGroupName,
[Parameter(Mandatory=$true)]
[String] $MonitorScopeLARG,
[Parameter(Mandatory=$true)]
[String] $MonitorScopeLAName,
[Parameter(Mandatory=$true)]
[String] $DimensionName,
[Parameter(Mandatory=$true)]
[String] $DimensionValue,
[Parameter(Mandatory=$true)]
[String] $Signal,
[Parameter(Mandatory=$true)]
[ValidateSet("Average","Maximum","Minimum","Total","Count")]
[String] $TimeAggregation,
[Parameter(Mandatory=$true)]
[ValidateSet("GreaterThan","GreaterThanorEqual","Equal","LessThanorEqual","LessThan")]
[string] $Operator,
[Parameter(Mandatory=$true)]
[Int32] $Threshold,
[Parameter(Mandatory=$true)]
 $AggregationGranularityMins,
[Parameter(Mandatory=$true)]
 $FrequencyMins
)

$ActionGroupid = (Get-AzActionGroup -WarningAction Ignore |  ?{$_.Name -eq "$ActionGroupName"}).Id
$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $MonitorScopeLARG -Name $MonitorScopeLAName -WarningAction Ignore
$TargetResourceScope = $workspace.ResourceId

$DimensionNames = $DimensionName.Split(",")
$DimensionValues = $DimensionValue.Split(",")
$DimensionValueCounts = $DimensionValues.Count
$DimensionNameCounts = $DimensionNames.Count


Remove-Variable -Name AzDimension* -Force -Verbose -ErrorAction SilentlyContinue
Remove-Variable -Name DimensionList -Force -Verbose -ErrorAction SilentlyContinue
Remove-Variable -Name DimensionSelection -Force -Verbose -ErrorAction SilentlyContinue
$DimensionList = New-Object -TypeName 'System.Collections.ArrayList'
If ( ($Dimensionnamecounts -gt 1) -and ($DimensionValueCounts -gt 1) ) {
    [Int32]$i = 0
    [Int32]$LastNum = $DimensionNameCounts - 1
    do {        
 $obj = New-AzMetricAlertRuleV2DimensionSelection -DimensionName $DimensionNames[$i] -ValuesToInclude $DimensionValues[$i] -WarningAction SilentlyContinue -Verbose
 $DimensionList.Add($obj)
    $i = $i + 1
    }
    while ($i -le $LastNum)

$Condition = New-AzMetricAlertRuleV2Criteria -DimensionSelection $DimensionList -MetricName $Signal -MetricNamespace "Microsoft.OperationalInsights/workspaces" -TimeAggregation $TimeAggregation -Operator $Operator -Threshold $Threshold -Verbose -WarningAction SilentlyContinue
}

ELSE {
$DimensionSelection = New-AzMetricAlertRuleV2DimensionSelection -DimensionName $DimensionName -ValuesToInclude $DimensionValue -WarningAction SilentlyContinue -Verbose
 $Condition = New-AzMetricAlertRuleV2Criteria -DimensionSelection $DimensionSelection -MetricName $Signal -MetricNamespace "Microsoft.OperationalInsights/workspaces" -TimeAggregation $TimeAggregation -Operator $Operator -Threshold $Threshold -Verbose -WarningAction SilentlyContinue
}
$AggregationGranularityMins = New-TimeSpan -Minutes $AggregationGranularityMins -Verbose
$FrequencyMins = New-TimeSpan -Minutes $FrequencyMins -Verbose
Add-AzMetricAlertRuleV2 -ResourceGroupName $AlertRuleRG -Name $AlertRuleName -TargetResourceScope $TargetResourceScope -Description $AlertRuleDescription -Severity $AlertRuleSeverity -ActionGroupId $ActionGroupid -WindowSize $AggregationGranularityMins -Frequency $FrequencyMins -Condition $Condition  -TargetResourceType "Microsoft.OperationalInsights/workspaces" -TargetResourceRegion $workspace.Location -Verbose -WarningAction SilentlyContinue