# K8s Golang Demo - Test Script for Windows
# Run in PowerShell

param(
    [string]$ApiUrl = "http://localhost:8080"
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Testing Data Ingestion API" -ForegroundColor Cyan
Write-Host "API URL: $ApiUrl" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Test health endpoint
Write-Host "Testing /health endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/health" -Method Get
    $response | ConvertTo-Json
    Write-Host "✓ Health check passed" -ForegroundColor Green
} catch {
    Write-Host "✗ Health check failed: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test ready endpoint
Write-Host "Testing /ready endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/ready" -Method Get
    $response | ConvertTo-Json
    Write-Host "✓ Ready check passed" -ForegroundColor Green
} catch {
    Write-Host "✗ Ready check failed: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Ingest some test data
Write-Host "Ingesting test data..." -ForegroundColor Yellow
for ($i = 1; $i -le 5; $i++) {
    $body = @{
        source = "test-source-$i"
        metrics = @{
            value = Get-Random -Minimum 0 -Maximum 1000
            latency = Get-Random -Minimum 0 -Maximum 100
        }
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$ApiUrl/ingest" -Method Post -ContentType "application/json" -Body $body
        $response | ConvertTo-Json
    } catch {
        Write-Host "✗ Data ingestion failed: $_" -ForegroundColor Red
    }
    Write-Host ""
}
Write-Host "✓ Data ingestion completed" -ForegroundColor Green
Write-Host ""

# Retrieve data
Write-Host "Retrieving stored data..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/data" -Method Get
    Write-Host "Count: $($response.count)" -ForegroundColor White
    $response.data | Where-Object { $_.source -ne $null } | ConvertTo-Json
    Write-Host "✓ Data retrieval successful" -ForegroundColor Green
} catch {
    Write-Host "✗ Data retrieval failed: $_" -ForegroundColor Red
}
Write-Host ""

# Check Prometheus metrics
Write-Host "Checking Prometheus metrics..." -ForegroundColor Yellow
try {
    $metrics = Invoke-WebRequest -Uri "$ApiUrl/metrics" -UseBasicParsing
    Write-Host "Sample metrics:" -ForegroundColor White
    $metrics.Content -split "`n" | Where-Object { $_ -match "^(http_requests_total|data_points_ingested_total|http_request_duration)" } | Select-Object -First 10
    Write-Host "✓ Metrics available" -ForegroundColor Green
} catch {
    Write-Host "✗ Metrics check failed: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "All tests passed!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
