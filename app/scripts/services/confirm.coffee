'use strict'

# confirm single options:
#   message      = translation key for title (interpolated using messageformat)
#   messageSub   = text to show in small text beside title (not translated)
#   buttonType   = name of bootstrap style for confirm button e.g. 'danger'
#   confirmText  = translation key for confirm button text
#   titleParams  = params supplied to interpolation of message translation key
class ConfirmCtrl
  @$inject = ['$scope', '$uibModalInstance', 'options']
  constructor: (@$scope, @$uibModalInstance, @options) ->
    @buttonType = (if @options and @options.buttonType then @options.buttonType else 'primary')
    @$scope.ctrl = @

  confirm: -> @$uibModalInstance.close 'confirm'

  close: -> @$uibModalInstance.close 'close'

  cancel: ->  @$uibModalInstance.dismiss 'cancel'

# alert options:
#   message      = translation key for title (interpolated using messageformat)
#   messageSub   = text to show in small text beside title (not translated)
#   buttonType   = name of bootstrap style for confirm button e.g. 'danger'
#   titleParams  = params supplied to interpolation of message translation key
class AlertCtrl
  @$inject = ['$scope', '$uibModalInstance', 'options']
  constructor: (@$scope, @$uibModalInstance, @options) ->
    @buttonType = (if @options and @options.buttonType then @options.buttonType else 'primary')
    @$scope.ctrl = @

  dismiss: -> @$uibModalInstance.close 'dismiss'

angular.module('dcida20App')
  .factory 'Confirm', ['$uibModal', ($uibModal) ->
    # show simple confirmation that provides a message, a positive action, and a cancel button
    show: (options) ->
      $uibModal.open(
        template:
          "<div class='modal-header text-center'>
            <h3>{{ ::ctrl.options.message }}</h3>
            <h4 class='text-muted'>{{ ::ctrl.options.messageSub }}</h4>
          </div>
          <div class='modal-body modal-confirm-body text-right'>
            <button class='btn btn-default half-space-bottom' ng-click='ctrl.cancel()'>{{'BTN-CANCEL' | translate}}</button>
            <button class='btn btn-{{ ::ctrl.buttonType }} half-space-bottom' ng-click='ctrl.confirm()'>{{ ::ctrl.options.confirmText }}</button>
          </div>"
        backdrop: 'static'
        keyboard: false
        size: 'sm-lg'
        resolve:
          options: -> options
        controller: ConfirmCtrl
      )

    # show simple confirmation that provides a message, a positive action, a close button, and a cancel button that executes a callback
    showWithClose: (options) ->
      $uibModal.open(
        template:
          "<div class='modal-header'>
            <h3>{{ ::ctrl.options.message }}</h3>
            <h4 class='text-muted'>{{ ::ctrl.options.messageSub }}</h4>
          </div>
          <div class='modal-body modal-confirm-body clearfix'>
            <div class='pull-right'>
              <button class='btn btn-danger half-space-bottom' ng-click='ctrl.close()'>{{ ::ctrl.options.closeText}}</button>
              <button class='btn btn-{{ ::ctrl.buttonType }} half-space-bottom' ng-click='ctrl.confirm()'>{{ ::ctrl.options.confirmText }}</button>
            </div>
            <div class='pull-left'>
              <button class='btn btn-default half-space-bottom' ng-click='ctrl.cancel()'>Cancel</button>
            </div>
          </div>"
        backdrop: 'static'
        keyboard: false
        size: 'sm-lg'
        resolve:
          options: -> options
        controller: ConfirmCtrl
      )

    downloadReady: (options) ->
      $uibModal.open(
        template:
          "<div class='modal-header'>
            <h3 class='text-center text-success'>Success!</h3>
            <h4 class='text-muted text-center'>Your download is ready</h4>
          </div>
          <div class='modal-body modal-confirm-body'>
            <div>
              <p>
                <a target='_blank' ng-href='{{::ctrl.options.downloadLink}}'>Click here to download your file</a>
              </p>
            </div>
            <div class='clearfix'>
              <div class='pull-left'>
                <button class='btn btn-default half-space-bottom' ng-click='ctrl.cancel()'>Close</button>
              </div>
            </div>
          </div>"
        backdrop: 'static'
        keyboard: false
        size: 'sm-lg'
        resolve:
          options: -> options
        controller: ConfirmCtrl
      )

    warning: (options) ->
      $uibModal.open(
        template:
          "<div class='modal-header'>
            <h3 class='text-center'>{{ ::ctrl.options.message }}</h3>
            <h4 class='text-center text-danger'><span compile='::ctrl.options.messageSub'></span></h4>
          </div>
          <div class='modal-body text-right'>
            <button class='btn btn-{{ ::ctrl.buttonType}}' ng-click='ctrl.dismiss()'>Dismiss</button>
          </div>"
        size: 'sm-lg'
        resolve:
          options: -> options
        controller: AlertCtrl
      )

    frontendInfo: (options) ->
      $uibModal.open(
        template:
          "<div class='frontend-info'><div class='modal-header'>
            <h4 class='modal-title'>{{ ::ctrl.options.header }}</h3>
          </div>
          <div class='modal-body'>
            <h5 compile='::ctrl.options.messageSub'></h5>
          </div>
          <div class='modal-footer text-right'>
            <button class='btn btn-{{ ::ctrl.buttonType}}' ng-click='ctrl.dismiss()'>{{'DISMISS-BUTTON' | translate}}</button>
          </div></div>"
        size: if options.size then options.size else 'sm-lg'
        resolve:
          options: -> options
        controller: AlertCtrl
      )

    info: (options) ->
      $uibModal.open(
        template:
          "<div class='modal-header'>
            <h3 class='text-center'>{{ ::ctrl.options.message }}</h3>
            <h4 class='text-center text-info'><span compile='::ctrl.options.messageSub'></span></h4>
          </div>
          <div class='modal-body text-right'>
            <button class='btn btn-{{ ::ctrl.buttonType}}' ng-click='ctrl.dismiss()'>{{'BTN-CLOSE' | translate}}</button>
          </div>"
        size: 'sm-lg'
        resolve:
          options: -> options
        controller: AlertCtrl
      )

    # show simple alert that displays a message and a dismiss button
    alert: (options) ->
      $uibModal.open(
        template:
          "<div class='modal-header text-center'>
            <h3 class='{{::ctrl.options.headerClass}}'>{{ ::ctrl.options.message }}</h3>
            <h4 class='text-muted'> {{ ::ctrl.options.messageSub }}</h4>
          </div>
          <div class='modal-body text-right'>
            <button class='btn btn-{{ ::ctrl.buttonType}}' ng-click='ctrl.dismiss()'>Close</button>
          </div>"
        size: 'sm-lg'
        resolve:
          options: -> options
        controller: AlertCtrl
      )

    questionResponse: (options, backdrop=true) ->
      $uibModal.open(
        template:
          "<div class='modal-header text-center'>
          </div>
          <div class='modal-body'>
            <div compile='::ctrl.options.popup_information'></div>
          </div>
          <div class='modal-footer text-right'>
            <button class='btn btn-{{ ::ctrl.buttonType}}' ng-click='ctrl.dismiss()'>{{'BTN-CLOSE' | translate}}</button>
          </div>"
        size: 'sm-lg'
        backdrop: backdrop
        resolve:
          options: -> options
        controller: AlertCtrl
      )
  ]