'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdDynamicContent', [ '$http', '_', ($http, _) ->
  restrict: 'E'
  scope:
    sourceUrl: "@saSourceUrl"
  template:  "<div>
                <div class='space-top space-bottom text-center' ng-show='loading'>
                  <i class='fa fa-2x fa-spin fa-refresh'></i>
                </div>
                <div ng-show='!loading' compile='loadedContent'></div>
              </div>"
  
  link: (scope, element, attrs) ->

    scope.loading = true

    whitelisted = [
      {
        domain: "jointhealth.org",
        removeTags: ["img"]
      }
    ]

    getLocation = (url) =>
      l = document.createElement('a');
      l.href = url
      return l

    if scope.sourceUrl
      loc = getLocation(scope.sourceUrl)
      wl = _.find whitelisted, (item) => item.domain = loc.hostname
      console.log wl
      if wl
        $http({
          method: 'GET',
          url: "https://cors-anywhere.herokuapp.com/" + scope.sourceUrl
        }).then (data) =>
          htmlString = data.data
          body = /<body.*?>([\s\S]*)<\/body>/.exec(htmlString)[1]
          domifiedHtml = $($.parseHTML(body))
          #domifiedHtml.find('img').remove()
          #console.log domifiedHtml.prop('outerHTML')
          #console.log $('<div>').append($(domifiedHtml).clone()).html();
          #domifiedHtml.find('img').remove();
          #console.log domifiedHtml.html()
          
          _.each wl.removeTags, (tag) =>
            domifiedHtml.find(tag).remove()
            #parsedHtml = parsedHtml.replace(/<img.*>/ig, '')
          scope.loadedContent = $('<div>').append($(domifiedHtml).clone()).html();
          scope.loading = false
          # scope.loadedContent = parsedHtml

        , (error) =>
          console.error "Error fetching content"
          scope.loading = false
      else
        console.error "Given URL not whitelisted"
        scope.loading = false
    else
      console.error "No URL given"
      scope.loading = false
]