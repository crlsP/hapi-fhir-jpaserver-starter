# 🔑 Credenciales de Base de Datos PostgreSQL

## ✅ Credenciales CORRECTAS

```
Host:           localhost
Puerto:         5432
Base de datos:  hapi          ⚠️ NO "admin"
Usuario:        admin
Contraseña:     admin
```

---

## ❌ Errores Comunes

### Error 1: Base de datos incorrecta
**INCORRECTO**: Intentar conectarse a la base de datos `admin`  
**CORRECTO**: La base de datos se llama `hapi`

### Error 2: Usuario incorrecto
**INCORRECTO**: Intentar usar el usuario `postgres`  
**CORRECTO**: El usuario es `admin`

---

## 🔧 Formas de Conectarse

### 1. Desde PowerShell con psql (si tienes PostgreSQL instalado localmente)

```powershell
# Opción A: Con parámetros
psql -h localhost -p 5432 -U admin -d hapi

# Opción B: Con URL de conexión
psql postgresql://admin:admin@localhost:5432/hapi
```

**Cuando te pida la contraseña, escribe**: `admin`

---

### 2. Desde Docker (RECOMENDADO - siempre funciona)

```powershell
docker exec -it hapi-fhir-postgres psql -U admin -d hapi
```

**Una vez dentro de psql**, puedes ejecutar:

```sql
-- Ver información de conexión
\conninfo

-- Listar todas las bases de datos
\l

-- Listar todas las tablas
\dt

-- Ver recursos FHIR almacenados
SELECT RES_TYPE, COUNT(*) as cantidad 
FROM HFJ_RESOURCE 
GROUP BY RES_TYPE;

-- Ver pacientes
SELECT RES_ID, RES_TYPE, RES_VERSION, RES_UPDATED 
FROM HFJ_RESOURCE 
WHERE RES_TYPE = 'Patient';

-- Salir
\q
```

---

### 3. Con DBeaver (GUI)

1. Clic en **Nueva Conexión** → **PostgreSQL**
2. Configurar:
   - **Host**: `localhost`
   - **Puerto**: `5432`
   - **Database**: `hapi`
   - **Usuario**: `admin`
   - **Contraseña**: `admin`
3. **Test Connection** → **OK** → **Finish**

**Captura de configuración correcta:**
```
┌─────────────────────────────────────┐
│ Host:          localhost            │
│ Port:          5432                 │
│ Database:      hapi       ← ¡CLAVE! │
│ Username:      admin                │
│ Password:      admin                │
└─────────────────────────────────────┘
```

---

### 4. Con pgAdmin 4 (GUI)

1. Clic derecho en **Servers** → **Register** → **Server**
2. En la pestaña **General**:
   - **Name**: `HAPI FHIR Local`
3. En la pestaña **Connection**:
   - **Host name/address**: `localhost`
   - **Port**: `5432`
   - **Maintenance database**: `hapi`
   - **Username**: `admin`
   - **Password**: `admin`
   - ☑️ **Save password**
4. **Save**

---

### 5. Con Azure Data Studio

1. **Nueva Conexión**
2. **Connection type**: PostgreSQL
3. Configurar:
   - **Server**: `localhost`
   - **Authentication type**: Password
   - **User name**: `admin`
   - **Password**: `admin`
   - **Database**: `hapi`
   - **Port**: `5432`
4. **Connect**

---

### 6. Con DataGrip (JetBrains)

1. **Database** → **+** → **Data Source** → **PostgreSQL**
2. Configurar:
   - **Host**: `localhost`
   - **Port**: `5432`
   - **Database**: `hapi`
   - **User**: `admin`
   - **Password**: `admin`
3. **Test Connection** → **OK**

---

### 7. String de Conexión (para código)

**JDBC (Java)**
```java
String url = "jdbc:postgresql://localhost:5432/hapi";
String user = "admin";
String password = "admin";
```

**Python (psycopg2)**
```python
import psycopg2

conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="hapi",
    user="admin",
    password="admin"
)
```

**Node.js (pg)**
```javascript
const { Client } = require('pg');

const client = new Client({
  host: 'localhost',
  port: 5432,
  database: 'hapi',
  user: 'admin',
  password: 'admin',
});
```

**C# (.NET)**
```csharp
var connectionString = "Host=localhost;Port=5432;Database=hapi;Username=admin;Password=admin";
```

---

## 🔍 Verificar que el puerto está abierto

Desde PowerShell:

```powershell
# Ver si el puerto 5432 está escuchando
netstat -ano | findstr :5432

# Probar conectividad al puerto
Test-NetConnection -ComputerName localhost -Port 5432
```

Deberías ver que el puerto está `LISTENING` y la conexión es exitosa.

---

## 🐛 Solución de Problemas

### Problema 1: "database 'admin' does not exist"
**Solución**: Estás intentando conectarte a la base de datos incorrecta.  
La base de datos se llama `hapi`, no `admin`.

### Problema 2: "password authentication failed for user 'postgres'"
**Solución**: El usuario `postgres` no existe.  
Debes usar el usuario `admin`.

### Problema 3: "Connection refused"
**Solución**: 
1. Verifica que Docker Desktop esté corriendo
2. Verifica que el contenedor esté activo: `docker ps`
3. Si no está activo, inícialo: `docker compose up -d`

### Problema 4: "Port 5432 is already in use"
**Solución**: 
1. Hay otro PostgreSQL corriendo en tu máquina
2. Opciones:
   - Detén el otro PostgreSQL
   - Cambia el puerto en `docker-compose.yml` a `5433:5432`

---

## ✅ Test de Conexión Rápido

Ejecuta este comando para verificar que todo funciona:

```powershell
docker exec -it hapi-fhir-postgres psql -U admin -d hapi -c "SELECT version();"
```

Deberías ver la versión de PostgreSQL si todo está bien.

---

## 📊 Consultas Útiles

Una vez conectado, puedes ejecutar estas consultas:

```sql
-- 1. Ver cuántos recursos hay de cada tipo
SELECT RES_TYPE, COUNT(*) as total
FROM HFJ_RESOURCE
GROUP BY RES_TYPE
ORDER BY total DESC;

-- 2. Ver los pacientes más recientes
SELECT 
    RES_ID as id,
    RES_UPDATED as ultima_actualizacion
FROM HFJ_RESOURCE
WHERE RES_TYPE = 'Patient'
ORDER BY RES_UPDATED DESC
LIMIT 10;

-- 3. Ver el tamaño de las tablas
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 10;

-- 4. Ver todas las tablas HAPI
SELECT tablename 
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY tablename;
```

---

## 💡 Resumen de Credenciales

**Para recordar fácilmente:**

| Campo | Valor |
|-------|-------|
| Host | `localhost` |
| Puerto | `5432` |
| Base de datos | `hapi` ← ⚠️ **IMPORTANTE** |
| Usuario | `admin` |
| Contraseña | `admin` |

**URL completa:**
```
postgresql://admin:admin@localhost:5432/hapi
```

---

**¿Sigues teniendo problemas?** Prueba primero la conexión desde Docker:

```powershell
docker exec -it hapi-fhir-postgres psql -U admin -d hapi
```

Si esto funciona, el problema está en la herramienta o configuración que estás usando externamente.

