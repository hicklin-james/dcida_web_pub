'use strict'

app = angular.module('dcida20App')

app.directive 'sdFevVis', [ ->
  restrict: 'AE'
  templateUrl: 'views/directives/fev_vis.html'
  replace: true
  controller: FevVisCtrl
]

class FevVisCtrl
  @$inject: ['$scope', '_', '$http']
  constructor: (@$scope, @_, @$http) ->
    @$scope.ctrl = @

    #console.log("Hi")

    model_params = {
      male: 1,
      age: 70,
      smoker: 1,
      FEV1: 2.5,
      height: 1.68,
      weight: 65
    }

    @_.each @$scope.data, (v, k) =>
      if model_params[k] is null
        model_params[k] = v

    if @_.some(model_params, (v) => v is null)
      console.error "Can't proceed - missing some data"
    else
      req = {
        method: "POST",
        url: "https://prism.peermodelsnetwork.com/route/fev1/run",
        headers: {
          "Content-Type": "application/json",
          "x-prism-auth-user": "BQLxEiB7GohXrN5XEFzogG"
        },
        data: {
          "func": "prism_model_run",
          "model_input": [model_params]
        }
      }

      @$http(req).then (response) =>
        console.log(response)
        #responseData = JSON.parse(response.data)
        #console.log(responseData)
        # noTreatmentRisk = responseData.predicted_exac_probability[0]
        # treatmentRisk = responseData.azithromycin_predicted_exac_probability[0]

        # noTreatmentPerc = Math.round(100*noTreatmentRisk)
        # noTreatmentRem = 100 - noTreatmentPerc

        # totalSaved = noTreatmentPerc - Math.round(100*treatmentRisk)
        # stillAffected = noTreatmentPerc - totalSaved
        # treatmentRem = 100 - totalSaved - stillAffected

        # @stageData = [
        #   {
        #     totalN: 1,
        #     separateDataPoints: false,
        #     stepLabel: "Imagine this is you.",
        #     dataPoints: [
        #       {
        #         val: 1,
        #         color: "blue",
        #         pointLabel: null
        #       }
        #     ]
        #   },
        #   {
        #     totalN: 100,
        #     separateDataPoints: false,
        #     stepLabel: "Now, imagine there are 100 people like you (same age, sex, health).",
        #     dataPoints: [
        #       {
        #         val: 100,
        #         color: "blue",
        #         pointLabel: null
        #       }
        #     ]
        #   },
        #   {
        #     totalN: 100,
        #     separateDataPoints: false,
        #     stepLabel: "If these 100 people chose not to take any treatment, here is what would happen...",
        #     dataPoints: [
        #       {
        #         val: 100,
        #         color: "blue",
        #         pointLabel: null
        #       }
        #     ]
        #   },
        #   {
        #     totalN: 100,
        #     separateDataPoints: true,
        #     stepLabel: "This is what would happen to those 100 people if they did nothing.",
        #     dataPoints: [
        #       {
        #         val: noTreatmentPerc,
        #         color: "red",
        #         pointLabel: "#{noTreatmentPerc} out of 100 people would have an exacerbation."
        #       },
        #       {
        #         val: noTreatmentRem,
        #         color: "blue",
        #         pointLabel: "#{noTreatmentRem} out of 100 people would NOT have an exacerbation."
        #       }
        #     ]
        #   },
        #   {
        #     totalN: 100,
        #     separateDataPoints: false,
        #     stepLabel: "Here is a summary of what would happen to those 100 people if they did nothing.",
        #     dataPoints: [
        #       {
        #         val: noTreatmentPerc,
        #         color: "red",
        #         pointLabel: "#{noTreatmentPerc} out of 100 people would have an exacerbation."
        #       },
        #       {
        #         val: noTreatmentRem,
        #         color: "blue",
        #         pointLabel: "#{noTreatmentRem} out of 100 people would NOT have an exacerbation."
        #       }
        #     ]
        #   },
        #   {
        #     totalN: 100,
        #     separateDataPoints: false,
        #     stepLabel: "Now imagine that these same 100 people chose to take Azithromycin.",
        #     dataPoints: [
        #       {
        #         val: noTreatmentPerc,
        #         color: "red",
        #       },
        #       {
        #         val: noTreatmentRem,
        #         color: "blue",
        #       }
        #     ]
        #   },
        #   {
        #     totalN: 100,
        #     separateDataPoints: true,
        #     dataPoints: [
        #       {
        #         val: totalSaved,
        #         color: "green",
        #         pointLabel: "#{totalSaved} out of 100 people would be saved from having an exacerbation."
        #       },
        #       {
        #         val: stillAffected,
        #         color: "red",
        #         pointLabel: "#{stillAffected} out of 100 people would still have an exacerbation."
        #       },
        #       {
        #         val: treatmentRem,
        #         color: "blue",
        #         pointLabel: "#{treatmentRem} out of 100 people would NOT have an exacerbation."
        #       }
        #     ]
        #   },
        #   {
        #     totalN: 100,
        #     separateDataPoints: false,
        #     stepLabel: "Here is the summary if these 100 people chose to take Azithromycin.",
        #     dataPoints: [
        #       {
        #         val: totalSaved,
        #         color: "green",
        #         pointLabel: "#{totalSaved} out of 100 people would be saved from having an exacerbation."
        #       },
        #       {
        #         val: stillAffected,
        #         color: "red",
        #         pointLabel: "#{stillAffected} out of 100 people would still have an exacerbation."
        #       },
        #       {
        #         val: treatmentRem,
        #         color: "blue",
        #         pointLabel: "#{treatmentRem} out of 100 people would NOT have an exacerbation."
        #       }
        #     ]
        #   }
        # ]

      , (error) =>
        console.error error