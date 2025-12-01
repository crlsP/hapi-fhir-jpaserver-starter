# Script de Prueba de Conexion a PostgreSQL
# Para ejecutar: .\test-conexion-bd.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST DE CONEXION A POSTGRESQL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Credenciales
$host_db = "localhost"
$port_db = "5432"
$database = "hapi"
$username = "admin"
$password = "admin"

Write-Host "Credenciales a usar:" -ForegroundColor Yellow
Write-Host "  Host:           $host_db"
Write-Host "  Puerto:         $port_db"
Write-Host "  Base de datos:  $database"
Write-Host "  Usuario:        $username"
Write-Host "  Contraseña:     $password"
Write-Host ""

# Test 1: Verificar que el puerto esta abierto
Write-Host "Test 1: Verificando puerto $port_db..." -ForegroundColor Cyan
$testPort = Test-NetConnection -ComputerName $host_db -Port $port_db -WarningAction SilentlyContinue

if ($testPort.TcpTestSucceeded) {
    Write-Host "  [OK] Puerto $port_db esta abierto y accesible" -ForegroundColor Green
} else {
    Write-Host "  [ERROR] Puerto $port_db no esta accesible" -ForegroundColor Red
    Write-Host "  Verifica que Docker este corriendo: docker ps" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Test 2: Verificar que el contenedor esta corriendo
Write-Host "Test 2: Verificando contenedor de PostgreSQL..." -ForegroundColor Cyan
$container = docker ps --filter "name=hapi-fhir-postgres" --format "{{.Status}}"

if ($container -match "Up") {
    Write-Host "  [OK] Contenedor PostgreSQL esta corriendo: $container" -ForegroundColor Green
} else {
    Write-Host "  [ERROR] Contenedor PostgreSQL no esta corriendo" -ForegroundColor Red
    Write-Host "  Inicia los contenedores: docker compose up -d" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Test 3: Conectarse y ejecutar consulta desde Docker
Write-Host "Test 3: Probando conexion desde Docker..." -ForegroundColor Cyan
$queryTest = 'SELECT version();'
docker exec hapi-fhir-postgres psql -U $username -d $database -c $queryTest | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] Conexion exitosa desde Docker" -ForegroundColor Green
} else {
    Write-Host "  [ERROR] Error al conectarse desde Docker" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 4: Mostrar informacion de la base de datos
Write-Host "Test 4: Obteniendo informacion de la base de datos..." -ForegroundColor Cyan
Write-Host ""

# Obtener conteo de recursos
Write-Host "Recursos FHIR almacenados:" -ForegroundColor Yellow
$queryRecursos = "SELECT RES_TYPE, COUNT(*) FROM HFJ_RESOURCE GROUP BY RES_TYPE ORDER BY COUNT(*) DESC;"
$recursos = docker exec hapi-fhir-postgres psql -U $username -d $database -t -c $queryRecursos

if ($LASTEXITCODE -eq 0 -and $recursos) {
    foreach ($linea in $recursos) {
        if ($linea.Trim()) {
            Write-Host "  $linea"
        }
    }
} else {
    Write-Host "  (No hay recursos todavia)" -ForegroundColor Gray
}
Write-Host ""

# Test 5: Mostrar estadisticas de la base de datos
Write-Host "Estadisticas de la base de datos:" -ForegroundColor Yellow
$queryTablas = "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';"
$stats = docker exec hapi-fhir-postgres psql -U $username -d $database -t -c $queryTablas
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Total de tablas: $($stats.Trim())"
}

$queryConexiones = "SELECT COUNT(*) FROM pg_stat_activity WHERE datname = 'hapi';"
$conexiones = docker exec hapi-fhir-postgres psql -U $username -d $database -t -c $queryConexiones
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Conexiones activas: $($conexiones.Trim())"
}
Write-Host ""

# Resumen final
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TODOS LOS TESTS PASARON" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Como conectarte:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Desde linea de comandos (Docker):" -ForegroundColor White
Write-Host "     docker exec -it hapi-fhir-postgres psql -U admin -d hapi" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Con herramienta GUI (DBeaver, pgAdmin, etc.):" -ForegroundColor White
Write-Host "     Host:           localhost" -ForegroundColor Gray
Write-Host "     Puerto:         5432" -ForegroundColor Gray
Write-Host "     Base de datos:  hapi" -ForegroundColor Cyan
Write-Host "     Usuario:        admin" -ForegroundColor Gray
Write-Host "     Contraseña:     admin" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. URL de conexion:" -ForegroundColor White
Write-Host "     postgresql://admin:admin@localhost:5432/hapi" -ForegroundColor Gray
Write-Host ""
Write-Host "IMPORTANTE: La base de datos se llama 'hapi', NO 'admin'" -ForegroundColor Yellow
Write-Host ""
