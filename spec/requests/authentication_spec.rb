require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  let(:headers) { { 'Content-Type': 'application/json' } }

  describe 'authenticate_request' do
    context 'when token is not provided' do
      it 'returns a 401 unauthorized error' do
        get '/api/v1/products', headers: headers

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Token not provided')
      end
    end

    context 'when token is invalid' do
      let(:invalid_token) { 'invalid.token.here' }
      let(:headers_with_invalid_token) { headers.merge('Authorization': "Bearer #{invalid_token}") }

      it 'returns a 401 unauthorized error with an invalid token message' do
        get '/api/v1/products', headers: headers_with_invalid_token

        expect(response).to have_http_status(:unauthorized)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to eq('Invalid or expired token')
        expect(response_body['message']).to be_present
      end
    end
  end
end
