var app = angular.module('bocApp', ['google-maps']);

app.controller('MainCtrl', function($scope, $http) {

  google.maps.visualRefresh = true;

  $scope.ui = {
    map: {},
    selectedCategory: "",
    places: [],
    categories: [],
    filteredPlaces: []
  };

  $scope.ui.map = {
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

  $scope.resetMap = function() {
    $scope.ui.selectedCategory = "";
    $scope.ui.filteredPlaces = [];
    $scope.clearMap();
  }

  $scope.clearMap = function() {
    $scope.ui.map.markers = [];
  };

  $scope.numberInCategory = function(category) {
    return _.where($scope.places, {category: category}).length;
  };

  $scope.populateMarkers = function(name, isSubcategory) {
    if (isSubcategory) {
      var placesByCat = _.each(_.where($scope.places, {subcategory: name}), $scope.addMarker);
    } else {
      var placesByCat = _.each(_.where($scope.places, {category: name}), $scope.addMarker);
    }
  };

  $scope.addMarker = function(place) {
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
      $scope.ui.map.markers.push(marker);
  };

  $scope.addToFilteredList = function(place) {
    $scope.ui.filteredPlaces << place;
    if (place.lat && place.lat.length > 0) {
      $scope.addMarker(place);
    }
  };

  $scope.subcategorySelected = function(name) {
    $scope.clearMap();
    _.each(_.where($scope.places, {subcategory: name}), $scope.addToFilteredList);
  };

  $scope.categorySelected = function(name) {
    $scope.clearMap();
    $scope.ui.selectedCategory = name;
    _.each(_.where($scope.places, {category: name}), $scope.addToFilteredList);
  };

});
