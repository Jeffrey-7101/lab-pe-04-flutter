# 🌿 Invernadero IoT – Flutter App

Esta aplicación Flutter se conecta con **Firebase Realtime Database** para monitorear un sistema de dispositivos IoT en tiempo real, visualizar métricas ambientales (como temperatura y humedad) y recibir notificaciones automáticas por fuera de rango.

---

## ✨ Características

- 🔐 **Autenticación con Firebase Auth** (Login/Registro)
- 📟 **Gestión de Dispositivos IoT**: Estado, sensores, último visto
- 📊 **Monitoreo en Tiempo Real**: Gráficas de temperatura y humedad
- 🔔 **Notificaciones Push**: Alertas automáticas al superar umbrales

---

## 🧱 Arquitectura del Proyecto

<img width="1565" height="1186" alt="Arquitectura PE" src="https://github.com/user-attachments/assets/7b986d35-1445-4d15-a9a6-9dc6bda26871" />

## ⚙️ CONFIGURACIÓN

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/Jeffrey-7101/lab-pe-04-flutter.git
   cd lab-pe-04-flutter

2. **Ignorar el archivo JSON de servicio**  
   Verifica que tu `.gitignore` incluya:
   ```
   invernadero-iot-dfa2f-firebase-adminsdk-*.json
   ```

3. **Agregar tu JSON de cuenta de servicio**  
   - Descarga la clave de Service Accounts desde Firebase Console. (Disponible aquí: https://drive.google.com/drive/folders/19dBn1eZeEuVNURSfUWAjGXnYC3aHlGaN?usp=sharing )  
   - Coloca el archivo `*.json` en la raíz del proyecto.

4. **Verificar `databaseURL`**  
   En `lib/firebase_options.dart`, comprueba que cada plataforma (`android`, `ios`, `web`) tenga tu `databaseURL`.

5. **Instalar dependencias**  
   ```bash
   flutter pub get
   ```

## 🚀 EJECUCIÓN

```bash
flutter clean
flutter run
```

Usa **hot restart** (⇧ R) tras cambios en inicialización de Firebase.

## 🔐 Cuenta de prueba

- Regístrate desde la vista de registro, **o** usa:
  - **Email**: `admin@gmail.com`
  - **Password**: `admin123`

## 👥 Participantes

- **Huashuayo Sivincha, Josue Daniel**
- **Kana Condori, Frank Jhonatan**
- **Pinto Ñaupa, Jeffrey Joan**
