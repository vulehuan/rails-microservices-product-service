require 'rails_helper'

RSpec.describe 'Categories API', type: :request do
  let(:admin_token) { jwt_token_for('admin') }

  before do
    Category.destroy_all
    @categories = create_list(:category, 15)
    @category_id = @categories.first.id
  end
  let(:headers) { { 'Content-Type': 'application/json', 'Authorization': "Bearer #{admin_token}" } }

  describe 'GET /api/v1/categories' do
    context 'when categories exist' do
      before { get '/api/v1/categories', headers: headers }

      it 'returns categories with pagination metadata' do
        expect(json['data'].size).to eq(10) # Default per_page is 10 (Pagy::DEFAULT[:limit])
        expect(json['meta']).to include('page', 'count', 'pages')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when fetching a specific page' do
      before { get '/api/v1/categories?page=2&per_page=5', headers: headers }

      it 'returns correct categories for the page' do
        expect(json['data'].size).to eq(5)
        expect(json['meta']['page']).to eq(2)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /api/v1/categories/:id' do
    context 'when the category exists' do
      before { get "/api/v1/categories/#{@category_id}", headers: headers }

      it 'returns the category' do
        expect(json['data']['id']).to eq(@category_id)
        expect(json['data']['name']).to eq(@categories.first.name)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the category does not exist' do
      before { get '/api/v1/categories/999999', headers: headers }

      it 'returns a not found error' do
        expect(json['error']).to eq('Record not found')
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/categories' do
    let(:valid_attributes) { { name: 'New Category', status: true }.to_json }

    context 'when the request is valid' do
      it 'creates a new category' do
        expect {
          post '/api/v1/categories', params: valid_attributes, headers: headers
        }.to change(Category, :count).by(1)

        expect(json['data']['name']).to eq('New Category')
        expect(response).to have_http_status(:created)
      end
    end

    context 'when the request is invalid' do
      let(:invalid_attributes) { { status: true }.to_json }

      it 'returns an error' do
        post '/api/v1/categories', params: invalid_attributes, headers: headers
        expect(json['error']).to include("Invalid record")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT /api/v1/categories/:id' do
    let(:valid_attributes) { { name: 'Updated Name' }.to_json }

    context 'when the category exists' do
      before { put "/api/v1/categories/#{@category_id}", params: valid_attributes, headers: headers }

      it 'updates the category' do
        expect(json['data']['name']).to eq('Updated Name')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when category is invalid' do
      before { put "/api/v1/categories/#{@category_id}", params: {name: ''}.to_json, headers: headers }
      it 'raises an ActiveRecord::RecordInvalid error' do
        expect(json['error']).to include('Invalid record')
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the category does not exist' do
      before { put '/api/v1/categories/999', params: valid_attributes, headers: headers }

      it 'returns an error' do
        expect(json['error']).to eq('Record not found')
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/v1/categories/:id' do
    context 'when the category exists' do
      it 'deletes the category' do
        expect {
          delete "/api/v1/categories/#{@category_id}", headers: headers
        }.to change(Category, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the category does not exist' do
      before { delete '/api/v1/categories/999', headers: headers }

      it 'returns an error' do
        expect(json['error']).to eq('Record not found')
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
