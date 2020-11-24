module.exports = [
  {
    request: {
      path: 'http://localhost:3000/api/decision_aids/1/properties',
      method: 'GET'
    },
    response: {
      data: {
        properties: [
          {
            decision_aid_id: 1,
            id: 1,
            title: "Property 1",
            property_order: 1
          },
          {
            decision_aid_id: 1,
            id: 2,
            title: "Property 2",
            property_order: 2
          },
          {
            decision_aid_id: 1,
            id: 3,
            title: "Property 3",
            property_order: 3
          }
        ]
      }
    }
  }
]