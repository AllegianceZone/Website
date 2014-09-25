//Define an angular module for our app
var az = angular.module('az', ['ngRoute']);
az.config(['$compileProvider', function ($compileProvider) {
    $compileProvider.aHrefSanitizationWhiteList(/^\s*(allegiance):/);
}]);

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

    $scope.missions = [];


    $scope.message = 'This is Home screen';
    var refreshLobbyInfo = function () {
        $http.get('/lobbyinfo.ashx')
            .then(function (res) {
                $scope.missions = res.data;
                $scope.playerCount = function () {
                    var sum = 0;
                    if ($scope.missions.length > 0) {
                        for (var m in $scope.missions) {
                            sum += $scope.missions[m].nNumPlayers;
                        }
                    }
                    return sum;
                }
            });
    };
    refreshLobbyInfo();
    setInterval(refreshLobbyInfo, 32000);
});


az.controller('ShowLeaderboardController', function ($scope) {

    $scope.message = 'This is the leaderboard screen';

});

az.controller('ShowRostersController', function ($scope) {

    $scope.message = 'This is Show orders screen';

});