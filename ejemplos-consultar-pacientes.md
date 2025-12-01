# 🔍 Ejemplos para Consultar Pacientes FHIR

## 📋 Tabla de Contenidos
1. [Consultas FHIR (API REST)](#consultas-fhir-api-rest)
2. [Consultas SQL (Base de Datos)](#consultas-sql-base-de-datos)
3. [Ejemplos Prácticos](#ejemplos-prácticos)

---

## 1️⃣ Consultas FHIR (API REST)

### A. Buscar TODOS los pacientes

#### Con cURL:
```powershell
curl http://localhost:8080/fhir/Patient
```

#### Con PowerShell (más legible):
```powershell
$response = Invoke-RestMethod -Uri "http://localhost:8080/fhir/Patient" -Method Get
$response.entry | ForEach-Object {
    $patient = $_.resource
    Write-Host "ID: $($patient.id) - Nombre: $($patient.name[0].given[0]) $($patient.name[0].family)"
}
```

---

### B. Buscar un paciente por ID específico

```powershell
# Buscar paciente con ID 1000
curl http://localhost:8080/fhir/Patient/1000
```

**Con PowerShell (formato JSON legible):**
```powershell
$patientId = "1000"
$patient = Invoke-RestMethod -Uri "http://localhost:8080/fhir/Patient/$patientId"
$patient | ConvertTo-Json -Depth 10
```

---

### C. Verificar si existe un paciente por ID

```powershell
# Función para verificar si un paciente existe
function Test-PatientExists {
    param([string]$PatientId)
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/fhir/Patient/$PatientId" -Method Get -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ El paciente con ID $PatientId EXISTE" -ForegroundColor Green
            return $true
        }
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Host "❌ El paciente con ID $PatientId NO EXISTE" -ForegroundColor Red
            return $false
        }
        else {
            Write-Host "⚠️ Error al consultar: $($_.Exception.Message)" -ForegroundColor Yellow
            return $null
        }
    }
}

# Uso:
Test-PatientExists -PatientId "1000"
Test-PatientExists -PatientId "9999"
```

---

### D. Buscar pacientes por nombre

```powershell
# Buscar por apellido
curl "http://localhost:8080/fhir/Patient?name=Garcia"

# Buscar por nombre completo
curl "http://localhost:8080/fhir/Patient?name=Carlos Garcia"
```

**Con PowerShell:**
```powershell
$apellido = "Garcia"
$response = Invoke-RestMethod -Uri "http://localhost:8080/fhir/Patient?name=$apellido"

if ($response.total -gt 0) {
    Write-Host "Se encontraron $($response.total) paciente(s) con apellido '$apellido'" -ForegroundColor Green
    
    $response.entry | ForEach-Object {
        $p = $_.resource
        Write-Host "  - ID: $($p.id), Nombre: $($p.name[0].given -join ' ') $($p.name[0].family)"
    }
} else {
    Write-Host "No se encontraron pacientes con apellido '$apellido'" -ForegroundColor Yellow
}
```

---

### E. Buscar pacientes por género

```powershell
# Buscar pacientes masculinos
curl "http://localhost:8080/fhir/Patient?gender=male"

# Buscar pacientes femeninos
curl "http://localhost:8080/fhir/Patient?gender=female"
```

---

### F. Buscar pacientes por fecha de nacimiento

```powershell
# Buscar pacientes nacidos en 1990
curl "http://localhost:8080/fhir/Patient?birthdate=1990"

# Buscar pacientes nacidos después de 1990
curl "http://localhost:8080/fhir/Patient?birthdate=gt1990"

# Buscar pacientes nacidos entre 1980 y 1990
curl "http://localhost:8080/fhir/Patient?birthdate=ge1980&birthdate=le1990"
```

---

### G. Buscar con múltiples criterios (combinados)

```powershell
# Buscar hombre llamado García nacido en 1990
curl "http://localhost:8080/fhir/Patient?name=Garcia&gender=male&birthdate=1990"
```

**Con PowerShell:**
```powershell
$params = @{
    name = "Garcia"
    gender = "male"
    birthdate = "1990"
}

$queryString = ($params.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"
$uri = "http://localhost:8080/fhir/Patient?$queryString"

$response = Invoke-RestMethod -Uri $uri
Write-Host "Pacientes encontrados: $($response.total)"
```

---

### H. Buscar por identificador (número de documento)

```powershell
# Buscar por identificador específico
curl "http://localhost:8080/fhir/Patient?identifier=12345678"
```

---

## 2️⃣ Consultas SQL (Base de Datos)

### A. Verificar si existe un paciente por ID

```powershell
docker exec hapi-fhir-postgres psql -U admin -d hapi -c "SELECT EXISTS(SELECT 1 FROM HFJ_RESOURCE WHERE RES_ID = 1000 AND RES_TYPE = 'Patient');"
```

**Salida:**
- `t` = true (el paciente existe)
- `f` = false (el paciente NO existe)

---

### B. Contar todos los pacientes

```sql
SELECT COUNT(*) as total_pacientes 
FROM HFJ_RESOURCE 
WHERE RES_TYPE = 'Patient';
```

**Ejecutar desde PowerShell:**
```powershell
docker exec hapi-fhir-postgres psql -U admin -d hapi -c "SELECT COUNT(*) as total_pacientes FROM HFJ_RESOURCE WHERE RES_TYPE = 'Patient';"
```

---

### C. Listar todos los pacientes (IDs)

```sql
SELECT RES_ID, RES_UPDATED, RES_VERSION 
FROM HFJ_RESOURCE 
WHERE RES_TYPE = 'Patient' 
ORDER BY RES_UPDATED DESC;
```

**Ejecutar:**
```powershell
docker exec hapi-fhir-postgres psql -U admin -d hapi -c "SELECT RES_ID, RES_UPDATED, RES_VERSION FROM HFJ_RESOURCE WHERE RES_TYPE = 'Patient' ORDER BY RES_UPDATED DESC;"
```

---

### D. Ver el contenido completo de un paciente

```sql
SELECT RES_TEXT_VC 
FROM HFJ_RESOURCE 
WHERE RES_ID = 1000 
AND RES_TYPE = 'Patient';
```

**Nota:** `RES_TEXT_VC` contiene el JSON completo del recurso FHIR.

---

### E. Buscar pacientes por contenido (texto)

```sql
-- Buscar pacientes que contengan "Garcia" en su JSON
SELECT RES_ID, RES_UPDATED 
FROM HFJ_RESOURCE 
WHERE RES_TYPE = 'Patient' 
AND RES_TEXT_VC LIKE '%Garcia%';
```

---

### F. Buscar usando índices de búsqueda de HAPI

```sql
-- Buscar por nombre usando la tabla de índices de strings
SELECT DISTINCT r.RES_ID 
FROM HFJ_RESOURCE r
JOIN HFJ_SPIDX_STRING s ON r.RES_ID = s.RES_ID
WHERE r.RES_TYPE = 'Patient'
AND s.SP_NAME = 'family'
AND s.SP_VALUE_NORMALIZED LIKE '%GARCIA%';
```

---

## 3️⃣ Ejemplos Prácticos Completos

### Ejemplo 1: Script completo para buscar un paciente

```powershell
# buscar-paciente.ps1

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
    
    try {
        $patient = Invoke-RestMethod -Uri "$baseUrl/Patient/$Id" -Method Get
        
        Write-Host "`n✅ Paciente encontrado:" -ForegroundColor Green
        Write-Host "  ID: $($patient.id)"
        Write-Host "  Nombre: $($patient.name[0].given -join ' ') $($patient.name[0].family)"
        Write-Host "  Género: $($patient.gender)"
        Write-Host "  Fecha de nacimiento: $($patient.birthDate)"
        
        # Mostrar JSON completo
        Write-Host "`n📄 JSON completo:" -ForegroundColor Yellow
        $patient | ConvertTo-Json -Depth 10
        
    } catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Host "`n❌ Paciente con ID $Id no encontrado" -ForegroundColor Red
        } else {
            Write-Host "`n⚠️ Error: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
} elseif ($Nombre) {
    # Buscar por nombre
    Write-Host "Buscando pacientes con nombre: $Nombre" -ForegroundColor Cyan
    
    $response = Invoke-RestMethod -Uri "$baseUrl/Patient?name=$Nombre" -Method Get
    
    if ($response.total -gt 0) {
        Write-Host "`n✅ Se encontraron $($response.total) paciente(s):" -ForegroundColor Green
        
        $response.entry | ForEach-Object {
            $p = $_.resource
            Write-Host "`n  ID: $($p.id)"
            Write-Host "  Nombre: $($p.name[0].given -join ' ') $($p.name[0].family)"
            Write-Host "  Género: $($p.gender)"
            Write-Host "  Fecha de nacimiento: $($p.birthDate)"
        }
    } else {
        Write-Host "`n❌ No se encontraron pacientes con nombre '$Nombre'" -ForegroundColor Red
    }
    
} else {
    # Listar todos los pacientes
    Write-Host "Listando todos los pacientes..." -ForegroundColor Cyan
    
    $response = Invoke-RestMethod -Uri "$baseUrl/Patient" -Method Get
    
    Write-Host "`n📊 Total de pacientes: $($response.total)" -ForegroundColor Green
    
    if ($response.total -gt 0) {
        $response.entry | ForEach-Object {
            $p = $_.resource
            Write-Host "`n  ID: $($p.id)"
            Write-Host "  Nombre: $($p.name[0].given -join ' ') $($p.name[0].family)"
        }
    }
}
```

**Uso:**
```powershell
# Buscar por ID
.\buscar-paciente.ps1 -Id "1000"

# Buscar por nombre
.\buscar-paciente.ps1 -Nombre "Garcia"

# Listar todos
.\buscar-paciente.ps1
```

---

### Ejemplo 2: Verificar múltiples pacientes

```powershell
# verificar-pacientes.ps1

$pacientesIds = @("1000", "1001", "1002", "9999")

Write-Host "Verificando existencia de pacientes...`n" -ForegroundColor Cyan

foreach ($id in $pacientesIds) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/fhir/Patient/$id" -Method Get -ErrorAction Stop
        
        if ($response.StatusCode -eq 200) {
            $patient = $response.Content | ConvertFrom-Json
            $nombreCompleto = "$($patient.name[0].given -join ' ') $($patient.name[0].family)"
            Write-Host "✅ ID $id - EXISTE - $nombreCompleto" -ForegroundColor Green
        }
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Host "❌ ID $id - NO EXISTE" -ForegroundColor Red
        }
        else {
            Write-Host "⚠️ ID $id - ERROR: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}
```

---

### Ejemplo 3: Búsqueda avanzada con filtros

```powershell
# busqueda-avanzada.ps1

function Search-Patients {
    param(
        [string]$Nombre,
        [string]$Genero,
        [string]$FechaNacimiento,
        [int]$Limit = 10
    )
    
    $params = @{}
    if ($Nombre) { $params['name'] = $Nombre }
    if ($Genero) { $params['gender'] = $Genero }
    if ($FechaNacimiento) { $params['birthdate'] = $FechaNacimiento }
    $params['_count'] = $Limit
    
    $queryString = ($params.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"
    $uri = "http://localhost:8080/fhir/Patient?$queryString"
    
    Write-Host "Buscando con criterios:" -ForegroundColor Cyan
    Write-Host "  URL: $uri`n" -ForegroundColor Gray
    
    $response = Invoke-RestMethod -Uri $uri
    
    Write-Host "📊 Resultados: $($response.total) paciente(s) encontrado(s)`n" -ForegroundColor Green
    
    if ($response.total -gt 0) {
        $response.entry | ForEach-Object {
            $p = $_.resource
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            Write-Host "ID:                 $($p.id)"
            Write-Host "Nombre:             $($p.name[0].given -join ' ') $($p.name[0].family)"
            Write-Host "Género:             $($p.gender)"
            Write-Host "Fecha nacimiento:   $($p.birthDate)"
            if ($p.telecom) {
                Write-Host "Teléfono:           $($p.telecom[0].value)"
            }
            if ($p.address) {
                Write-Host "Ciudad:             $($p.address[0].city)"
            }
            Write-Host ""
        }
    }
}

# Ejemplos de uso:
Search-Patients -Nombre "Garcia"
Search-Patients -Genero "male"
Search-Patients -Nombre "Garcia" -Genero "male"
Search-Patients -FechaNacimiento "1990"
```

---

## 🎯 Resumen de Métodos

| Método | Caso de Uso | Velocidad | Complejidad |
|--------|------------|-----------|-------------|
| **GET /Patient/{id}** | Buscar por ID exacto | ⚡⚡⚡ Rápido | ✅ Simple |
| **GET /Patient?name=X** | Buscar por nombre | ⚡⚡ Medio | ✅ Simple |
| **GET /Patient?gender=X** | Filtrar por género | ⚡⚡ Medio | ✅ Simple |
| **GET /Patient** | Listar todos | ⚡ Lento | ✅ Simple |
| **SQL directo** | Consultas avanzadas | ⚡⚡⚡ Rápido | ⚠️ Avanzado |

---

## 💡 Consejos Importantes

1. **Siempre usa búsquedas específicas** en lugar de listar todos los pacientes
2. **Usa paginación** con `_count` para limitar resultados: `?_count=10`
3. **Maneja los errores 404** cuando un paciente no existe
4. **Usa SQL solo para reportes** o consultas muy específicas
5. **La API FHIR es la forma estándar** y recomendada

---

## 📚 Documentación Adicional

- **Parámetros de búsqueda FHIR**: https://www.hl7.org/fhir/patient.html#search
- **Operadores de comparación**: `eq`, `ne`, `lt`, `gt`, `le`, `ge`, `sa`, `eb`
- **Modificadores**: `:exact`, `:contains`, `:missing`

---

¡Listo para buscar pacientes! 🔍

