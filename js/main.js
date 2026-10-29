/**
 * STANDARD WORK · DARNEL GROUP
 * Scripts interactivos para la Landing Page de descarga APK
 */

document.addEventListener('DOMContentLoaded', () => {
    // 1. Acordeón interactivo para Preguntas Frecuentes (FAQ)
    const faqItems = document.querySelectorAll('.faq-item');

    faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');
        question.addEventListener('click', () => {
            const isActive = item.classList.contains('active');

            // Cerrar los demás acordeones para mantener orden visual
            faqItems.forEach(otherItem => {
                otherItem.classList.remove('active');
            });

            // Alternar estado del seleccionado
            if (!isActive) {
                item.classList.add('active');
            }
        });
    });

    // 2. Manejo y telemetría visual para botones de descarga
    const downloadButtons = document.querySelectorAll('.btn-download-action');

    downloadButtons.forEach(btn => {
        btn.addEventListener('click', (e) => {
            // Animación suave de confirmación en el botón
            const originalText = btn.innerHTML;
            btn.style.opacity = '0.9';
            btn.style.transform = 'scale(0.98)';

            setTimeout(() => {
                btn.style.opacity = '1';
                btn.style.transform = '';
            }, 300);

            // Mostrar toast discreto con recomendación para Android
            showNotificationToast('Redirigiendo a Google Drive para descargar APK...');
        });
    });

    // 3. Sistema de notificación Toast discreto
    function showNotificationToast(message) {
        let toast = document.getElementById('sw-toast');
        if (!toast) {
            toast = document.createElement('div');
            toast.id = 'sw-toast';
            toast.style.position = 'fixed';
            toast.style.bottom = '24px';
            toast.style.right = '24px';
            toast.style.background = '#002F6C';
            toast.style.color = '#FFFFFF';
            toast.style.padding = '12px 20px';
            toast.style.borderRadius = '10px';
            toast.style.boxShadow = '0 10px 25px rgba(0, 47, 108, 0.4)';
            toast.style.fontSize = '14px';
            toast.style.fontWeight = '600';
            toast.style.zIndex = '9999';
            toast.style.display = 'flex';
            toast.style.alignItems = 'center';
            toast.style.gap = '10px';
            toast.style.transition = 'all 0.3s ease';
            toast.style.opacity = '0';
            toast.style.transform = 'translateY(20px)';
            document.body.appendChild(toast);
        }

        toast.innerHTML = `
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#38BDF8" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                <polyline points="7 10 12 15 17 10"></polyline>
                <line x1="12" y1="15" x2="12" y2="3"></line>
            </svg>
            <span>${message}</span>
        `;

        requestAnimationFrame(() => {
            toast.style.opacity = '1';
            toast.style.transform = 'translateY(0)';
        });

        setTimeout(() => {
            toast.style.opacity = '0';
            toast.style.transform = 'translateY(20px)';
        }, 4000);
    }
});
