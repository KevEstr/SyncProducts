# Instalación del Servicio de Sincronización Shopify

## Descripción
Este servicio sincroniza automáticamente los productos desde la API de Centro Japón hacia Shopify todos los días a las **23:59 (11:59 PM)**.

## Requisitos Previos

1. **Python 3.8 o superior** instalado en el servidor
2. **Permisos de Administrador** en Windows
3. **Archivo .env configurado** con las credenciales de Shopify y la URL de la API

## Pasos de Instalación

### 1. Configurar Variables de Entorno

Copia el archivo `.env.example` a `.env` y completa los valores:

```env
SHOPIFY_STORE=tu-tienda.myshopify.com
SHOPIFY_CLIENT_ID=tu_client_id
SHOPIFY_CLIENT_SECRET=tu_client_secret
API_URL=http://tu-api.com/api/inventario
SYNC_LIMIT=0
```

### 2. Ejecutar el Instalador

1. Haz clic derecho en `instalar_servicio_shopify.bat`
2. Selecciona **"Ejecutar como administrador"**
3. Ingresa tus credenciales de Windows cuando se soliciten
4. Espera a que la instalación complete

### 3. Verificar la Instalación

El instalador realizará automáticamente:
- ✓ Detección de Python
- ✓ Creación del entorno virtual
- ✓ Instalación de dependencias
- ✓ Descarga de NSSM (gestor de servicios)
- ✓ Registro del servicio de Windows
- ✓ Inicio automático del servicio

## Gestión del Servicio

### Ver Estado del Servicio
```cmd
sc query ShopifySyncCentroJapon
```

### Iniciar el Servicio
```cmd
sc start ShopifySyncCentroJapon
```

### Detener el Servicio
```cmd
sc stop ShopifySyncCentroJapon
```

### Desinstalar el Servicio
```cmd
sc stop ShopifySyncCentroJapon
sc delete ShopifySyncCentroJapon
```

## Logs

El servicio genera varios archivos de log:

- `logs/service.log` - Log del wrapper del servicio
- `logs/service_out.log` - Salida estándar del servicio
- `logs/service_err.log` - Errores del servicio
- `sync.log` - Log detallado de cada sincronización

## Horario de Ejecución

El servicio ejecuta la sincronización **todos los días a las 23:59 (11:59 PM)**.

Para cambiar el horario, edita el archivo `service_wrapper.py` en la línea:
```python
schedule.every().day.at("23:59").do(ejecutar_sincronizacion)
```

Después de modificar, reinicia el servicio:
```cmd
sc stop ShopifySyncCentroJapon
sc start ShopifySyncCentroJapon
```

## Prueba Manual

Para probar la sincronización sin esperar al horario programado:

```cmd
venv\Scripts\python.exe sync_shopify_products.py
```

## Solución de Problemas

### El servicio no inicia
1. Verifica que el archivo `.env` existe y está configurado
2. Revisa los logs en `logs/service_err.log`
3. Verifica que las credenciales de Windows sean correctas

### La sincronización falla
1. Revisa `sync.log` para ver errores específicos
2. Verifica las credenciales de Shopify en `.env`
3. Verifica que la API de inventario esté accesible

### Cambiar credenciales del servicio
```cmd
sc stop ShopifySyncCentroJapon
tools\nssm\nssm.exe set ShopifySyncCentroJapon ObjectName "DOMINIO\Usuario" "Contraseña"
sc start ShopifySyncCentroJapon
```

## Arquitectura

```
instalar_servicio_shopify.bat  → Instalador del servicio
service_wrapper.py             → Wrapper con scheduler (cron)
sync_shopify_products.py       → Lógica de sincronización
.env                           → Configuración y credenciales
```

## Notas Importantes

- El servicio se inicia automáticamente con Windows
- Si el servicio falla, se reinicia automáticamente después de 10 segundos
- Los logs rotan automáticamente cuando alcanzan 10 MB
- El servicio corre bajo las credenciales del usuario especificado durante la instalación
