var app = angular.module('bocApp', ['google-maps']);

app.controller('MainCtrl', function($scope, $http) {

  $http({method: 'GET', url: '/categories.json'}).success(function(data, status, headers, config) {
    $scope.categories = data;
  });

  $http({method: 'GET', url: '/hotlist.json'}).success(function(data, status, headers, config) {
    $scope.places = data;
  });

  $scope.showMarkersForCategory = function(category) {
    var data = _.where($scope.places, {category: category});
    console.log(data);
  };

  $scope.map = {
    center: {
      latitude: 41.4822,
      longitude: -81.6697
    },
    zoom: 8
  };
});
