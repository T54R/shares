@echo off

set TASK_NAME=RunTeamViewerEvery5Min
set TV_PATH="C:\Program Files\TeamViewer\TeamViewer.exe"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$action = New-ScheduledTaskAction -Execute %TV_PATH%; ^
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration ([TimeSpan]::MaxValue); ^
$principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -RunLevel Highest; ^
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable; ^
Register-ScheduledTask -TaskName '%TASK_NAME%' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force"
