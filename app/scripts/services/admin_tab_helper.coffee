'use strict'

angular.module('dcida20App')
  .factory 'AdminTabHelper', ['Confirm', '$q', '$timeout', (Confirm, $q, $timeout) ->

    saveDecisionAid: (scope, decisionAid) ->
      d = $q.defer()
      decisionAid.$update {decision_aid_id: decisionAid.id}, ((da) => 
        scope.decisionAidEditForm.$setPristine()
        scope.$emit 'decisionAidUpdated', da
        scope.ctrl.saveSuccess = true
        $timeout () =>
          scope.ctrl.saveSuccess = false
        , 1500
        d.resolve(decisionAid)
      ), ((error) => 
        d.reject(error)
      )
      d.promise

    confirmNavigation: (scope, decisionAid) ->
      if scope.decisionAidEditForm and scope.decisionAidEditForm.$dirty
        Confirm.showWithClose(
          message: 'You have unsaved changes on this page. Would you like to save them before continuing?'
          buttonType: 'primary'
          confirmText: 'Yes'
          closeText: 'No'
        ).result.then (msg) =>
          if msg is "confirm"
            @saveDecisionAid(scope, decisionAid).then (da) =>
              scope.$emit 'tabChangeApproved'
            , (error) =>
              scope.ctrl.handleError(error) #scope.ctrl.errors = scope.ctrl.ErrorHandler.handleError(error)
          else if msg is "close"
            scope.$emit 'tabChangeApproved'
      else
        scope.$emit 'tabChangeApproved'

  ]
