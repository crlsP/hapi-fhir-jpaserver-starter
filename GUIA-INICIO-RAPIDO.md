# 🚀 Guía de Inicio Rápido - Servidor HAPI FHIR

## 📋 Requisitos Previos
- Docker Desktop instalado y en ejecución
- Puerto 8080 (servidor FHIR) y 5432 (PostgreSQL) disponibles

---

## 🔧 Pasos para Levantar el Servidor

### 1. Iniciar Docker Desktop
Asegúrate de que Docker Desktop esté corriendo en Windows.

### 2. Navegar al directorio del proyecto
```powershell
cd "C:\Users\carlo\Documents\Teker\HL7 FHIR\Servidor FHIR\hapi-fhir-jpaserver-starter"
```

### 3. Levantar los contenedores
```powershell
docker compose up -d
```

El flag `-d` ejecuta los contenedores en modo "detached" (en segundo plano).

### 4. Verificar que los contenedores están corriendo
```powershell
docker ps
```

Deberías ver dos contenedores:
- `hapi-fhir-server` - Puerto 8080
- `hapi-fhir-postgres` - Puerto 5432

### 5. Ver los logs del servidor (opcional)
```powershell
docker logs hapi-fhir-server -f
```

El servidor estará listo cuando veas: `"Started Application in X seconds"`

Presiona `Ctrl + C` para salir de los logs.

---

## 🌐 Acceder al Servidor

### Interfaz Web
Abre tu navegador en: **http://localhost:8080**

### Endpoint de Metadatos (CapabilityStatement)
```
http://localhost:8080/fhir/metadata
```

---

## 🗄️ Acceder a la Base de Datos PostgreSQL

### Credenciales de Conexión
```
Host:           localhost
Puerto:         5432
Base de datos:  hapi
Usuario:        admin
Contraseña:     admin
```

### Desde línea de comandos
```powershell
docker exec -it hapi-fhir-postgres psql -U admin -d hapi
```

### Consultas útiles SQL
```sql
-- Ver todas las tablas
\dt

-- Ver tipos de recursos almacenados
SELECT RES_TYPE, COUNT(*) FROM HFJ_RESOURCE GROUP BY RES_TYPE;

-- Ver pacientes
SELECT * FROM HFJ_RESOURCE WHERE RES_TYPE = 'Patient' LIMIT 10;

-- Salir de psql
\q
```

---

## 📤 Enviar Recursos FHIR

### Ejemplo 1: Crear un Paciente con cURL
```powershell
curl -X POST http://localhost:8080/fhir/Patient `
  -H "Content-Type: application/fhir+json" `
  -d '{
  "resourceType": "Patient",
  "name": [
    {
      "family": "García",
      "given": ["Carlos", "Alberto"]
    }
  ],
  "gender": "male",
  "birthDate": "1990-05-15",
  "telecom": [
    {
      "system": "phone",
      "value": "+57 300 123 4567"
    }
  ],
  "address": [
    {
      "use": "home",
      "city": "Bogotá",
      "country": "Colombia"
    }
  ]
}'
```

### Ejemplo 2: Crear un Paciente con PowerShell
```powershell
$headers = @{
    "Content-Type" = "application/fhir+json"
}

$body = @{
    resourceType = "Patient"
    name = @(
        @{
            family = "Rodríguez"
            given = @("María", "Elena")
        }
    )
    gender = "female"
    birthDate = "1985-03-20"
} | ConvertTo-Json -Depth 10

$response = Invoke-RestMethod -Uri "http://localhost:8080/fhir/Patient" -Method Post -Headers $headers -Body $body
$response | ConvertTo-Json -Depth 10
```

### Ejemplo 3: Buscar Pacientes
```powershell
# Buscar todos los pacientes
curl http://localhost:8080/fhir/Patient

# Buscar por nombre
curl "http://localhost:8080/fhir/Patient?name=García"

# Buscar por género
curl "http://localhost:8080/fhir/Patient?gender=male"
```

### Ejemplo 4: Obtener un Paciente Específico
```powershell
# Reemplaza '1' con el ID del paciente
curl http://localhost:8080/fhir/Patient/1
```

---

## 📊 Ejemplos de Otros Recursos FHIR

