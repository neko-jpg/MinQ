(function () {
  let deferredPrompt;
  const banner = document.getElementById('pwa-install-banner');
  if (!banner) {
    return;
  }

  const installButton = banner.querySelector('button[data-action="install"]');
  const dismissButton = banner.querySelector('button[data-action="dismiss"]');

  const hideBanner = () => {
    banner.setAttribute('data-visible', 'false');
  };

  dismissButton?.addEventListener('click', () => {
    hideBanner();
    window.localStorage.setItem('minq-pwa-dismissed', Date.now().toString());
  });

  installButton?.addEventListener('click', async () => {
    if (!deferredPrompt) {
      return;
    }
    deferredPrompt.prompt();
    const { outcome } = await deferredPrompt.userChoice;
    if (outcome === 'accepted') {
      hideBanner();
    }
    deferredPrompt = null;
  });

  window.addEventListener('beforeinstallprompt', (event) => {
    event.preventDefault();
    const dismissedAt = Number(window.localStorage.getItem('minq-pwa-dismissed') ?? '0');
    const twentyFourHours = 24 * 60 * 60 * 1000;
    if (Date.now() - dismissedAt < twentyFourHours) {
      return;
    }
    deferredPrompt = event;
    banner.setAttribute('data-visible', 'true');
  });
})();
