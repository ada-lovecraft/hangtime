'use strict'

### Controllers ###

angular.module('app.controllers', [])

.controller('AppCtrl', [
  '$scope'
  '$location'
  '$resource'
  '$rootScope'
  'Firebase'
  'angularFireAuth'
  'angularFire'

($scope, $location, $resource, $rootScope,Firebase, angularFireAuth, angularFire) ->
  console.log 'app controller'
  # Uses the url to determine if the selected
  # menu item should have the class active.
  $scope.$location = $location
  $scope.location = $location.path()
  $scope.$watch('$location.path()', (path) ->
    $scope.activeNavId = path || '/'
  )

  # getClass compares the current url with the id.
  # If the current url starts with the id it returns 'active'
  # otherwise it will return '' an empty string. E.g.
  #
  #   # current url = '/products/1'
  #   getClass('/products') # returns 'active'
  #   getClass('/orders') # returns ''
  #
  $scope.getClass = (id) ->
    if $scope.activeNavId.substring(0, id.length) == id
      return 'active'
    else
      return ''


  $scope.base = new Firebase('https://hangtime.firebaseio.com')
  $scope.usersRef = $scope.base.child('users')
  $scope.organizationsRef = $scope.base.child('organizations')

  angularFire($scope.organizationsRef, $scope, 'organizations')
  angularFire($scope.usersRef, $scope, 'users')


  angularFireAuth.initialize($scope.base, {scope: $scope, name: "auth"});

  $scope.login = ->
    angularFireAuth.login('github')

  $scope.logout = ->
    angularFireAuth.logout()

  $scope.$on 'angularFireAuth:login', (evt, user) ->
    console.log 'logged in'
    $scope.userRef = $scope.usersRef.child(user.id)
    angularFire($scope.userRef,$scope, 'user')
    $scope.userRef.once 'value', (snapshot) ->
      if !snapshot.val()
        console.log 'user not found... adding'
        $scope.userRef.set(user)
        console.log 'saved user'
      else

  $scope.$on 'angularFireAuth:logout', (evt) ->
    console.log 'logged out'
    $location.path('/login')

  $scope.$on 'angularFireAuth:error', (evt, error) ->
    console.error 'error in authentication:' , error

])

.controller('AccountController', [
  '$scope'
  'angularFire'

($scope, angularFire) ->
  console.log 'scope.auth:', $scope.auth
  $scope.addOrganization = ->
    console.log 'scope.organizations:', $scope.organizations
    $scope.organizationsRef.once 'value', (snapshot) ->
      console.log 'snapshot val:', snapshot.val()
      if snapshot.val() && _.indexOf(_.pluck(snapshot.val(),'name'), $scope.newOrgName) != -1
        snapshot.forEach (organization) ->
          if organization.child('name').val() == $scope.newOrgName 
            console.log 'found matching organization'
            if _.indexOf(_.pluck(organization.child('users').val(),'id'),$scope.user.id) == -1
              console.log 'adding user to organization'
              usersRef = organization.ref().child('users').push({id: $scope.user.id})
              $scope.userRef.child('hangtime_organizations').push(organization.ref().name())
            else 
              console.log 'user already a part of organization'
            return true
      else 
        newOrganization = $scope.organizationsRef.push({name: $scope.newOrgName})
        newOrganization.child('users').push({id:$scope.user.id})
        newOrganization.child('messages').push({from: $scope.user.id, message: $scope.newOrgName + ' created'})
        $scope.userRef.child('hangtime_organizations').push({id: newOrganization.name()})
      $scope.newOrgName = ''
])
.controller('OrganizationController', [
  '$scope'
  '$routeParams'
  'angularFire'
  ($scope, $routeParams, angularFire) ->
    $scope.organizationRef = $scope.organizationsRef.child($routeParams.id)
    $scope.messagesRef = $scope.organizationRef.child('messages')

    angularFire $scope.organizationRef, $scope, 'organization'
    angularFire $scope.messagesRef, $scope, 'messages'
    
    $scope.addMessage = (evt) ->
      if evt.keyCode == 13
        console.log 'adding message'
        console.log 'scope.messages:', $scope.messages
        $scope.messagesRef.push({from: $scope.user.id, message: $scope.msg});
        $scope.msg = ''
])


