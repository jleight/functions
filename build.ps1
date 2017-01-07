param (
    [Parameter(Position = 1)][string] $Operation = 'Build',
    [string] $Function = (Get-Item (Get-Location)).FullName,
    [bool] $Minify = $true
)

#
# Setup

$FunctionName = (Get-Item $Function).Name
$FunctionRelative = ((Resolve-Path -Relative $Function) -replace '\\', '/').TrimEnd('/')

if (-not ($env:Path -like '*;.\node_modules\.bin*')) {
    $env:Path += ';.\node_modules\.bin'
}

if (Test-Path '.\env.ps1') {
    . .\env.ps1
}


#
# Helper Functions

function Test-IsFunctionDirectory () {
    Test-Path (Join-Path $Function "function.json")
}


#
# Operation Functions

function Invoke-BuildBuild ($Directory = $null) {
    if ($Directory -eq $null) {
        Write-Host "[build:transpile] transpiling typescript..." -ForegroundColor Cyan
        &tsc.cmd --noUnusedParameters --noUnusedLocals
        Write-Host "[build:transpile] done" -ForegroundColor Cyan
        Write-Host

        if ($Minify) {
            Get-ChildItem -Directory |
                Where-Object { Get-ChildItem $_ -File -Filter "function.json" } |
                ForEach-Object { Invoke-BuildBuild $_ }
        }
    } else {
        Write-Host "[build:minify:${Directory}] minifying javascript..." -ForegroundColor Cyan
        &uglifyjs.cmd --compress --mangle --screw-ie8 --output "${Directory}/src/index.js" "${Directory}/src/index.js"
        Write-Host "[build:minify:${Directory}] done" -ForegroundColor Cyan
        Write-Host
    }
}

function Invoke-BuildLint () {
    Write-Host "[lint] linting typescript..." -ForegroundColor Cyan
    &tslint.cmd --project tsconfig.json --type-check
    Write-Host "[lint] done" -ForegroundColor Cyan
    Write-Host
}

function Invoke-BuildRun () {
    if (-not (Test-IsFunctionDirectory)) {
        Write-Error "[run:${FunctionName}] no function specified!"
        Exit 2
    }
    
    Write-Host "[run:${FunctionName}] running function..." -ForegroundColor Cyan
    &node -e "require('${FunctionRelative}')({ log: x => console.log(x), done: e => e && console.log(e) });"
    Write-Host "[run:${FunctionName}] done" -ForegroundColor Cyan
    Write-Host
}


#
# Main Script

if (Get-Command "Invoke-Build${Operation}" -ErrorAction SilentlyContinue) {
    Write-Host "[$($Operation.ToLower())] starting operation..." -ForegroundColor Cyan
    Write-Host

    Invoke-Expression "Invoke-Build${Operation}"

    Write-Host "[$($Operation.ToLower())] done" -ForegroundColor Cyan
    Write-Host
} else {
    Write-Error "[$($Operation.ToLower())] operation is not supported!"
    Exit 1
}
