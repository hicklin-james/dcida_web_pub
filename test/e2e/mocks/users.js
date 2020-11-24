
module.exports = [
  {
    request: {
      path: 'http://localhost:3000/api/users/current',
      method: 'GET'
    },
    response: {
      data: {
        user: {
          id: 1,
          first_name: 'Joe',
          last_name: 'Connington',
          email: "admin@tt.com",
          is_superadmin: false
        }
      }
    }
  },
  {
    request: {
      path: 'http://localhost:3000/oauth/token',
      method: 'POST'
    },
    response: {
      data: {
        access_token: "123",
        refresh_token: "456"
      }
    }
  }

]