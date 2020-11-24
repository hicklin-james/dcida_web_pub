'use strict'

app = angular.module('dcida20App')

app.filter('lpad', () =>
  return (input, padValue) =>
    len = input.length
    diff = len - padValue
    if diff > 0
      return input.substring(diff)
    else
      return ((new Array(Math.abs(diff)+1).join('\xa0')) + input)
);

# when clicking the element, it will trigger a browser back operation
app.directive 'sdHumanBodyHeatmapQuestion', ['$document', '$window', '$timeout', '_', 'Util', '$sce', ($document, $window, $timeout, _, Util, $sce) ->
  templateUrl: "views/directives/human_body_heatmap_question.html"
  scope:
    question: "=saQuestion"
    toggleQuestion: "&saToggleQuestion"
    responses: "=saResponses"
    hideCheckboxes: "@saHideCheckboxes"

  link: (scope, element, attrs) =>
    bodyParts = [
      {key: 'neck', label: "Neck"}, 
      {key: 'uback', label: "Upper back"},
      {key: 'lback', label: "Lower back"}, 
      {key: 'lshoulder', label: "Left shoulder"}, 
      {key: 'lelbow', label: "Left elbow"}, 
      {key: 'lwrist', label: "Left wrist"}, 
      {key: 'lhand', label: "Left hand"},
      {key: 'lthumb', label: "Left thumb"},
      {key: 'lhip', label: "Left hip"},
      {key: 'lknee', label: "Left knee"},
      {key: 'lankle', label: "Left ankle"},
      {key: 'lfoot', label: "Left foot"},
      {key: 'rshoulder', label: "Right shoulder"}, 
      {key: 'relbow', label: "Right elbow"}, 
      {key: 'rwrist', label: "Right wrist"}, 
      {key: 'rhand', label: "Right hand"}, 
      {key: 'rthumb', label: "Right thumb"}, 
      {key: 'rhip', label: "Right hip"}, 
      {key: 'rknee', label: "Right knee"}, 
      {key: 'rankle', label: "Right ankle"}, 
      {key: 'rfoot', label: "Right foot"}
    ]

    midPoint = (bodyParts.length-3) / 2
    scope.bodyTop = bodyParts.slice(0, 3)
    scope.bodyLeft = bodyParts.slice(3, midPoint+3)
    scope.bodyRight = bodyParts.slice(midPoint+3)

    scope.hideCheckboxes = false if !scope.hideCheckboxes

    scope.bodyPartQuestions = {}
    if scope.question && scope.question.grid_questions
      _.each bodyParts, (bp) =>
        q = _.find scope.question.grid_questions, (q) => q.question_text_published is bp.key
        if q
          scope.bodyPartQuestions[bp.key] = q
          if !scope.responses[q.id].question_response_id
            scope.responses[q.id].question_response_id = q.question_responses[1].id

    win = angular.element($window)

    setSVGValues = () =>
      heatmap = d3.select('.human-body')
      svg = d3.select('#human-body-svg')
      viewbox = svg.attr("viewBox")
      vals = viewbox.split(" ")
      widthv = vals[2]
      heightv = vals[3]
      ratio = heightv / widthv
      width = parseInt(heatmap.style('width'))
      svg.style("width", width + "px")
      svg.style("height", Math.round(width * ratio) + "px")


    win.on 'resize', () ->
      setSVGValues()

    $timeout () =>
      setSVGValues()

    scope.selectQuestion = (q) =>
      scope.toggleQuestion({question: q})
]

