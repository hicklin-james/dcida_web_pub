'use strict'

angular.module('dcida20App')
  .factory 'Util', ['$q', '_', ($q, _) ->

    responseArray = (key) ->
      (dataStr, headers) ->
        try
          data = angular.fromJson dataStr

          array = []
          if _.has data, key
            array = data[key]
            array.$metadata = data.meta

          return array
        catch e
          return []

    responseSingle = (key) ->
      (dataStr, headers) ->
        try
          data = angular.fromJson dataStr

          result = {}
          if data.errors?
            result = errors: data.errors
          else if _.has data, key
            result = data[key]

          if _.has data, 'meta'
            result.$metadata = data.meta

          return result
        catch e
          return {}

    transformParams = (data, prefix, allowedParams) ->
      outputParams = {}
      outputParams[prefix] = {}
      _.each allowedParams, (attr, index, list) ->
        if _.has(data, attr)
          outputParams[prefix][_.underscored(attr)] = data[attr]
      outputParams

    # this is used to transform POST/PUT requests to the format rails expects
    transformParamsFunc = (prefix, allowedParams) ->
      (data, headers) ->
        angular.toJson transformParams data, prefix, allowedParams

    metaDataInterceptor = (response) ->
      response.resource.$metadata = response.data.$metadata
      response.resource

    exclusionHash = (exclusion, list) ->
      hash = {}
      if _.isArray exclusion
        _.each exclusion, (key) -> hash[key] = true
      else if _.isFunction exclusion
        _.each list, (element) ->
          excluded =  exclusion(element)
          hash[excluded] = true if excluded
      else if _.isObject exclusion
        hash = exclusion
      else
        hash[exclusion] = true
      hash

    componentToHex = (c) ->
      hex = c.toString(16);
      return (if hex.length == 1 then "0" + hex else hex)

    # set up actions available for an ngResource instance.
    # this uses various utility functions in this class to perform basic operations, such as parsing API responses and preparing API requests
    resourceActions: (single, array, attributes, nestedUrl) ->
      respSingle = responseSingle(single)
      respArray = responseArray(array)
      createReq = transformParamsFunc single, attributes

      getAction =    method: 'GET',    isArray: false, transformResponse: respSingle
      queryAction =  method: 'GET',    isArray: true,  transformResponse: respArray,  interceptor: { response: metaDataInterceptor }
      updateAction = method: 'PUT',    isArray: false, transformResponse: respSingle, transformRequest: createReq
      saveAction =   method: 'POST',   isArray: false, transformResponse: respSingle, transformRequest: createReq
      deleteAction = method: 'DELETE', isArray: false, transformResponse: respSingle

      if nestedUrl?
        queryAction.url = nestedUrl
        saveAction.url = nestedUrl

      get:    getAction
      query:  queryAction
      update: updateAction
      save:   saveAction
      delete: deleteAction

    hslToRgb: (h, s, l) ->
      r = 0
      g = 0
      b = 0

      if s is 0
          r = g = b = l
      else
        hue2rgb = (p, q, t) ->
          if t < 0 then t += 1
          if t > 1 then t -= 1
          if t < 1/6 then return p + (q - p) * 6 * t
          if t < 1/2 then return q
          if t < 2/3 then return p + (q - p) * (2/3 - t) * 6
          return p
          
        q = if l < 0.5 then l * (1 + s) else l + s - l * s
        p = 2 * l - q
        r = hue2rgb(p, q, h + 1/3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1/3)


      return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)]

    hexToRgb: (hex) ->
      result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
      
      return {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
      }

    rgbToHex: (rgb) ->
      if rgb
        components = rgb.replace(/[^\d,]/g, '').split(',')
        if components.length is 3
          r = parseInt(components[0])
          g = parseInt(components[1])
          b = parseInt(components[2])
          return "#" + componentToHex(r) + componentToHex(g) + componentToHex(b)
        
      return '#ffffff'

    getContrastYIQ: (hexcolor) ->
      r = parseInt(hexcolor.substr(0,2),16)
      g = parseInt(hexcolor.substr(2,2),16)
      b = parseInt(hexcolor.substr(4,2),16)
      yiq = ((r * 299) + (g * 587) + (b * 114)) / 1000
      if yiq >= 128  then return 'black' else return 'white'

    dataURLToBlob: (dataURL) ->
      BASE64_MARKER = ';base64,'
      if dataURL.indexOf(BASE64_MARKER) is -1
        parts = dataURL.split(',')
        contentType = parts[0].split(':')[1]
        vaw = decodeURIComponent(parts[1])

        return new Blob([raw], {type: contentType});

      parts = dataURL.split(BASE64_MARKER)
      contentType = parts[0].split(':')[1]
      raw = window.atob(parts[1])
      rawLength = raw.length

      uInt8Array = new Uint8Array(rawLength)

      uInt8Array[i] = raw.charCodeAt(i) for i in [0 .. rawLength]
      

      return new Blob([uInt8Array], {type: contentType})

    partial: (func, args) ->
      () =>
        allArguments = args.concat(Array.prototype.slice.call(arguments))
        func.apply(this, allArguments)

    makeId: () ->
      text = "";
      possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
      i = 0
      while i < 5
        text += possible.charAt(Math.floor(Math.random() * possible.length))
        i = i + 1

      text

    pOpen: () ->
      '<p>'

    pClose: () ->
      '</p>'
  ]
