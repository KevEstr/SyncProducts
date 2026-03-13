"""
Service Wrapper - Sincronización Shopify Centro Japón
Ejecuta sync_shopify_products.py en un horario programado.
"""
import os
import sys
import time
import logging
import schedule
from datetime import datetime

# Asegurar que el directorio de trabajo sea el del script
os.chdir(os.path.dirname(os.path.abspath(__file__)))

# Configurar logging
log_dir = os.path.join(os.path.dirname(__file__), 'logs')
os.makedirs(log_dir, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler(os.path.join(log_dir, 'service.log'), encoding='utf-8')
    ]
)
log = logging.getLogger(__name__)


def ejecutar_sincronizacion():
    """Ejecuta el script de sincronización."""
    log.info("=" * 70)
    log.info("INICIANDO SINCRONIZACIÓN PROGRAMADA")
    log.info(f"Fecha y hora: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    log.info("=" * 70)
    
    try:
        # Importar y ejecutar la sincronización
        import sync_shopify_products
        sync_shopify_products.sincronizar()
        
        log.info("Sincronización completada exitosamente")
        
    except Exception as e:
        log.error(f"Error durante la sincronización: {e}", exc_info=True)
    
    log.info("=" * 70)


def main():
    """Función principal del servicio."""
    log.info("╔" + "═" * 68 + "╗")
    log.info("║" + " " * 10 + "SERVICIO DE SINCRONIZACIÓN SHOPIFY - CENTRO JAPÓN" + " " * 8 + "║")
    log.info("╚" + "═" * 68 + "╝")
    log.info("")
    log.info("Configuración:")
    log.info("  • Horario: Todos los días a las 23:59 (11:59 PM)")
    log.info("  • Script: sync_shopify_products.py")
    log.info("")
    log.info("Servicio iniciado correctamente")
    log.info("Esperando horario programado...")
    log.info("")
    
    # Programar ejecución diaria a las 23:59
    schedule.every().day.at("23:59").do(ejecutar_sincronizacion)
    
    # Loop principal del servicio
    while True:
        try:
            schedule.run_pending()
            time.sleep(30)  # Verificar cada 30 segundos
            
        except KeyboardInterrupt:
            log.info("Servicio detenido por el usuario")
            break
            
        except Exception as e:
            log.error(f"Error en el loop del servicio: {e}", exc_info=True)
            time.sleep(60)  # Esperar 1 minuto antes de reintentar


if __name__ == '__main__':
    main()
