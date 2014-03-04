'use strict';

angular.module('cleApp.filters', []).
  filter('hasNoLocation', [function() {
    return function(input) {
      var out = [];
        for (var i = 0; i < input.length; i++){
            if(input[i].lat == "")
                out.push(input[i]);
        }
      return out;
    };
  }]);
