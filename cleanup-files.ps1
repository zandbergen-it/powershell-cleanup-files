# Load config file
if (Get-Item './config.json' -ErrorAction SilentlyContinue)
{
    $config = Get-Content './config.json' | ConvertFrom-Json
}
else 
{
    Write-host 'No config.json in root dir of script!'
    Break
}

# Variables
# Debug file will be deleted every run and recreated when $debug = $true
$debug = $true
$debugfile = './debug.log'

# Main script
if ($debug)
{
    if (Get-Item $debugfile -ErrorAction SilentlyContinue)
    {
        Remove-Item $debugfile
    }
}

foreach ($dir in $config.dirs)
{
    # Precaution to make sure the server won't crash because of all the jobs running at once
    while ((Get-Job | Where-Object { $_.state -eq 'Running'} ).count -ge $config.common.concurrentjobs)
    {
        "Waiting 10s too many jobs"
        start-sleep -Seconds 10
    }

    # Using jobs too do multiple dirs at once
    Start-Job -name $dir -ScriptBlock {

        $files = Get-ChildItem $USING:dir.dir | Where-Object { $_.name -match $USING:dir.pattern }
        
        foreach ($file in $files)
        {
            # Check age of lastwrite and delete older files than age specified in config
            if ($file.LastWriteTime -le (Get-Date).AddDays(((-$USING:dir.age))))
            {
                if ($USING:debug)
                {
                    $file.FullName
                }

                Remove-Item $file.FullName
            }
        }
    }
}

if ($debug)
{
    # Have to do this afterwards, otherwise it will take a long time to run 
    # because it is waiting for the jobs to finish
    "Deleted files:" >> $debugfile

    foreach ($dir in $config.dirs)
    {
        Receive-Job -name $dir >> $debugfile
    }    
}
