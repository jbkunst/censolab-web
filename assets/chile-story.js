(() => {
  const TOTAL = 18480432;

  const regions = {
    arica: {
      name: "Arica y Parinacota",
      population: 244569,
      change: 9.8,
      note: "El extremo norte reúne algo más de 244 mil residentes habituales."
    },
    tarapaca: {
      name: "Tarapacá",
      population: 369806,
      change: 14.8,
      note: "Fue la región con mayor crecimiento poblacional entre 2017 y 2024."
    },
    antofagasta: {
      name: "Antofagasta",
      population: 635416,
      change: 9.9,
      note: "Su población residente habitual supera las 635 mil personas."
    },
    atacama: {
      name: "Atacama",
      population: 299180,
      change: 5.1,
      note: "Cerca de 300 mil personas residen habitualmente en la región."
    },
    coquimbo: {
      name: "Coquimbo",
      population: 832864,
      change: 11.2,
      note: "Registró el segundo mayor crecimiento regional desde 2017."
    },
    valparaiso: {
      name: "Valparaíso",
      population: 1896053,
      change: 6.3,
      note: "Es la segunda región más poblada y presenta el mayor índice de envejecimiento del país."
    },
    metropolitana: {
      name: "Metropolitana de Santiago",
      population: 7400741,
      change: 5.3,
      note: "Concentra aproximadamente el 40% de la población del país."
    },
    ohiggins: {
      name: "O’Higgins",
      population: 987228,
      change: 9.4,
      note: "Se aproxima al millón de residentes habituales."
    },
    maule: {
      name: "Maule",
      population: 1123008,
      change: 8.8,
      note: "Es una de las cinco regiones que superan el millón de habitantes."
    },
    nuble: {
      name: "Ñuble",
      population: 512289,
      change: 8.0,
      note: "Supera el medio millón de residentes habituales."
    },
    biobio: {
      name: "Biobío",
      population: 1613059,
      change: 4.3,
      note: "Es la tercera región con mayor población del país."
    },
    araucania: {
      name: "La Araucanía",
      population: 1010423,
      change: 7.4,
      note: "En 2024 superó por primera vez el millón de habitantes."
    },
    losrios: {
      name: "Los Ríos",
      population: 398230,
      change: 5.8,
      note: "Cerca de 400 mil personas residen habitualmente en la región."
    },
    loslagos: {
      name: "Los Lagos",
      population: 890284,
      change: 9.1,
      note: "Su población residente habitual se acerca a las 900 mil personas."
    },
    aysen: {
      name: "Aysén",
      population: 100745,
      change: 1.3,
      note: "Registró el menor crecimiento regional entre 2017 y 2024."
    },
    magallanes: {
      name: "Magallanes y de la Antártica Chilena",
      population: 166537,
      change: 3.3,
      note: "Es una de las regiones con menor crecimiento poblacional desde 2017."
    }
  };

  const normalize = (value) => String(value || "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase();

  function regionKey(name) {
    const value = normalize(name);
    if (value.includes("arica")) return "arica";
    if (value.includes("tarapaca")) return "tarapaca";
    if (value.includes("antofagasta")) return "antofagasta";
    if (value.includes("atacama")) return "atacama";
    if (value.includes("coquimbo")) return "coquimbo";
    if (value.includes("valparaiso")) return "valparaiso";
    if (value.includes("metropolitana") || value.includes("santiago")) return "metropolitana";
    if (value.includes("higgins")) return "ohiggins";
    if (value.includes("maule")) return "maule";
    if (value.includes("nuble")) return "nuble";
    if (value.includes("biobio")) return "biobio";
    if (value.includes("araucania")) return "araucania";
    if (value.includes("los rios")) return "losrios";
    if (value.includes("los lagos")) return "loslagos";
    if (value.includes("aysen") || value.includes("aisen")) return "aysen";
    if (value.includes("magallanes")) return "magallanes";
    return null;
  }

  const formatNumber = new Intl.NumberFormat("es-CL");
  const formatDecimal = new Intl.NumberFormat("es-CL", {
    minimumFractionDigits: 1,
    maximumFractionDigits: 1
  });

  function tooltipHTML(point) {
    const stats = point.custom && point.custom.region;
    if (!stats) {
      return `<div class="cl-map-tooltip"><div class="cl-map-tooltip__name">${point.name || "Chile"}</div></div>`;
    }

    const share = (stats.population / TOTAL) * 100;

    return `
      <div class="cl-map-tooltip">
        <div class="cl-map-tooltip__name">${stats.name}</div>
        <div class="cl-map-tooltip__label">Población residente habitual · 2024</div>
        <div class="cl-map-tooltip__value">${formatNumber.format(stats.population)}</div>
        <div class="cl-map-tooltip__meta">
          ${formatDecimal.format(share)}% del país · +${formatDecimal.format(stats.change)}% desde 2017
        </div>
        <div class="cl-map-tooltip__note">${stats.note}</div>
      </div>`;
  }

  function buildMap() {
    const container = document.getElementById("cl-chile-map");
    if (!container || !window.Highcharts) return;

    const mapData = Highcharts.maps && Highcharts.maps["countries/cl/cl-all"];
    if (!mapData) {
      container.innerHTML = '<p class="cl-map-error">No fue posible cargar el mapa.</p>';
      return;
    }

    Highcharts.mapChart(container, {
      chart: {
        map: mapData,
        backgroundColor: "transparent",
        animation: false,
        spacing: [8, 8, 8, 8],
        style: {
          fontFamily: '"IBM Plex Sans", system-ui, sans-serif'
        },
        events: {
          load() {
            const series = this.series[0];
            series.points.forEach((point) => {
              const key = regionKey(point.name);
              const region = key ? regions[key] : null;
              point.update({
                value: region ? 1 : null,
                custom: { region }
              }, false);
            });
            this.redraw(false);
          }
        }
      },

      title: { text: null },
      credits: { enabled: false },
      legend: { enabled: false },
      exporting: { enabled: false },
      mapNavigation: { enabled: false },

      tooltip: {
        enabled: true,
        useHTML: true,
        outside: false,
        padding: 0,
        borderWidth: 0,
        borderRadius: 8,
        backgroundColor: "rgba(255,255,255,0.98)",
        shadow: {
          color: "rgba(15, 23, 42, 0.14)",
          offsetX: 0,
          offsetY: 6,
          opacity: 0.18,
          width: 10
        },
        formatter() {
          return tooltipHTML(this.point);
        }
      },

      plotOptions: {
        map: {
          animation: false,
          enableMouseTracking: true,
          nullInteraction: true,
          borderColor: "rgba(14, 79, 90, 0.42)",
          borderWidth: 0.8,
          color: "rgba(63, 113, 128, 0.20)",
          nullColor: "rgba(63, 113, 128, 0.20)",
          states: {
            hover: {
              color: "#0E4F5A",
              borderColor: "#FFFFFF",
              borderWidth: 1.4,
              brightness: 0
            },
            inactive: {
              opacity: 1
            }
          }
        }
      },

      series: [{
        name: "Regiones de Chile",
        mapData,
        data: [],
        allAreas: true,
        joinBy: "hc-key"
      }]
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", buildMap, { once: true });
  } else {
    buildMap();
  }
})();
