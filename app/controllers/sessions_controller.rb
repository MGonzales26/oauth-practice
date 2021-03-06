class SessionsController < ApplicationController
  
  def create
    client_id = '34a219ad7fc66212855c'
    client_secret = '0edef9fb94ed536ead4a4e8da893c4d368fcc998'
    code = params[:code]

    conn = Faraday.new(url: 'https://github.com', headers: { 'Accept': 'application/json'})

    response = conn.post('/login/oauth/access_token') do |req|
      req.params['code'] = code
      req.params['client_id'] = client_id
      req.params['client_secret'] = client_secret
    end

    data = JSON.parse(response.body, symbolize_names: true)
    access_token = data[:access_token]

    conn = Faraday.new(
      url: 'https://api.github.com',
      headers: {
          'Authorization': "token #{access_token}"
      }
    )
    response = conn.get('/user')
    data = JSON.parse(response.body, symbolize_names: true)

    user = User.find_or_create_by(uid: data[:id])
    user.username = data[:login]
    user.uid = data[:id]
    user.token = data[:access_token]
    user.save
    session[:user_id] = user.id

    redirect_to dashboard_path
  end
end