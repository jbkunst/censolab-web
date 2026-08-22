(() => {
  const container = document.getElementById('cl-slide-map');
  if (!container || !window.maplibregl) return;

  const revealRoot = document.querySelector('.reveal');
  const slides = revealRoot?.querySelector(':scope > .slides');
  const mapLayer = container.closest('.cl-cover-map');

  if (revealRoot && slides && mapLayer) {
    revealRoot.insertBefore(mapLayer, slides);

    [...slides.children].forEach((slide) => {
      if (
        slide instanceof HTMLElement &&
        slide.matches('section:not(#title-slide)') &&
        !slide.textContent.trim() &&
        !slide.querySelector('img, video, iframe, canvas')
      ) {
        slide.remove();
      }
    });

    window.Reveal?.sync();
  }

  const updateCoverVisibility = () => {
    const currentSlide = window.Reveal?.getCurrentSlide();
    mapLayer?.classList.toggle('is-hidden', currentSlide?.id !== 'title-slide');
  };

  const stops = [
    { center: [-78.84, -33.64], zoom: 4, bearing: 0 },
    { center: [-70.31, -18.48], zoom: 6.1, bearing: -7 },
    { center: [-71.62, -33.05], zoom: 6.2, bearing: 5 },
    { center: [-73.05, -36.82], zoom: 6.1, bearing: -5 },
    { center: [-72.94, -41.47], zoom: 6.0, bearing: 6 },
    { center: [-70.91, -53.16], zoom: 5.8, bearing: -6 }
  ];

  const labels = [
    { name: 'Arica', coordinates: [-70.31, -18.48] },
    { name: 'Antofagasta', coordinates: [-70.40, -23.65] },
    { name: 'Valparaíso', coordinates: [-71.62, -33.05] },
    { name: 'Santiago', coordinates: [-70.67, -33.45] },
    { name: 'Concepción', coordinates: [-73.05, -36.82] },
    { name: 'Puerto Montt', coordinates: [-72.94, -41.47] },
    { name: 'Coyhaique', coordinates: [-72.07, -45.57] },
    { name: 'Punta Arenas', coordinates: [-70.91, -53.16] }
  ];

  const map = new maplibregl.Map({
    container,
    style: {
      version: 8,
      sources: {
        carto: {
          type: 'vector',
          url: 'https://tiles.basemaps.cartocdn.com/vector/carto.streets/v1/tiles.json',
          attribution: '&copy; CARTO · &copy; OpenStreetMap contributors'
        }
      },
      layers: [
        {
          id: 'territory-background',
          type: 'background',
          paint: { 'background-color': '#F4F4F1' }
        },
        {
          id: 'territory-water',
          type: 'fill',
          source: 'carto',
          'source-layer': 'water',
          paint: { 'fill-color': '#D9E4E7' }
        },
        {
          id: 'territory-state-boundaries',
          type: 'line',
          source: 'carto',
          'source-layer': 'boundary',
          minzoom: 3,
          filter: ['all', ['==', 'admin_level', 4], ['==', 'maritime', 0]],
          paint: {
            'line-color': '#90A5AA',
            'line-width': ['interpolate', ['linear'], ['zoom'], 3, 0.6, 8, 1.4],
            'line-opacity': 0.72
          }
        },
        {
          id: 'territory-country-boundaries',
          type: 'line',
          source: 'carto',
          'source-layer': 'boundary',
          filter: ['all', ['==', 'admin_level', 2], ['==', 'maritime', 0]],
          paint: {
            'line-color': '#607D84',
            'line-width': ['interpolate', ['linear'], ['zoom'], 3, 1, 8, 1.8],
            'line-opacity': 0.78
          }
        }
      ]
    },
    ...stops[0],
    pitch: 26,
    interactive: false,
    attributionControl: false,
    renderWorldCopies: false,
    fadeDuration: 0
  });

  let stopIndex = 0;
  let timer;
  const cameraOffset = () => [
    Math.min(container.clientWidth * 0.145, 260),
    Math.min(container.clientHeight * 0.015, 14)
  ];

  const travel = () => {
    stopIndex = (stopIndex + 1) % stops.length;
    map.flyTo({
      ...stops[stopIndex],
      offset: cameraOffset(),
      pitch: 30,
      duration: stopIndex === 0 ? 5600 : 4600,
      curve: 0.88,
      essential: false
    });
    timer = window.setTimeout(travel, 6800);
  };

  map.once('load', () => {
    map.easeTo({
      ...stops[0],
      offset: cameraOffset(),
      pitch: 26,
      duration: 0
    });

    window.requestAnimationFrame(() => map.resize());

    labels.forEach(({ name, coordinates }) => {
      const label = document.createElement('span');
      label.className = 'cl-slide-map-label';
      label.textContent = name;
      new maplibregl.Marker({ element: label, anchor: 'center' })
        .setLngLat(coordinates)
        .addTo(map);
    });

    if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      timer = window.setTimeout(travel, 4800);
    }
  });

  const resizeMap = () => window.requestAnimationFrame(() => map.resize());
  window.addEventListener('resize', resizeMap);
  window.Reveal?.on('ready', () => {
    resizeMap();
    updateCoverVisibility();
  });
  window.Reveal?.on('slidechanged', () => {
    resizeMap();
    updateCoverVisibility();
  });
  updateCoverVisibility();
  window.addEventListener('beforeunload', () => window.clearTimeout(timer));
})();