'use strict';

angular.module('cleApp.directives', []).
  directive('googleMap', [function() {
    return {
      scope: { callback: '=' },
      restrict: 'A',
      link: function(scope, elm, attrs) {
        var styles = [
          {
            featureType:"administrative",
            stylers:[{visibility:"off"}]
          },
          {
            featureType:"poi",
            stylers:[{visibility:"simplified"}]
          },
          {
            featureType:"road",
            elementType:"labels",
            stylers:[{visibility:"simplified"}]
          },
          {
            featureType:"water",
            stylers:[{visibility:"simplified"}]
          },
          {
            featureType:"transit",
            stylers:[{visibility:"simplified"}]
          },
          {
            featureType:"landscape",
            stylers:[{visibility:"simplified"}]
          },
          {
            featureType:"road.highway",
            stylers:[{visibility:"off"}]
          },
          {
            featureType:"road.local",
            stylers:[{visibility:"on"}]
          },
          {
            featureType:"road.highway",
            elementType:"geometry",
            stylers:[{visibility:"on"}]
          },
          {
            featureType:"water",
            stylers:[
              {color:"#84afa3"},
              {lightness:52}
            ]
          },
          {
            stylers:[
              {saturation:-17},
              {gamma:0.36}
            ]
          },
          {
            featureType:"transit.line",
            elementType:"geometry",
            stylers:[{color:"#3f518c"}]
          }
        ];

        var styledMap = new google.maps.StyledMapType(styles, {name: "Cleveland"});

        var mapOptions = {
            zoom: 14,
            center: new google.maps.LatLng(41.4822, -81.6697),
            mapTypeControl: false
          };

        var googleMap = new google.maps.Map(elm[0], mapOptions);
        googleMap.mapTypes.set('cleveland', styledMap);
        googleMap.setMapTypeId('cleveland');
        scope.callback(googleMap);
      }
    };
  }]);