### Crear una Observación (resultado de laboratorio)
```powershell
curl -X POST http://localhost:8080/fhir/Observation `
  -H "Content-Type: application/fhir+json" `
  -d '{
  "resourceType": "Observation",
  "status": "final",
  "code": {
    "coding": [{
      "system": "http://loinc.org",
      "code": "15074-8",
      "display": "Glucosa en sangre"
    }]
  },
  "subject": {
    "reference": "Patient/1"
  },
  "effectiveDateTime": "2025-11-28T10:00:00Z",
  "valueQuantity": {
    "value": 95,
    "unit": "mg/dL",
    "system": "http://unitsofmeasure.org",
    "code": "mg/dL"
  }
}'
```

### Crear una Cita Médica
```powershell
curl -X POST http://localhost:8080/fhir/Appointment `
  -H "Content-Type: application/fhir+json" `
  -d '{
  "resourceType": "Appointment",
  "status": "booked",
  "description": "Consulta de control",
  "start": "2025-12-01T10:00:00Z",
  "end": "2025-12-01T10:30:00Z",
  "participant": [{
    "actor": {
      "reference": "Patient/1"
    },
    "status": "accepted"
  }]
}'
```

---

## 🛑 Detener el Servidor

### Detener los contenedores
```powershell
docker compose stop
```

### Detener y eliminar los contenedores (mantiene los datos en el volumen)
```powershell
docker compose down
```

### Detener, eliminar contenedores Y BORRAR TODOS LOS DATOS
```powershell
docker compose down -v
```
⚠️ **ADVERTENCIA**: El flag `-v` eliminará toda la información de la base de datos.

---

## 🔄 Reiniciar el Servidor

```powershell
docker compose restart
```

O simplemente:
```powershell
docker compose down
docker compose up -d
```

---

## 📝 Ver Logs en Tiempo Real

### Logs del servidor FHIR
```powershell
docker logs hapi-fhir-server -f
```

### Logs de PostgreSQL
```powershell
docker logs hapi-fhir-postgres -f
```

### Logs de ambos contenedores
```powershell
docker compose logs -f
```

---

## 🔍 Comandos Útiles de Diagnóstico

### Ver el estado de los contenedores
```powershell
docker ps -a
```

### Ver uso de recursos
```powershell
docker stats
```

### Inspeccionar un contenedor
```powershell
docker inspect hapi-fhir-server
```

### Entrar al contenedor del servidor
```powershell
docker exec -it hapi-fhir-server /bin/sh
```

---

## 🐛 Solución de Problemas

### El servidor no inicia
1. Verifica que Docker Desktop esté corriendo
2. Verifica que los puertos 8080 y 5432 no estén en uso:
   ```powershell
   netstat -ano | findstr :8080
   netstat -ano | findstr :5432
   ```

### No puedo conectarme al servidor
1. Espera unos 60 segundos después de ejecutar `docker compose up -d`
2. Verifica los logs: `docker logs hapi-fhir-server`
3. Asegúrate de que el contenedor esté corriendo: `docker ps`

### Error de base de datos
1. Verifica que el contenedor de PostgreSQL esté corriendo
2. Reinicia los contenedores:
   ```powershell
   docker compose restart
   ```

### Limpiar y empezar de nuevo
```powershell
docker compose down -v
docker compose up -d
```

---

## 📚 Recursos Adicionales

- **Documentación HAPI FHIR**: https://hapifhir.io/hapi-fhir/docs/
- **Especificación FHIR R4**: https://www.hl7.org/fhir/
- **Interfaz Web**: http://localhost:8080
- **Swagger/OpenAPI**: http://localhost:8080/fhir/swagger-ui/

---

## 💡 Notas Importantes

1. **Los datos persisten** entre reinicios gracias al volumen Docker `hapi-fhir-postgres`
2. El servidor usa **FHIR R4** por defecto
3. La primera vez que se levanta el servidor, puede tardar más tiempo mientras crea las tablas en la base de datos
4. Puedes acceder al servidor desde otras máquinas en tu red usando tu IP local en lugar de `localhost`

---

**¡Listo! 🎉** Ya tienes todo lo necesario para trabajar con tu servidor FHIR.

