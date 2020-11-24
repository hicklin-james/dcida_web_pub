'use strict'

angular.module('dcida20App')
  .factory 'ErrorHandler', ['$q', '_', ($q, _) ->

    handleError: (responseData) ->
      if responseData.status is 403
        return ["You don't have permission to do that."]
      else if responseData.status is 422
        if responseData.data and responseData.data.errors
          return responseData.data.errors
        else
          return ["An unknown error occured"]
  ]
