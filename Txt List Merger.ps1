Add-Type -AssemblyName System.Windows.Forms

# UI Components
$form = New-Object System.Windows.Forms.Form
$form.Text = "TXT File Merger"
$form.Width = 600
$form.Height = 350
$form.StartPosition = "CenterScreen"

$lblInput = New-Object System.Windows.Forms.Label
$lblInput.Text = "Select TXT files to merge:"
$lblInput.Left = 10
$lblInput.Top = 20
$lblInput.Width = 200
$form.Controls.Add($lblInput)

$lstFiles = New-Object System.Windows.Forms.ListBox
$lstFiles.SelectionMode = 'MultiExtended'
$lstFiles.Left = 10
$lstFiles.Top = 45
$lstFiles.Width = 400
$lstFiles.Height = 120
$form.Controls.Add($lstFiles)

$btnAddFiles = New-Object System.Windows.Forms.Button
$btnAddFiles.Text = "Add Files"
$btnAddFiles.Left = 420
$btnAddFiles.Top = 45
$btnAddFiles.Width = 120
$form.Controls.Add($btnAddFiles)

$btnRemoveFiles = New-Object System.Windows.Forms.Button
$btnRemoveFiles.Text = "Remove Selected"
$btnRemoveFiles.Left = 420
$btnRemoveFiles.Top = 80
$btnRemoveFiles.Width = 120
$form.Controls.Add($btnRemoveFiles)

$lblOutput = New-Object System.Windows.Forms.Label
$lblOutput.Text = "Output file:"
$lblOutput.Left = 10
$lblOutput.Top = 180
$lblOutput.Width = 200
$form.Controls.Add($lblOutput)

$txtOutput = New-Object System.Windows.Forms.TextBox
$txtOutput.Left = 10
$txtOutput.Top = 205
$txtOutput.Width = 400
$form.Controls.Add($txtOutput)

$btnBrowseOut = New-Object System.Windows.Forms.Button
$btnBrowseOut.Text = "Browse"
$btnBrowseOut.Left = 420
$btnBrowseOut.Top = 205
$btnBrowseOut.Width = 120
$form.Controls.Add($btnBrowseOut)

$btnMerge = New-Object System.Windows.Forms.Button
$btnMerge.Text = "Merge"
$btnMerge.Left = 230
$btnMerge.Top = 250
$btnMerge.Width = 120
$btnMerge.Height = 35
$btnMerge.Font = "Microsoft Sans Serif, 11"
$form.Controls.Add($btnMerge)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Status: Waiting for user action."
$lblStatus.Left = 10
$lblStatus.Top = 300
$lblStatus.Width = 580
$form.Controls.Add($lblStatus)

# File Dialogs
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
$openFileDialog.Multiselect = $true

$saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
$saveFileDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
$saveFileDialog.OverwritePrompt = $true

# Status updater
function Update-Status($msg) {
    $lblStatus.Text = "Status: $msg"
    $form.Refresh()
}

# Add files
$btnAddFiles.Add_Click({
    if($openFileDialog.ShowDialog() -eq "OK") {
        foreach ($file in $openFileDialog.FileNames) {
            if(-not $lstFiles.Items.Contains($file)) {
                $lstFiles.Items.Add($file)
            }
        }
    }
})

# Remove selected
$btnRemoveFiles.Add_Click({
    $selected = @($lstFiles.SelectedItems)
    foreach ($item in $selected) {
        $lstFiles.Items.Remove($item)
    }
})

# Browse output
$btnBrowseOut.Add_Click({
    if($saveFileDialog.ShowDialog() -eq "OK") {
        $txtOutput.Text = $saveFileDialog.FileName
    }
})

# Optimized merge function with threading
function Merge-FilesOptimized {
    param (
        [string[]]$InputFiles,
        [string]$OutputFile
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $utf8NoBOM = New-Object System.Text.UTF8Encoding($false)

    $tempFiles = @()
    $jobs = @()
    $totalFiles = $InputFiles.Count
    $fileIndex = 1

    foreach ($file in $InputFiles) {
        $tempFile = [System.IO.Path]::GetTempFileName()
        $tempFiles += $tempFile

        $jobs += Start-Job -ArgumentList $file, $tempFile, $fileIndex, $totalFiles -ScriptBlock {
            param($filePath, $outPath, $index, $total)

            $reader = New-Object System.IO.StreamReader($filePath, [System.Text.Encoding]::UTF8)
            $writer = New-Object System.IO.StreamWriter($outPath, $false, [System.Text.UTF8Encoding]::new($false))

            while (($line = $reader.ReadLine()) -ne $null) {
                $trimmed = $line.Trim()
                if ($trimmed -ne "") {
                    $writer.WriteLine($trimmed)
                }
            }

            $reader.Close()
            $writer.Close()
        }

        $fileIndex++
    }

    # Wait for all jobs
    while (@($jobs | Where-Object { $_.State -eq "Running" }).Count -gt 0) {
        $done = $totalFiles - @($jobs | Where-Object { $_.State -eq "Running" }).Count
        Update-Status "Merging files... $([math]::Round($done / $totalFiles * 100))% done"
        Start-Sleep -Milliseconds 500
    }

    # Merge temp files into final output
    Update-Status "Finalizing merged file..."
    $writer = New-Object System.IO.StreamWriter($OutputFile, $false, $utf8NoBOM)

    foreach ($temp in $tempFiles) {
        $reader = New-Object System.IO.StreamReader($temp, [System.Text.Encoding]::UTF8)
        while (($line = $reader.ReadLine()) -ne $null) {
            $writer.WriteLine($line)
        }
        $reader.Close()
        Remove-Item $temp -Force
    }

    $writer.Close()

    # Cleanup jobs
    $jobs | ForEach-Object {
        Receive-Job $_ | Out-Null
        Remove-Job $_ -Force
    }

    $sw.Stop()
    Update-Status "Done! Merged $totalFiles files in $($sw.Elapsed.TotalSeconds.ToString("0.00")) seconds."
}


# Merge button click
$btnMerge.Add_Click({
    $files = @($lstFiles.Items)
    $output = $txtOutput.Text.Trim()
    if($files.Count -eq 0) {
        Update-Status "Please select at least one input file."
        return
    }
    if([string]::IsNullOrWhiteSpace($output)) {
        Update-Status "Please select an output file."
        return
    }
    if(Test-Path $output) {
        $result = [System.Windows.Forms.MessageBox]::Show("Output file exists and will be overwritten. Continue?", "Warning", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if($result -ne [System.Windows.Forms.DialogResult]::Yes) { return }
        Remove-Item $output -Force
    }
    try {
        Update-Status "Starting merge..."
        Merge-FilesOptimized -InputFiles $files -OutputFile $output
        [System.Windows.Forms.MessageBox]::Show("Merge complete!","Success",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
    } catch {
        Update-Status "Error: $_"
        [System.Windows.Forms.MessageBox]::Show("Error during merge: $_","Error",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

# Show form
[void]$form.ShowDialog()
