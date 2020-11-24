module.exports = [
  {
    request: {
      path: 'http://localhost:3000/api/decision_aids/1/option_properties',
      method: 'GET'
    },
    response: {
      data: {
        option_properties: [
          {
            decision_aid_id: 1,
            option_id: 1,
            property_id: 1,
            id: 1,
            short_label: "O1P1"
          },
          {
            decision_aid_id: 1,
            option_id: 1,
            property_id: 2,
            id: 2,
            short_label: "O1P2"
          },
          {
            decision_aid_id: 1,
            option_id: 2,
            property_id: 1,
            id: 3,
            short_label: "O2P1"
          },
          {
            decision_aid_id: 1,
            option_id: 2,
            property_id: 2,
            id: 4,
            short_label: "O2P2"
          }
        ]
      }
    }
  }
]