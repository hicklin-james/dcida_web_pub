'use strict'

describe 'Service: DecisionAidUserProperty', ->

  beforeEach angular.mock.module 'dcida20App'

  DecisionAidUserProperty = {}
  _ = {}

  decisionAidUser = 
    id: 1

  decisionAidUserProperties = [
    id: 1
    property_id: 1
    weight: 2
   ,
    id: 2
    property_id: 2
    weight: 8
  ]

  beforeEach inject (_DecisionAidUserProperty_, ___) ->
    DecisionAidUserProperty = _DecisionAidUserProperty_
    _ = ___

  describe "sanitizeForUpdate", () ->
    it "should remove properties that aren't in attributes", () ->
      _.each decisionAidUserProperties, (dauop) ->
        dauop.bad_attribute = "yay"
        expect(dauop.bad_attribute).toBeDefined()
      sanitizedProps = DecisionAidUserProperty.sanitizeForUpdate(decisionAidUserProperties)
      expect(sanitizedProps.length).toBe > 0
      _.each sanitizedProps, (p) ->
        expect(p.bad_attribute).not.toBeDefined()
        expect(p.id).toBeDefined()

  describe "normalize_patient_weights", () ->
    it "should normalize each weight to a fraction of the total weight", () ->
      normalizedWeights = DecisionAidUserProperty.normalize_patient_weights(decisionAidUserProperties)
      expect(normalizedWeights[1]).toBeDefined()
      expect(normalizedWeights[2]).toBeDefined()
      expect(normalizedWeights[1]).toEqual 0.2
      expect(normalizedWeights[2]).toEqual 0.8

  describe "generateSampleUserProperties", () ->
    it "should return sample user properties based on props", () ->
      props = [
        id: 1
        title: "1"
       ,
        id: 2
        title: "2"
      ]
      sampleProps = DecisionAidUserProperty.generateSampleUserProperties(2, props, ["#aaa", "#bbb"])
      expect(sampleProps.length).toEqual props.length



