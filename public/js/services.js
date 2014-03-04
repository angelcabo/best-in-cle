'use strict';

angular.module('cleApp.services', []).
  provider('HotList', function () {
    this.$get = function($http) {
      return {
        getCategories: function(selectedCategoryName) {
          return $http({method: 'GET', url: '/categories.json'}).then(function (response) {
            var categories = response.data;
            if (selectedCategoryName) {
              categories = _.findWhere(categories, {name: selectedCategoryName}).subcategories;
            }
            return categories;
          });
        },
        getPlaces: function(selectedCategoryName, isSubCategory) {
          return $http({method: 'GET', url: '/hotlist.json'}).then(function (response) {
            return response.data;
          });
        }
      }
    };
  });
