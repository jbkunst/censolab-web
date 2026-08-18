(() => {
  const updateLogo = () => {
    const reveal = document.querySelector(".reveal");
    const slide = window.Reveal?.getCurrentSlide?.();

    if (!reveal || !slide) return;

    const forceTeal = slide.classList.contains("logo-teal");
    const useWhite = !forceTeal && (
      slide.id === "title-slide" ||
      slide.classList.contains("dark") ||
      slide.classList.contains("inverse") ||
      slide.classList.contains("logo-white")
    );

    reveal.classList.toggle("cl-logo-white", useWhite);
  };

  if (window.Reveal) {
    window.Reveal.on("ready", updateLogo);
    window.Reveal.on("slidechanged", updateLogo);
  }

  window.addEventListener("load", updateLogo);
})();
