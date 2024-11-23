module AuthHelpers
  def jwt_token_for(role)
    payload = { role: role }
    JWT.encode(payload, ENV['JWT_KEY'], 'HS256')
  end
end

RSpec.configure do |config|
  config.include AuthHelpers
end
