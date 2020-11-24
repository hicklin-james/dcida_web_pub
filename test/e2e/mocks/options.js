module.exports = [
  {
    request: {
      path: 'http://localhost:3000/api/decision_aids/1/options',
      method: 'GET'
    },
    response: {
      data: {
        options: [
          {
            decision_aid_id: 1,
            id: 1,
            label: "Option 1",
            sub_option_ids: [],
            title: "Option 1",
            option_order: 1
          },
          {
            decision_aid_id: 1,
            id: 2,
            label: "Option 2",
            sub_option_ids: [],
            title: "Option 2",
            option_order: 2
          },
          {
            decision_aid_id: 1,
            id: 3,
            label: "Option 3",
            sub_option_ids: [],
            title: "Option 3",
            option_order: 3
          }
        ]
      }
    }
  }
]