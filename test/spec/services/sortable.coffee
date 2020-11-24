'use strict'

describe 'Service: Sortable', ->

  beforeEach angular.mock.module 'dcida20App'

  q = {}
  Sortable = {}
  _ = {}
  items = []

  beforeEach inject (_Sortable_, ___) ->
    item1 = {id: 1, order: 1}
    item2 = {id: 2, order: 2}
    items = [item1, item2]

    Sortable = _Sortable_
    _ = ___

  describe "addToItemArray", () ->

    it "should add a new item to the items array", () ->
      newItem = {id: 3, order: 3}
      expect(_.contains(items, newItem)).toBe false
      Sortable.addToItemArray(newItem, items, "order")
      expect(_.contains(items, newItem)).toBe true

  describe "finishItemDeletion", () ->

    it "should remove the item from the items array", () ->
      newItem = {id: 3, order: 3}
      Sortable.addToItemArray(newItem, items, "order")
      expect(_.contains(items, newItem)).toBe true
      Sortable.finishItemDeletion(newItem, items, "order")
      expect(_.contains(items, newItem)).toBe false

  describe "reorderItem", () ->

    it "should update the item order after reordering the item", () ->
      newItem = {id: 3, order: 3}
      newItem.updateOrder = () ->
        then: (fn) ->
          fn()

      Sortable.addToItemArray(newItem, items, "order")
      displacedItem = items[1]
      items[1] = newItem
      items[2] = displacedItem
      newItem.order = 2
      expect(displacedItem.order).toBe 2
      Sortable.reorderItem(newItem, items, 'order')
      expect(displacedItem.order).toBe 3
