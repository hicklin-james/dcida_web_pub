'use strict'

app = angular.module('dcida20App')

app.directive 'sdAcceptVis', [ ->
  restrict: 'AE'
  templateUrl: 'views/directives/accept_vis.html'
  replace: true
  scope:
    data: "=saData"
  controller: AcceptVisCtrl
]

class AcceptVisCtrl
  @$inject: ['$scope', '_', '$http']
  constructor: (@$scope, @_, @$http) ->
    @$scope.ctrl = @

    model_params = {
      ID: "10001",
      male: null,
      age: null,
      smoker: null,
      oxygen: null,
      statin: null,
      LAMA: null,
      LABA: null,
      ICS: null,
      FEV1: null,
      BMI: null,
      SGRQ: null,
      LastYrExacCount: null,
      LastYrSevExacCount: null,
      randomized_azithromycin: 0,
      randomized_statin: 0,
      randomized_LAMA: 0,
      randomized_LABA: 0,
      randomized_ICS: 0,
      random_sampling_N: 1000,
      random_distribution_iteration: 20000,
      calculate_CIs: "TRUE"
    }

    @_.each @$scope.data, (v, k) =>
      if model_params[k] is null
        model_params[k] = v

    if @_.some(model_params, (v) => v is null)
      console.error "Can't proceed - missing some data"
    else
      req = {
        method: "POST",
        url: "https://admin-prism-api.cp.prism-ubc.linaralabs.com/route/accept/run"
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
        responseData = JSON.parse(response.data)
        noTreatmentRisk = responseData.predicted_exac_probability[0]
        treatmentRisk = responseData.azithromycin_predicted_exac_probability[0]

        noTreatmentPerc = Math.round(100*noTreatmentRisk)
        noTreatmentRem = 100 - noTreatmentPerc

        totalSaved = noTreatmentPerc - Math.round(100*treatmentRisk)
        stillAffected = noTreatmentPerc - totalSaved
        treatmentRem = 100 - totalSaved - stillAffected

        @stageData = [
          {
            totalN: 1,
            separateDataPoints: false,
            stepLabel: "Imagine this is you.",
            dataPoints: [
              {
                val: 1,
                color: "blue",
                pointLabel: null
              }
            ]
          },
          {
            totalN: 100,
            separateDataPoints: false,
            stepLabel: "Now, imagine there are 100 people like you (same age, sex, health).",
            dataPoints: [
              {
                val: 100,
                color: "blue",
                pointLabel: null
              }
            ]
          },
          {
            totalN: 100,
            separateDataPoints: false,
            stepLabel: "If these 100 people chose not to take any treatment, here is what would happen...",
            dataPoints: [
              {
                val: 100,
                color: "blue",
                pointLabel: null
              }
            ]
          },
          {
            totalN: 100,
            separateDataPoints: true,
            stepLabel: "This is what would happen to those 100 people if they did nothing.",
            dataPoints: [
              {
                val: noTreatmentPerc,
                color: "red",
                pointLabel: "#{noTreatmentPerc} out of 100 people would have an exacerbation."
              },
              {
                val: noTreatmentRem,
                color: "blue",
                pointLabel: "#{noTreatmentRem} out of 100 people would NOT have an exacerbation."
              }
            ]
          },
          {
            totalN: 100,
            separateDataPoints: false,
            stepLabel: "Here is a summary of what would happen to those 100 people if they did nothing.",
            dataPoints: [
              {
                val: noTreatmentPerc,
                color: "red",
                pointLabel: "#{noTreatmentPerc} out of 100 people would have an exacerbation."
              },
              {
                val: noTreatmentRem,
                color: "blue",
                pointLabel: "#{noTreatmentRem} out of 100 people would NOT have an exacerbation."
              }
            ]
          },
          {
            totalN: 100,
            separateDataPoints: false,
            stepLabel: "Now imagine that these same 100 people chose to take Azithromycin.",
            dataPoints: [
              {
                val: noTreatmentPerc,
                color: "red",
              },
              {
                val: noTreatmentRem,
                color: "blue",
              }
            ]
          },
          {
            totalN: 100,
            separateDataPoints: true,
            dataPoints: [
              {
                val: totalSaved,
                color: "green",
                pointLabel: "#{totalSaved} out of 100 people would be saved from having an exacerbation."
              },
              {
                val: stillAffected,
                color: "red",
                pointLabel: "#{stillAffected} out of 100 people would still have an exacerbation."
              },
              {
                val: treatmentRem,
                color: "blue",
                pointLabel: "#{treatmentRem} out of 100 people would NOT have an exacerbation."
              }
            ]
          },
          {
            totalN: 100,
            separateDataPoints: false,
            stepLabel: "Here is the summary if these 100 people chose to take Azithromycin.",
            dataPoints: [
              {
                val: totalSaved,
                color: "green",
                pointLabel: "#{totalSaved} out of 100 people would be saved from having an exacerbation."
              },
              {
                val: stillAffected,
                color: "red",
                pointLabel: "#{stillAffected} out of 100 people would still have an exacerbation."
              },
              {
                val: treatmentRem,
                color: "blue",
                pointLabel: "#{treatmentRem} out of 100 people would NOT have an exacerbation."
              }
            ]
          }
        ]

      , (error) =>
        console.error error