Param (
[Parameter(Mandatory=$true)]
[String] $LARG,
[Parameter(Mandatory=$true)]
[String] $LAName,
[Parameter(Mandatory=$true)]
[String] $RuleName,
[Parameter(Mandatory=$true)]
[String] $Description,
[Parameter(Mandatory=$true)]
[string] $Query,
[Parameter(Mandatory=$true)]
[ValidateSet(5,10,15,30,45,60,120,180,240,300,360,1440)]
[Int32] $Frequency,
[Parameter(Mandatory=$true)]
[ValidateSet(5,10,15,30,45,60,120,180,240,300,360,1440,2880)]
[Int32] $Preiod,
[Parameter(Mandatory=$true)]
[Int32] $Threshold,
[Parameter(Mandatory=$true)]
[ValidateSet("Greaterthan","Greaterthanorequal","Equal","Lessthanorequal","Lessthan")]
[string] $Operator,
[Parameter(Mandatory=$true)]
[string] $ActionGroup,
[Parameter(Mandatory=$true)]
[string] $EmailSubject,
[Parameter(Mandatory=$true)]
[ValidateSet(0,1,2,3,4)]
[Int32] $Severity
)

$ActionGroupid = (Get-AzActionGroup -WarningAction Ignore |  ?{$_.Name -eq "$ActionGroup"}).Id
$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $LARG -Name $LAName -WarningAction Ignore
$workspaceId = $workspace.ResourceId
$location = $workspace.Location
$RG = $workspace.ResourceGroupName

$source = New-AzScheduledQueryRuleSource -Query $Query -DataSourceId $workspaceId -QueryType "ResultCount"   -Verbose  -WarningAction Ignore         				
$schedule = New-AzScheduledQueryRuleSchedule -FrequencyInMinutes $Frequency -TimeWindowInMinutes $Preiod  -Verbose -WarningAction Ignore
$TriggerCondition = New-AzScheduledQueryRuleTriggerCondition -Threshold $Threshold -ThresholdOperator $Operator -Verbose -WarningAction Ignore
$aznsActionGroup = New-AzScheduledQueryRuleAznsActionGroup -ActionGroup @("$ActionGroupid") -EmailSubject "$EmailSubject" -Verbose -WarningAction Ignore
$alertingAction = New-AzScheduledQueryRuleAlertingAction -AznsAction $aznsActionGroup -Severity $Severity -Trigger $triggerCondition
New-AzScheduledQueryRule -Source $source -Schedule $schedule -Action $alertingAction -Location $location -Description $Description -Name $RuleName -ResourceGroupName $RG -Enabled $true -WarningAction Ignore -Verbose