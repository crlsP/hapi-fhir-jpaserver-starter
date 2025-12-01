# buscar-paciente.ps1
# Script para buscar pacientes en el servidor FHIR

param(
    [Parameter(Mandatory=$false)]
    [string]$Id,
    
    [Parameter(Mandatory=$false)]
    [string]$Nombre
)

$baseUrl = "http://localhost:8080/fhir"

if ($Id) {
    # Buscar por ID
    Write-Host "Buscando paciente con ID: $Id" -ForegroundColor Cyan
    Write-Host ""
    
    try {
        $patient = Invoke-RestMethod -Uri "$baseUrl/Patient/$Id" -Method Get
        
        Write-Host "[OK] Paciente encontrado:" -ForegroundColor Green
        Write-Host "  ID:                 $($patient.id)"
        Write-Host "  Nombre:             $($patient.name[0].given -join ' ') $($patient.name[0].family)"
        Write-Host "  Genero:             $($patient.gender)"
        Write-Host "  Fecha nacimiento:   $($patient.birthDate)"
        
        if ($patient.telecom) {
            Write-Host "  Telefono:           $($patient.telecom[0].value)"
        }
        if ($patient.address) {
            Write-Host "  Ciudad:             $($patient.address[0].city)"
            Write-Host "  Pais:               $($patient.address[0].country)"
        }
        
        # Mostrar JSON completo
        Write-Host "`nJSON completo:" -ForegroundColor Yellow
        $patient | ConvertTo-Json -Depth 10
        
    } catch {
        if ($_.Exception.Response.StatusCode.value__ -eq 404) {
            Write-Host "[ERROR] Paciente con ID $Id no encontrado" -ForegroundColor Red
        } else {
            Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
} elseif ($Nombre) {
    # Buscar por nombre
    Write-Host "Buscando pacientes con nombre: $Nombre" -ForegroundColor Cyan
    Write-Host ""
    
    $response = Invoke-RestMethod -Uri "$baseUrl/Patient?name=$Nombre" -Method Get
    
    if ($response.total -gt 0) {
        Write-Host "[OK] Se encontraron $($response.total) paciente(s):" -ForegroundColor Green
        Write-Host ""
        
        $response.entry | ForEach-Object {
            $p = $_.resource
            Write-Host "================================"
            Write-Host "  ID:                 $($p.id)"
            Write-Host "  Nombre:             $($p.name[0].given -join ' ') $($p.name[0].family)"
            Write-Host "  Genero:             $($p.gender)"
            Write-Host "  Fecha nacimiento:   $($p.birthDate)"
            Write-Host ""
        }
    } else {
        Write-Host "[INFO] No se encontraron pacientes con nombre '$Nombre'" -ForegroundColor Yellow
    }
    
} else {
    # Listar todos los pacientes
    Write-Host "Listando todos los pacientes..." -ForegroundColor Cyan
    Write-Host ""
    
    $response = Invoke-RestMethod -Uri "$baseUrl/Patient?_count=100" -Method Get
    
    Write-Host "Total de pacientes: $($response.total)" -ForegroundColor Green
    Write-Host ""
    
    if ($response.total -gt 0) {
        $response.entry | ForEach-Object {
            $p = $_.resource
            $nombreCompleto = "$($p.name[0].given -join ' ') $($p.name[0].family)"
            Write-Host "  ID: $($p.id.PadRight(10)) - $nombreCompleto"
        }
    } else {
        Write-Host "No hay pacientes registrados todavia" -ForegroundColor Yellow
    }
}

