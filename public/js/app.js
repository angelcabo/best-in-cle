var app = angular.module('bocApp', ['google-maps']);

app.controller('MainCtrl', function($scope, $http) {

  $scope.map = {
    center: {
      latitude: 41.4822,
      longitude: -81.6697
    },
    zoom: 8
  };
});
