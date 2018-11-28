<# .SYNOPSIS
     Enumerate ciphers supported by an FTP(ES) server.
.DESCRIPTION
     Uses all ciphers supported by OpenSSL to test the SSL/TLS configuration of an FTP server using Explicit SSL.

     The ciphers names are converted from OpenSSL naming to official IANA naming.
.NOTES
     Author     : Marc Wils - marc@marcwils.be.eu.org
.LINK
     https://www.marcwils.be.eu.org
#>
$ErrorActionPreference = "Stop"

# Variables
$openSsl = "C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
$targetHost = "test.rebex.net"
$targetPort = "21"
$ianaList = "https://www.iana.org/assignments/tls-parameters/tls-parameters-4.csv"

# Start script and perform sanity checks
& cls 
if (!(Test-Path $openSsl)){
    Write-Error "OpenSSL.exe not found"
} else {
    $openSslVersion = & $openssl version
    Write-Host "Using $openSslVersion"
}

# Script start
Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# Capture ciphers supported by OpenSSL
$ciphers = & $openSsl ciphers -V | ConvertFrom-String -PropertyNames a,Code,b,Name,TlsVersion | Sort-Object -Property Name

# Read list from IANA to do translations
$ianaCiphers = (Invoke-WebRequest -Uri $ianaList -Method Get).Content 

# Try each cipher to connect
Write-Host "Enumerating ciphers"
foreach ($cipher in $ciphers){
    $cipherName = $cipher.Name
    $cipherCode = $cipher.Code
    $connectLog = echo QUIT | & $openssl s_client -cipher $cipherName -connect ${targetHost}:${targetPort} -starttls ftp 2>&1
    
    $ianaCipher =  [regex]::Match($ianaCiphers, """(?<code>$cipherCode""),(?<name>\S*),(.*),(.*),(.*)", [System.Text.RegularExpressions.RegexOptions]::Multiline).Groups["name"].Value
    
    $tlsInterpreter = [regex]::Match($connectLog, "New, TLSv(?<tls_version>\d\.\d), Cipher is (?<cipher>\S*)", [System.Text.RegularExpressions.RegexOptions]::Multiline)
    if ($tlsInterpreter.Length -ne 0)
    {
        $tlsVersion = $tlsInterpreter.Groups["tls_version"].Value
        $tlsCipher = $tlsInterpreter.Groups["cipher"].Value

        Write-Host "$cipherName -> Succeeded, connected using TLSv${tlsVersion} $ianaCipher" -ForegroundColor White
    } else {
        Write-Host "$cipherName -> Failed using $ianaCipher" -ForegroundColor Red
    }
}
