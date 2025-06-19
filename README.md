# Invernadero IoT Flutter App

Esta aplicación Flutter conecta con Firebase Realtime Database para monitorear dispositivos IoT, visualizar métricas de sensores en tiempo real y gestionar notificaciones.

## Descripción

- **Autenticación**: Firebase Auth con vistas de registro y login.
- **Dispositivos**: Lista de dispositivos con estado, último visto y sensores.
- **Monitoreo**: Gráficas en tiempo real de temperatura y humedad.
- **Notificaciones**: Alertas automáticas cuando un sensor sale de rango.

## Requisitos

- Flutter ≥ 3.8.0
- Android SDK o Xcode instalado
- Proyecto de Firebase con:
  - Realtime Database
  - Authentication habilitada
  - Clave de servicio JSON descargada (service-account-key.json)

## Configuración

1. **Clonar el repositorio**  
   ```bash
   git clone https://github.com/Jeffrey-7101/lab-pe-04-flutter.git
   cd lab-pe-04-flutter
   ```

2. **Ignorar el archivo JSON de servicio**  
   Verifica que tu `.gitignore` incluya:
   ```
   invernadero-iot-dfa2f-firebase-adminsdk-*.json
   ```

3. **Agregar tu JSON de cuenta de servicio**  
   - Descarga la clave de Service Accounts desde Firebase Console.  
   - Coloca el archivo `*.json` en la raíz del proyecto.

4. **Verificar `databaseURL`**  
   En `lib/firebase_options.dart`, comprueba que cada plataforma (`android`, `ios`, `web`) tenga tu `databaseURL`.

5. **Instalar dependencias**  
   ```bash
   flutter pub get
   ```

## Ejecución

```bash
flutter clean
flutter run
```

Usa **hot restart** (⇧ R) tras cambios en inicialización de Firebase.

## Cuenta de prueba

- Regístrate desde la vista de registro, **o** usa:
  - **Email**: `admin@gmail.com`
  - **Password**: `admin123`

## Simulador de datos

Para pruebas sin hardware, ejecuta:

```bash
python simulate_rtdb.py
```

Asegúrate de haber activado tu virtualenv e instalado `firebase-admin`.

## Podar notificaciones

La app mantiene sólo las 5 últimas notificaciones automáticamente.  

## Contribuciones

1. Fork del repositorio  
2. Crear una rama para tu feature  
3. Pull request describiendo cambios  

¡Gracias por colaborar!
