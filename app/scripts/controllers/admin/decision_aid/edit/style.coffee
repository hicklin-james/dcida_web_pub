'use strict'

module = angular.module('dcida20App')


class DecisionAidEditStyleCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'DecisionAid', '$uibModal', 'AdminTabHelper', '_', 'ErrorHandler', 'NavLink' ,'$q', 'Confirm', 'Sortable']
  constructor: (@$scope, @$state, @$stateParams, @DecisionAid, @$uibModal, @AdminTabHelper, @_, @ErrorHandler, @NavLink, @$q, @Confirm, @Sortable) ->
    if @$scope.ctrl? && @$scope.ctrl.decisionAid?
      @decisionAid = @$scope.ctrl.decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @loading = true
    @currentlyActiveNl = null
    @navLinks = []

    @$scope.$on 'decisionAidChanged', (event, decisionAid) =>
      @decisionAid = decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @$scope.$on 'tabChangeRequested', () =>
      @AdminTabHelper.confirmNavigation(@$scope, @decisionAidEdit)

    @getNavLinks()
    @$scope.ctrl = @

  getNavLinks: () ->
    @NavLink.query {decision_aid_id: @$stateParams.decisionAidId}, (navLinks) => 
      @navLinks = navLinks
      @loading = false

  addNavLink: () ->
    if @currentlyActiveNl
      @saveNl().then () =>
        @createNewNavLink()
      , (error) =>
        console.log error
        @errors = @ErrorHandler.handleError(error)
    else
      @createNewNavLink()


  createNewNavLink: () ->
    @currentlyActiveNl = new @NavLink()
    @navLinks.push(@currentlyActiveNl)
  
  selectIcon: () ->
    modalInstance = @$uibModal.open(
      templateUrl: "views/admin/shared/icon_picker.html"
      controller: "IconPickerCtrl"
      size: 'lg'
      backdrop: 'static'
      resolve: 
        options: () =>
          selectedFileIds: [@decisionAidEdit.icon_id]
          decisionAidId: @decisionAidEdit.id
          iconType: 'main_logo'
    )

    modalInstance.result.then (icon) =>
      if icon and icon.id isnt @decisionAidEdit.icon_id
        @$scope.decisionAidEditForm.$setDirty()
      if icon
        @decisionAidEdit.icon_id = icon.id
        @decisionAidEdit.icon_image = icon.image
      else
        @decisionAidEdit.icon_id = null
        @decisionAidEdit.icon_image = null

  selectFooterIcons: () ->
    modalInstance = @$uibModal.open(
      templateUrl: "views/admin/shared/icon_picker.html"
      controller: "IconPickerCtrl"
      size: 'lg'
      backdrop: 'static'
      resolve: 
        options: () =>
          selectedFileIds: @decisionAidEdit.footer_logos
          decisionAidId: @decisionAidEdit.id
          iconType: 'main_logo'
          multiSelect: true
    )

    modalInstance.result.then (icons) =>
      new_footer_logos = @_.map icons, (icon) -> icon.id
      if !@_.all(@_.zip(new_footer_logos, @decisionAidEdit.footer_logos), (x) -> x[0] is x[1])
        @$scope.decisionAidEditForm.$setDirty()
      @decisionAidEdit.footer_logos = new_footer_logos
      @decisionAidEdit.footer_logo_images = @_.map icons, (icon) -> icon.image

  handleError: (error) ->
    @errors = @ErrorHandler.handleError(error)

  setCurrentlyActive: (nl) =>
    @currentlyActiveNl = nl

  saveNl: () ->
    d = @$q.defer()
    if @currentlyActiveNl.id
      @currentlyActiveNl.$update {decision_aid_id: @$stateParams.decisionAidId}, 
      (() => 
        @currentlyActiveNl = null
        d.resolve()
      ), ((error) => 
        d.reject(error)
      )
    else
      @currentlyActiveNl.$save {decision_aid_id: @$stateParams.decisionAidId}, 
      (() => 
        @currentlyActiveNl = null
        d.resolve()
      ), ((error) => 
        d.reject(error)
      )
    d.promise

  deleteNavLink: (nl) ->
    @Confirm.show(
      message: 'Are you sure you want to delete this navigation link?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      nl.$delete {decision_aid_id: @$stateParams.decisionAidId}, (() => 
        @Sortable.finishItemDeletion(nl, @navLinks, 'nav_link_order')
      ), (
        (error) => @handleError(error)
      )

  onSort: (navLink, partFrom, partTo, indexFrom, indexTo) ->
    if navLink and navLink.nav_link_order isnt indexTo + 1
      navLink.nav_link_order = indexTo + 1
      @Sortable.reorderItem(navLink, @navLinks, 'nav_link_order')

  save: () ->
    ps = []
    if @currentlyActiveNl
      ps.push @saveNl()

    ps.push @AdminTabHelper.saveDecisionAid(@$scope, @decisionAidEdit).promise

    @$q.all(ps).then((() =>

    ), ((error) =>
      @errors = @ErrorHandler.handleError(error)
    ))

module.controller 'DecisionAidEditStyleCtrl', DecisionAidEditStyleCtrl

