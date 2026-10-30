# Standard Work · Darnel Group — Portal de Descarga APK

Subcarpeta web corporativa, responsiva y autónoma para la presentación y distribución del archivo instalador **APK Android** de la aplicación **Standard Work** (Darnel Group).

---

## 📁 Estructura del Directorio

```text
descargar-app/
│
├── index.html          # Página principal de presentación y descarga de la APK
├── prueba.html         # Prototipo interactivo HTML original con barra de retorno integrada
│
├── css/
│   └── styles.css      # Estilos corporativos (Darnel Blue, Glassmorphism, Responsive)
│
├── js/
│   └── main.js         # Lógica interactiva (FAQ acordeón, telemetría y animaciones de descarga)
│
├── assets/
│   └── app_icon.png    # Icono corporativo oficial en alta resolución
│
└── README.md           # Guía de uso, pruebas locales y publicación
```

---

## 🚀 Cómo Probar la Página Localmente

### Opción 1: Abrir directamente en el navegador
Haz doble clic sobre el archivo `descargar-app/index.html` o ábrelo con Google Chrome, Microsoft Edge, Firefox o Safari.

### Opción 2: Usar un servidor web local
Desde una terminal en la carpeta del proyecto:

```bash
# Con Python 3
cd "descargar-app"
python -m http.server 8080

# O con Node.js / npx
npx serve .
```
Luego accede a `http://localhost:8080`.

---

## 🌐 Cómo Publicar y Compartir el Enlace

Esta subcarpeta es **100% estática y autónoma** (no depende de ningún servidor de base de datos ni backend). Puedes publicarla en cualquiera de las siguientes plataformas gratuitas:

### 1. GitHub Pages (Recomendado)
1. Sube tu proyecto a un repositorio en GitHub.
2. Ve a **Settings** > **Pages**.
3. Selecciona la rama principal (`main` o `master`) y la carpeta raíz o `/docs` (puedes renombrar o copiar `descargar-app` a `docs` para que GitHub Pages la sirva directamente).
4. GitHub te entregará un enlace público inmediato tipo `https://tu-usuario.github.io/tu-repositorio/descargar-app/`.

### 2. Vercel o Netlify
- Arrastra la carpeta `descargar-app` a la interfaz web de [Netlify Drop](https://app.netlify.com/drop) o vincúlala en [Vercel](https://vercel.com).
- En menos de 10 segundos tendrás una URL pública HTTPS (`https://standard-work-darnel.netlify.app`) lista para compartir por WhatsApp, correo corporativo o Teams.

---

## 📲 Enlace de la APK Configurado

El botón principal de descarga está enlazado a la APK en Google Drive:
- **URL configurada:** [Google Drive APK Standard Work](https://drive.google.com/file/d/1UpShl1PM4BEjNxLTYKXEELd1HL-XYhmB/view?usp=drive_link)
- Se abre en pestaña segura (`target="_blank" rel="noopener noreferrer"`) asegurando compatibilidad con la interfaz de descarga de Google Drive en Android.
