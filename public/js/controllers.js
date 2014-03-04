'use strict';

angular.module('cleApp.controllers', []).
  controller('MainCtrl', ['$scope', '$http', '$location', 'HotList', function($scope, $http, $location, HotList) {

    $scope.ui = {
      mapInstance: {},
      markers: [],
      selectedCategory: "",
      places: [],
      categories: [],
      filteredPlaces: []
    };

    $scope.location = $location;

    $scope.mapReady = function(mapInstance) {
      $scope.ui.mapInstance = mapInstance;

      $scope.$watch('location.search()', function() {
        $scope.ui.selectedCategory = ($location.search()).category;
        HotList.getCategories($scope.ui.selectedCategory).then(function(categories) {
          $scope.categories = categories
        });
        HotList.getPlaces().then(function(places) {
          $scope.places = places;
          if ($scope.ui.selectedCategory) {
            $scope.categorySelected();
          };
        });
      }, true);
    };

    $scope.resetMap = function() {
      $scope.ui.selectedCategory = "";
      $scope.clearMap();
    };

    $scope.someFilteredPlacesHaveNoLocation = function() {
      return _.find($scope.ui.filteredPlaces, function(place) {
        return place.lat == "";
      });
    };

    $scope.clearMap = function() {
      $scope.ui.filteredPlaces = [];
      _.each($scope.ui.markers, function(marker) {
        marker.setMap(null);
      });
    };

    $scope.numberInCategory = function(category) {
      return _.where($scope.places, {category: category}).length;
    };

    $scope.addToFilteredList = function(place) {
      $scope.ui.filteredPlaces.push(place);
      if (place.lat && place.lat.length > 0) {
        $scope.addMarker(place);
      }
    };

    $scope.categorySelected = function() {
      $scope.clearMap();
      $scope.populateMarkers();
    };

    $scope.populateMarkers = function() {
      if ($location.search().subcategory) {
        _.each(_.where($scope.places, {subcategory: $scope.ui.selectedCategory}), $scope.addMarker);
      } else {
        _.each(_.where($scope.places, {category: $scope.ui.selectedCategory}), $scope.addMarker);
      }
    };

    $scope.addMarker = function(place) {
      if (place.lat && place.lng) {
        var marker = new google.maps.Marker({
          position: new google.maps.LatLng(place.lat, place.lng),
          map: $scope.ui.mapInstance
        });
        if (place.map_icon) {
          var image = {
              url: place.map_icon,
              size: null,
              origin: null,
              anchor: null,
              scaledSize: new google.maps.Size(25, 25)
          };
          marker.setIcon(image);
        }
        $scope.ui.markers.push(marker);
      }
    };
  }]);
