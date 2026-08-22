(() => {
  const updateLogo = () => {
    const reveal = document.querySelector(".reveal");
    const slide = window.Reveal?.getCurrentSlide?.();

    if (!reveal || !slide) return;

    const isSection = slide.classList.contains("section-slide");
    const hasSectionImage = slide.classList.contains("has-image");
    const useInverseChrome = isSection || hasSectionImage;
    const sectionImage = hasSectionImage
      ? getComputedStyle(slide).getPropertyValue("--section-image").trim()
      : "none";

    reveal.classList.toggle("cl-logo-white", useInverseChrome);
    reveal.classList.toggle("cl-section-active", useInverseChrome);
    document.body.classList.toggle("cl-section-active", useInverseChrome);
    reveal.classList.toggle("cl-section-has-image", hasSectionImage);
    document.body.classList.toggle("cl-section-has-image", hasSectionImage);
    reveal.style.setProperty("--active-section-image", sectionImage);
    document.body.style.setProperty("--active-section-image", sectionImage);
  };

  if (window.Reveal) {
    window.Reveal.on("ready", updateLogo);
    window.Reveal.on("slidechanged", updateLogo);
  }

  window.addEventListener("load", updateLogo);
})();
