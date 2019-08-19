(() => {
  let datenow = new Date()
  document.addEventListener('DOMContentLoaded', () => {
    let elems = document.querySelectorAll('.datepicker');
    let instances = M.Datepicker.init(elems, {
      defaultDate: datenow,
      minDate: datenow,
      format: 'dd.mm',
      i18n: {
        cancel: 'Отмена',
        clear: 'Сбросить',
        done: 'Выбрать',
        months: [
          'Январь',
          'Февраль',
          'Март',
          'Апрель',
          'Май',
          'Июнь',
          'Июль',
          'Август',
          'Сентябрь',
          'Октябрь',
          'Ноябрь',
          'Декабрь'
        ],
        monthsShort: [
          'Янв',
          'Фев',
          'Мар',
          'Апр',
          'Май',
          'Июн',
          'Июл',
          'Авг',
          'Сен',
          'Окт',
          'Ноя',
          'Дек'
        ],
        weekdays: [
          'Воскресенье',
          'Понедельник',
          'Вторник',
          'Среда',
          'Четверг',
          'Пятница',
          'Суббота'
        ],
        weekdaysShort: [
          'Вс',
          'Пн',
          'Вт',
          'Ср',
          'Чт',
          'Пт',
          'Сб'
        ],
        weekdaysAbbrev: [
          'В', 'П', 'В', 'С', 'Ч', 'П', 'С'
        ]
      }
    });
  });
  let is_up = false
  $('#btn-up').click(ev => {
    $('footer').css({
      bottom: is_up ? '-559px' : '0'
    })
    $('#btn-up').find('i').text(is_up ? 'expand_less' : 'expand_more')
    is_up = !is_up
  })
  $(document).ready(() => {
    $('.tabs').tabs();
  });
  document.addEventListener('DOMContentLoaded', () => {
    let elems = document.querySelectorAll('.timepicker');
    let instances = M.Timepicker.init(elems, {});
  });
  document.addEventListener('DOMContentLoaded', function () {
    let elems = document.querySelectorAll('select');
    let instances = M.FormSelect.init(elems, {});
  });
  mapboxgl.accessToken = 'pk.eyJ1Ijoic2l5ZXQiLCJhIjoiY2p6Zm03cGk3MDVhbjNwbmd1cnByeHZ0ZyJ9.iQvODTY9195fwmOd9Pzwuw';
  let map = new mapboxgl.Map({
    container: 'map',
    style: 'mapbox://styles/mapbox/light-v10',
    center: [37.64957747842482, 55.732901766080545],
    zoom: 15,
    antialias: true,
    interactive: true
  });
  map.on('load', async () => {
    let layers = map.getStyle().layers;

    let labelLayerId;
    for (let i = 0; i < layers.length; i++) {
      if (layers[i].type === "symbol" && layers[i].layout["text-field"]) {
        labelLayerId = layers[i].id;
        break;
      }
    }
    let resp = await axios.get(
      "http://tseluyko.ru:8529/_db/sky_tech/api/helipads"
    );
    console.log(resp);
    // new mapboxgl.Marker()
    // Mapbox.Marker()
    //   .setLngLat([37.6499424, 55.7331183])
    //   .addTo(map);
    map.addSource("markers", {
      "type": "geojson",
      "data": {
        "type": "FeatureCollection",
        "features": [{
          "type": "Feature",
          "geometry": {
            "type": "Point",
            "coordinates": [7.4368330, 46.9516040]
          },
          "properties": {
            "title": "Duotones",
            "marker-symbol": "marker",
          }
        }]
      }
    });

    map.addLayer({
      "id": "markers",
      "type": "symbol",
      "source": "markers",
      "layout": {
        "icon-image": "{marker-symbol}-15",
        "icon-size": 3
      }
    });
    let lines = await this.axios.get('http://tseluyko.ru:8529/_db/sky_tech/dev-api/route')
    console.log("lines", lines)
    // map.addLayer({
    //   "id": "route",
    //   "type": "line",
    //   "source": {
    //     "type": "geojson",
    //     "data": {
    //       "type": "Feature",
    //       "properties": {},
    //       "geometry": {
    //         "type": "LineString",
    //         "coordinates": await axios.get('http://tseluyko.ru:8529/_db/sky_tech/dev-api/route/1795484').then(_resp => _resp.data.geo.coordinates)
    //       }
    //     }
    //   },
    //   "layout": {
    //     "line-join": "round",
    //     "line-cap": "round"
    //   },
    //   "paint": {
    //     "line-color": "#888",
    //     "line-width": 4
    //   }
    // });


    map.addLayer({
        id: "3d-buildings",
        source: "composite",
        "source-layer": "building",
        filter: ["==", "extrude", "true"],
        type: "fill-extrusion",
        minzoom: 15,
        paint: {
          "fill-extrusion-color": "#aaa",

          // use an 'interpolate' expression to add a smooth transition effect to the
          // buildings as the user zooms in
          "fill-extrusion-height": [
            "interpolate",
            ["linear"],
            ["zoom"],
            15,
            0,
            15.05,
            ["get", "height"]
          ],
          "fill-extrusion-base": [
            "interpolate",
            ["linear"],
            ["zoom"],
            15,
            0,
            15.05,
            ["get", "min_height"]
          ],
          "fill-extrusion-opacity": 0.6
        }
      },
      labelLayerId
    );
    // map.addLayer({
    //   id: "points",
    //   type: "symbol",
    //   source: {
    //     type: "geojson",
    //     data: {
    //       type: "FeatureCollection",
    //       features: resp.data.map(_point => ({
    //         type: "Feature",
    //         geometry: {
    //           type: "Point",
    //           coordinates: [_point.geo.coordinates[0], _point.geo.coordinates[1]]
    //         },
    //         properties: {
    //           title: _point.name,
    //           icon: {
    //             iconSize: [48, 48], // size of the icon
    //             iconAnchor: [24, 24], // point of the icon which will correspond to marker's location
    //             popupAnchor: [0, -24], // point from which the popup should open relative to the iconAnchor
    //             className: 'helipad-marker'
    //           }
    //         }
    //       }))
    //     }
    //   },
    //   layout: {
    //     "text-field": "{title}",
    //     "text-offset": [0, 0.6],
    //     "text-anchor": "top",
    //     "text-size": 13
    //   }
    // });
  })
})()