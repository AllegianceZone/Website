//Define an angular module for our app
var az = angular.module('az', ['ngRoute']);

az.config(['$routeProvider',
  function ($routeProvider) {
      $routeProvider.
        when('/Home', {
            templateUrl: 'templates/home.html',
            controller: 'ShowHomeController'
        }).
        when('/Leaderboard', {
            templateUrl: 'templates/leaderboard.html',
            controller: 'ShowLeaderboardController'
        }).
        when('/Rosters', {
            templateUrl: 'templates/rosters.html',
            controller: 'ShowRostersController'			
        }).
		
		when('/Training', {
            templateUrl: 'templates/training.html',
            controller: 'ShowHomeController'
        }).
		
		when('/Info', {
            templateUrl: 'templates/info.html',
            controller: 'ShowHomeController'
        }).
		
        otherwise({
            redirectTo: '/Home'
        });
  }]);


az.controller('ShowHomeController', function ($scope) {

    $scope.message = 'This is Home screen';

});


az.controller('ShowLeaderboardController', function ($scope) {

    $scope.message = 'This is the leaderboard screen';

});

az.controller('ShowRostersController', function ($scope) {

    $scope.message = 'This is Show orders screen';

});