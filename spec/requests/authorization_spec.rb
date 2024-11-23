require 'rails_helper'

RSpec.describe 'Access Denied Handling', type: :request do
  let(:user_token) { jwt_token_for('user') }
  let(:headers) { { 'Content-Type': 'application/json', 'Authorization': "Bearer #{user_token}" } }

  before do
    allow_any_instance_of(Ability).to receive(:can?).with(:create, Product).and_return(false)
  end

  describe 'handling CanCan::AccessDenied' do
    context 'when user tries to access a forbidden resource' do
      before do
        allow(Sentry).to receive(:capture_exception)
      end

      it 'logs the error and returns a forbidden response' do
        post '/api/v1/products', params: { product: { name: 'Test Product' } }, headers: headers

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)['error']).to eq('Access Denied')

        expect(Sentry).to have_received(:capture_exception).with(instance_of(CanCan::AccessDenied))

        expect(response.body).to include('Access Denied')
      end
    end
  end
end
