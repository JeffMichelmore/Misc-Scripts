<#
This script can be used as a template to make simple API calls to Azure Data Explorer's Run Query API.

# Required Modules
Install-Module -Name Az.Accounts -Force -AllowClobber
Install-Module -Name Az.Resources -Force -AllowClobber
Install-Module -Name Az.Kusto -Force -AllowClobber
Install-Module -Name PowerShellGet -Force -AllowClobber

Az-Context is needed so it may be best to add a check if the AZ modules are installed 
then check if AzContext is populated or Get-AzContext everytime.

$clusterName, $databaseName, and $query must be populated.
#>

# Get the Azure context
# $context = Get-AzContext

# Set the Azure Data Explorer cluster details
$clusterName = ""
$databaseName = ""

# Set the Azure Data Explorer endpoint
$kustoURI = "https://$clusterName.kusto.windows.net"

# Set the query to run
$query = ""

# Get the Azure AD token
$token = Get-AzAccessToken -ResourceUrl $kustoURI -ErrorAction Stop

# Create the authorization header
$header = @{
    "Authorization" = "Bearer $($token.Token)"
}

# Create the request body
$body = @{
    "db" = $databaseName
    "csl" = $query
}

# Invoke the REST API to run the query
$response = Invoke-RestMethod -Uri "$kustoURI/v1/rest/query" -Method Post -Headers $header -Body ($body | ConvertTo-Json) -ContentType "application/json"

# Declare array to hold table values
$TableArray = @()

# Display the response
$table = $response.Tables[0]

foreach ($row in $table.rows) {
    foreach ($columnValue in $row) {
        $TableArray += $columnValue
    }
}

# Set the response data to a CSV
$objects = foreach ($row in $table.rows) {
    $rowData = $row -split "`n" 
    [PSCustomObject]@{
        column1 = $rowData[0]
        column2 = $rowData[1]
        column3 = $rowData[2]
    }
}

$TableCsv = $objects | ConvertTo-Csv -NoTypeInformation 

$OutputCsv = Join-Path $PSScriptRoot "\Data.csv"

Set-Content -Path $OutputCsv -Value $TableCsv -Force
Invoke-Item $OutputCsv