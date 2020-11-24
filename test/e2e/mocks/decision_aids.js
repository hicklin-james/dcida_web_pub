module.exports = [
  {
    request: {
      path: 'http://localhost:3000/api/decision_aids',
      method: 'GET'
    },
    response: {
      data: {
        decision_aids: [
          {
            id: 1,
            title: 'Standard Decision Aid',
            slug: "sda",
            description: "Description",
            updated_at: null,
            creator: "Joe Connington",
            decision_aid_type: "standard"
          },
          {
            id: 2,
            title: 'BW Decision Aid',
            slug: "BW",
            description: "Description",
            updated_at: null,
            creator: "Joe Connington",
            decision_aid_type: "best_worst"
          },
          {
            id: 3,
            title: 'DCE Decision Aid',
            slug: "DCE",
            description: "Description",
            updated_at: null,
            creator: "Joe Connington",
            decision_aid_type: "dce"
          },
          {
            id: 4,
            title: 'TR Decision Aid',
            slug: "TR",
            description: "Description",
            updated_at: null,
            creator: "Joe Connington",
            decision_aid_type: "option_rankings"
          }
        ]
      }
    }
  },
  {
    request: {
      path: "http://localhost:3000/api/decision_aids/5",
      method: "GET"
    },
    response: {
      data: {
        decision_aid: {
          id: 5,
          title: "Standard from protractor",
          slug: "sfp",
          description: "blah",
          updated_at: null,
          creator: "Joe Connington",
          decision_aid_type: "standard"
        }
      }
    }
  },
  {
    request: {
      path: "http://localhost:3000/api/decision_aids/1",
      method: "GET"
    },
    response: {
      data: {
        decision_aid: {
          id: 1,
          title: 'Standard Decision Aid',
          slug: "sda",
          description: "Description",
          updated_at: null,
          creator: "Joe Connington",
          decision_aid_type: "standard"
        }
      }
    }
  },
  {
    request: {
      path: "http://localhost:3000/api/decision_aids/1",
      method: "DELETE"
    },
    response: {
      status: 200
    }
  }
]