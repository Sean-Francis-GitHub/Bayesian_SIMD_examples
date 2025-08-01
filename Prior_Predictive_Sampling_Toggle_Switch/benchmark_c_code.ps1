# PowerShell Script: benchmark_c_code.ps1

# List of thread counts you want to test
$threadCounts = @(1, 2, 4, 8, 12)  # or: @(1, 2, 4, 8, 16)

# Output CSV file
$outputCsv = "output_c_runtime.csv"

# Write header
"cores,time" | Out-File -FilePath $outputCsv -Encoding utf8

# Loop over thread counts
foreach ($threads in $threadCounts) {
    # Replace these args with your actual arguments, except the 6th (argv[5])
    $args = @("8064", "123", "8000", "600", "$threads")

    # Run the program and capture the output
    $output = & .\toggle_switch_ABC_pps_vec_par.exe @args

    # Extract the elapsed time (assuming output is just the time in seconds)
    $time = [double]$output.Trim()

    # Append result to CSV
    "$threads,$time" | Out-File -FilePath $outputCsv -Append -Encoding utf8

    Write-Host "Run with $threads threads took $time seconds"
}
