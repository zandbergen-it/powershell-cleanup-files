# Cleanup logfiles script

Script to cleanup (log) files with certain age and pattern options.

- Delete files older than X days
- Delete files based on pattern

## How to use

Best way to use this is to create a scheduled task and run this periodically.

## Configuration

config.json:
Add the directories which contain the logfiles.
Add a pattern, this can be a more complex regex, but a simple .log will also work; it uses match option in Powershell.
Age is in days and will look at lastwritetime.

```json
{
    "logdirs":
        [
            {
            "logdir": "C:/temp/test-logfiles",
            "pattern": ".log",
            "age": "1"
            },

            {
            "logdir": "C:/temp/test-logfiles2",
            "pattern": "'[0-9]{2,2}.log'",
            "age": "1"
            }
        ]
}
```
