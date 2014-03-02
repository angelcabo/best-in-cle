'use strict';

angular.module('cleApp.controllers', []).
  controller('MainCtrl', ['$scope', '$http', function($scope, $http) {

	  $scope.ui = {
	    mapInstance: {},
	    selectedCategory: "",
	    places: [],
	    categories: [],
	    filteredPlaces: []
	  };

		$scope.mapReady = function(mapInstance) {
			$scope.ui.mapInstance = mapInstance;
		  $http({method: 'GET', url: '/categories.json'}).success(function(data, status, headers, config) {
		    $scope.categories = data;
		  });

		  $http({method: 'GET', url: '/hotlist.json'}).success(function(data, status, headers, config) {
		    $scope.places = data;
		  });	
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
	    // Need to set all markers on the map to nil $scope.ui.map.markers = [];
	    $scope.ui.filteredPlaces = [];
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
	        name: place.name,
	        formattedAddress: place.formatted_address
	      };
	      marker.onClicked = function() {
	        marker.showWindow = true;
	      };
	      marker.closeClick = function () {
	          marker.showWindow = false;
	          $scope.$apply();
	      };
	      // $scope.ui.map.markers.push(marker);
	  };

	  $scope.addToFilteredList = function(place) {
	    $scope.ui.filteredPlaces.push(place);
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
  }]);