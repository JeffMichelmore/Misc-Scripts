<# 
This script takes the file path to the system event log as input and filters for DNS Warning, Error, and Critical events then outputs to CSV.
The default system log location can be substituted for the parameter
"%SystemRoot%\System32\winevt\Logs\System.evtx"
#>
param (
    [string]$systemLogPath
)

# Check if the folder path is provided as a parameter
if (-not $systemLogPath) {
    # Prompt the user for the folder path
    $systemLogPath = Read-Host "Enter the path to the System Event log."
}

# Remove double quotes from the input path
$systemLogPath = $systemLogPath.Replace('"', '')

# Check if the input file exists
if (Test-Path $systemLogPath -PathType Leaf) {

    # Get the directory path of the input file
    $directoryPath = Split-Path $systemLogPath -Parent
    $exportPath = Join-Path $directoryPath "DnsEvents.csv"

    # Define the XPath filter to only include events from the specified provider
    $filterXPath = "*[System[Provider[@Name='Microsoft-Windows-DNS-Client']] and (System/Level=2 or System/Level=3 or System/Level=1)]"

    $systemEvents = Get-WinEvent -Path $systemLogPath -FilterXPath $filterXPath
    $systemEvents | Select-Object TimeCreated, Id, Message, ProviderName | Export-Csv -Path $exportPath -NoTypeInformation -Force
}
