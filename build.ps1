param (
    [Parameter(Position = 1)][string] $Operation = 'Build',
    [string] $Function = $null,
    [bool] $Minify = $true
)

#
# Setup

if (-not ($env:Path -like '*;.\node_modules\.bin*')) {
    $env:Path += ';.\node_modules\.bin'
}

if (Test-Path '.\env.ps1') {
    . .\env.ps1
}


#
# Helper Functions

function Set-FunctionEnvironment ($FunctionDir) {
    if ([string]::IsNullOrWhiteSpace($FunctionDir)) {
        $env:FunctionName = $null
        $env:FunctionRelative = $null
    } else {
        $env:FunctionName = (Get-Item $FunctionDir).Name
        $env:FunctionRelative = ((Resolve-Path -Relative $FunctionDir) -replace '\\', '/').TrimEnd('/')
    }
}

function Rename-TSLibFile () {
    if (-not (Test-Path '.\node_modules\tslib\index.js')) {
        if (-not (Test-Path '.\node_modules\tslib\tslib.js')) {
            Write-Error 'npm package "tslib" must be installed!'
            Exit 2
        }

        Write-Host '[build:tslib] fixing tslib...' -ForegroundColor Cyan
        Copy-Item '.\node_modules\tslib\tslib.js' '.\node_modules\tslib\index.js'
        Write-Host '[build:tslib] done' -ForegroundColor Cyan
        Write-Host
    }
}


#
# Operation Functions

function Invoke-BuildBuild ($FunctionDir) {
    if ([string]::IsNullOrWhiteSpace($FunctionDir)) {
        Rename-TSLibFile
        
        if ([string]::IsNullOrWhiteSpace($Functiom)) {
            Get-ChildItem -Directory |
                Where-Object { Get-ChildItem $_ -File -Filter 'function.json' } |
                ForEach-Object { Invoke-BuildBuild $_ }
        } else {
            Invoke-BuildBuild $Function
        }
    } else {
        Set-FunctionEnvironment $FunctionDir

        Write-Host "[build:webpack:${env:FunctionName}] running webpack..." -ForegroundColor Cyan
        &webpack.cmd --module-bind ts
        Write-Host "[build:webpack${env:FunctionName}] done" -ForegroundColor Cyan
        Write-Host
    }
}

function Invoke-BuildLint () {
    Write-Host '[lint] linting typescript...' -ForegroundColor Cyan
    &tslint.cmd --project tsconfig.json --type-check
    Write-Host '[lint] done' -ForegroundColor Cyan
    Write-Host
}

function Invoke-BuildRun () {
    if ([string]::IsNullOrWhiteSpace($Function)) {
        Write-Error 'no function specified!'
        Exit 3
    }
    if (-not (Test-Path (Join-Path $Function 'function.json'))) {
        Write-Error 'invalid function specified!'
        Exit 4
    }

    Set-FunctionEnvironment $Function
    
    Write-Host "[run:${env:FunctionName}] running function..." -ForegroundColor Cyan
    &node -e "require('${env:FunctionRelative}')['default']({ log: x => console.log(x), done: e => e && console.log(e) });"
    Write-Host "[run:${env:FunctionName}] done" -ForegroundColor Cyan
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
    Write-Error "operation '$($Operation.ToLower())' is not supported!"
    Exit 1
}
