request = require('request')

class Seed
  constructor: () ->
    jar = request.jar()
    @req = request.defaults(jar: jar)

  post: (url, params) ->
    defer = protractor.promise.defer()
    @req.post({url: "http://localhost:3000/" + url, json: params}, (error, message) ->
      if (error || message.statusCode >= 400)
        defer.reject(
          error : error,
          message : message
        )
      else
        defer.fulfill(message)
    )
    return defer.promise

  prepare: (params) ->
    seedData = () =>
      return @post('test/setup_e2e_env', params)

    flow = protractor.promise.controlFlow()
    flow.execute(seedData)

module.exports = Seed