'use strict'

# Declare app level module which depends on filters, and services
App = angular.module('app', [
  'ngCookies'
  'ngResource'
  'ngRoute'
  'app.controllers'
  'app.directives'
  'app.filters'
  'app.services'
  'partials'
  'firebase'
  'ui.bootstrap'
])

App.config([
  '$routeProvider'
  '$locationProvider'

($routeProvider, $locationProvider, config) ->

  $routeProvider

    .when('/account', {templateUrl: '/partials/account.html'})
    .when('/organization/:id', {templateUrl: '/partials/organization.html'})

    # Catch all
    .otherwise({redirectTo: '/account'})

  # Without server side support html5 must be disabled.
  $locationProvider.html5Mode(false)
])
