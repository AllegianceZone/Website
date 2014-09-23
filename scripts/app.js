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
		
		when('/Video', {
            templateUrl: 'templates/video.html',
            controller: 'ShowHomeController'
        }).
		
        otherwise({
            redirectTo: '/Home'
        });
  }]);


az.controller('ShowHomeController', function ($scope, $http) {

    $scope.message = 'This is Home screen';
    $http.get('/gameinfod.ashx')
        .then(function(res){
            $scope.lobbyInfo = res.data;
        })
    $http.get('/lobbyinfo.ashx')
        .then(function (res) {            
            $scope.missions = res.data;
        })

});


az.controller('ShowLeaderboardController', function ($scope) {

    $scope.message = 'This is the leaderboard screen';

});

az.controller('ShowRostersController', function ($scope) {

    $scope.message = 'This is Show orders screen';

});