'use strict'

angular.module('dcida20App')
  .factory 'Sortable', ['$q', '_', ($q, _) ->

    deleteFromItemArray = (item, array) ->
      i = _.indexOf array, item
      if i > -1
        array.splice i, 1
      i

    fixItemOrders = (array, orderName, startIndex) ->
      if startIndex < array.length
        for index in [startIndex..array.length-1]
          #console.log array
          array[index][orderName] = index + 1

    addToItemArray: (item, array, orderName) ->
      array.splice(item[orderName] - 1, 0, item)
      for index in [item[orderName] - 1..array.length - 1]
        array[index][orderName] = index + 1

    # assumes presence of updateOrder function on item
    reorderItem: (item, array, orderName) ->
      d = $q.defer()
      item.updateOrder().then (it) =>
        # should be optimised to only iterate from fromIndex to toIndex
        fixItemOrders(array, orderName, 0)
        d.resolve(it)
      , (error) =>
        d.reject(error)
      d.promise

    finishItemDeletion: (item, array, orderName) ->
      startIndex = deleteFromItemArray(item, array)
      if orderName
        fixItemOrders(array, orderName, startIndex)

    # physically swap elements at indices
    swap: (array, x, y) ->
      b = array[x]
      array[x] = array[y]
      array[y] = b

  ]
