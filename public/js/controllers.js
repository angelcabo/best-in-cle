'use strict';

angular.module('cleApp.controllers', []).
  controller('MainCtrl', ['$scope', '$http', '$location', 'HotList', function($scope, $http, $location, HotList) {

    $scope.ui = {
      mapInstance: {},
      places: [],
      categories: [],
      selectedCategory: "",
      selectedSubcategory: "",
      searchResults: [
        /*
         * {
         *   place: {},
         *   marker: {},
         *   infowindow: {}
         * }
         */
      ]
    };

    $scope.location = $location;

    $scope.mapReady = function(mapInstance) {
      $scope.ui.mapInstance = mapInstance;

      $scope.$watch('location.search()', function() {
        $scope.ui.selectedCategory = ($location.search()).category;
        $scope.ui.selectedSubcategory = ($location.search()).subcategory;
        HotList.getCategories($scope.ui.selectedCategory).then(function(categories) {
          $scope.categories = categories
        });
        HotList.getPlaces().then(function(places) {
          $scope.places = places;
          // console.log(_.groupBy($scope.places, 'location_text'));
          if ($scope.ui.selectedCategory) {
            $scope.categorySelected();
          } else {
            $scope.clearMap();
          }
        });
      }, true);
    };

    $scope.resetMap = function() {
      $scope.ui.selectedCategory = "";
      $scope.ui.selectedSubcategory = "";
      $scope.clearMap();
      $scope.ui.mapInstance.setCenter(new google.maps.LatLng(41.4822, -81.6697));
      $location.search('category', null)
      $location.search('subcategory', null)
    };

    $scope.clearMap = function() {
      _.each($scope.ui.searchResults, function(result) {
        result.marker.setMap(null);
      });
      $scope.ui.searchResults = [];
    };

    $scope.numberInCategory = function(category) {
      return _.where($scope.places, {category: category}).length;
      $scope.location.path("/");
    };

    $scope.categorySelected = function() {
      $scope.clearMap();
      $scope.populateMarkers();
    };

    $scope.populateMarkers = function() {
      if ($scope.ui.selectedSubcategory) {
        _.each(_.where($scope.places, {subcategory: $scope.ui.selectedSubcategory}), $scope.addMarker);
      } else {
        _.each(_.where($scope.places, {category: $scope.ui.selectedCategory}), $scope.addMarker);
      }
    };

    $scope.addMarker = function(place) {
      if (place.lat && place.lng) {
        var searchResult = {place: place};
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
        var contentString = '<div><h3>' + place.name + '</h3><p>' + place.formatted_address + '</p></div>';
        searchResult.infowindow = new google.maps.InfoWindow({
          content: contentString
        });
        google.maps.event.addListener(marker, 'click', function() {
          _.each($scope.ui.searchResults, function(sr) { sr.infowindow.close(); });
          searchResult.infowindow.open($scope.ui.mapInstance, marker);
        });
        searchResult.marker = marker;
        $scope.ui.searchResults.push(searchResult);
      }
    };

    $scope.openMarker = function(searchResult) {
      _.each($scope.ui.searchResults, function(sr) { sr.infowindow.close(); });
      searchResult.infowindow.open($scope.ui.mapInstance, searchResult.marker);
      $scope.ui.mapInstance.setCenter(searchResult.marker.position);
    };
  }]);
