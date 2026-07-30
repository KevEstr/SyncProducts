"""
Service Wrapper - Sincronización Shopify Centro Japón
Ejecuta sync_shopify_products.py en un horario programado.
"""
import os
import sys
import time
import json
import logging
import threading
import schedule
from datetime import datetime
from dotenv import load_dotenv

# Cargar variables de entorno desde .env
load_dotenv()

# ══════════════════════════════════════════════
#  CONFIGURACIÓN DEL HORARIO
# ══════════════════════════════════════════════
# Cambia esta hora según necesites (formato 24h: "HH:MM")
HORA_EJECUCION = os.getenv('SYNC_HORA', '23:59')  # Por defecto 23:59 (11:59 PM)
MONITOR_PORT   = int(os.getenv('MONITOR_PORT', '8091'))

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


def iniciar_monitor():
    """Inicia servidor Flask de monitoreo en un hilo separado."""
    try:
        from flask import Flask, jsonify
        app = Flask(__name__)
        base_dir = os.path.dirname(os.path.abspath(__file__))

        @app.route('/status', methods=['GET'])
        def status():
            status_file = os.path.join(base_dir, 'status.json')
            if not os.path.exists(status_file):
                return jsonify({"estado": "sin_datos", "mensaje": "Aún no se ha ejecutado ninguna sincronización"}), 200
            with open(status_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            return jsonify(data), 200

        @app.route('/status/errores', methods=['GET'])
        def status_errores():
            status_file = os.path.join(base_dir, 'status.json')
            if not os.path.exists(status_file):
                return jsonify({"estado": "sin_datos"}), 200
            with open(status_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            solo_errores = [p for p in data.get('detalle', []) if p.get('accion') == 'ERROR']
            return jsonify({
                "ultima_sincronizacion": data.get('ultima_sincronizacion'),
                "total_errores": len(solo_errores),
                "errores": solo_errores
            }), 200

        @app.route('/logs', methods=['GET'])
        def logs():
            log_file = os.path.join(base_dir, 'sync.log')
            if not os.path.exists(log_file):
                return jsonify({"error": "sync.log no encontrado"}), 404
            with open(log_file, 'r', encoding='utf-8') as f:
                lineas = f.readlines()
            # Últimas 500 líneas para no saturar
            return jsonify({"lineas": [l.rstrip() for l in lineas[-500:]]}), 200

        @app.route('/health', methods=['GET'])
        def health():
            return jsonify({"servicio": "ShopifySyncCentroJapon", "estado": "running"}), 200

        log.info(f"Monitor HTTP iniciado en http://0.0.0.0:{MONITOR_PORT}")
        log.info(f"  /status  → resumen última sincronización")
        log.info(f"  /logs    → últimas 500 líneas del log")
        log.info(f"  /health  → estado del servicio")
        # use_reloader=False y threaded=True para que funcione en hilo
        app.run(host='0.0.0.0', port=MONITOR_PORT, use_reloader=False, threaded=True)
    except Exception as e:
        log.error(f"Error al iniciar monitor HTTP: {e}")


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
    log.info(f"  • Horario: Todos los días a las {HORA_EJECUCION}")
    log.info("  • Script: sync_shopify_products.py")
    log.info("")
    log.info("Servicio iniciado correctamente")
    log.info("Esperando horario programado...")
    log.info("")
    
    # Programar ejecución diaria
    schedule.every().day.at(HORA_EJECUCION).do(ejecutar_sincronizacion)

    # Iniciar monitor HTTP en hilo separado
    hilo_monitor = threading.Thread(target=iniciar_monitor, daemon=True)
    hilo_monitor.start()
    
    # Mostrar próxima ejecución
    proxima = schedule.next_run()
    if proxima:
        log.info(f"Próxima ejecución programada: {proxima.strftime('%Y-%m-%d %H:%M:%S')}")
    
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
