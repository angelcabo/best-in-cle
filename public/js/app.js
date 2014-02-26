var app = angular.module('bocApp', ['google-maps']);

app.controller('MainCtrl', function($scope, $http) {

  google.maps.visualRefresh = true;

  $scope.map = {
    center: {
      latitude: 41.4822,
      longitude: -81.6697
    },
    zoom: 8,
    dragging: false,
    markers: []
  };

  $http({method: 'GET', url: '/categories.json'}).success(function(data, status, headers, config) {
    $scope.categories = data;
  });

  $http({method: 'GET', url: '/hotlist.json'}).success(function(data, status, headers, config) {
    $scope.places = data;
  });

  $scope.numberInCategory = function(category) {
    return _.where($scope.places, {category: category}).length;
  };

  $scope.showMarkersForCategory = function(category) {
    $scope.map.markers = [];
    var placesByCat = _.where($scope.places, {category: category});
    _.each(placesByCat, function(place) {
      if (place.lat && place.lat.length > 0) {
        var marker = {
          icon: place.map_icon,
          latitude: place.lat,
          longitude: place.lng,
          showWindow: false,
          title: place.name
        };
        marker.onClicked = function() {
          marker.showWindow = true;
        };
        marker.closeClick = function () {
            marker.showWindow = false;
            $scope.$apply();
        };
        $scope.map.markers.push(marker);
      }
    });
  };

});
