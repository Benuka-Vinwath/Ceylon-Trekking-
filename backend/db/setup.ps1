# One-time setup: creates the database, tables and sample treks. Asks for the postgres password once.
$psql = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
Set-Location "$PSScriptRoot\.."
$secure = Read-Host "PostgreSQL password for user postgres" -AsSecureString
$env:PGPASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))

& $psql -U postgres -c "CREATE DATABASE ceylon_trekking;"   # fails harmlessly if it already exists
& $psql -U postgres -d ceylon_trekking -f db/schema.sql      # fails harmlessly if tables already exist
& $psql -U postgres -d ceylon_trekking -tc "SELECT count(*) FROM treks;" | ForEach-Object { if ($_.Trim() -eq "0") { & $psql -U postgres -d ceylon_trekking -f db/seed.sql } }
Write-Host "Treks in database:"
& $psql -U postgres -d ceylon_trekking -tc "SELECT count(*) FROM treks;"
Remove-Item Env:PGPASSWORD
