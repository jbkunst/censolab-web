(() => {
  const updateLogo = () => {
    const logo = document.querySelector('.reveal .slide-logo');
    const slide = window.Reveal?.getCurrentSlide();
    if (!logo || !slide) return;

    const forceTeal = slide.classList.contains('logo-teal');
    const forceWhite = slide.classList.contains('logo-white');
    const useWhite = forceWhite || (!forceTeal && (
      slide.id === 'title-slide' ||
      slide.classList.contains('dark') ||
      slide.classList.contains('inverse')
    ));

    logo.style.setProperty(
      'filter',
      useWhite ? 'brightness(0) invert(1)' : 'none',
      'important'
    );
    logo.style.setProperty('opacity', '1', 'important');
  };

  const bind = () => {
    if (!window.Reveal) {
      window.setTimeout(bind, 50);
      return;
    }

    window.Reveal.on('ready', updateLogo);
    window.Reveal.on('slidechanged', updateLogo);
    updateLogo();
  };

  bind();
})();
