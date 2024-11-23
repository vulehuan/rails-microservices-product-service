require 'rails_helper'

RSpec.describe 'Products API', type: :request do
  let(:admin_token) { jwt_token_for('admin') }
  let(:user_token) { jwt_token_for('user') }

  before do
    Category.destroy_all
    Product.destroy_all
    @categories = create_list(:category, 5)
    @products = create_list(:product, 15)
    @product_id = @products.first.id
  end
  let(:headers) { { 'Content-Type': 'application/json', 'Authorization': "Bearer #{admin_token}" } }

  describe 'GET /api/v1/products' do
    context 'when products exist' do
      before { get '/api/v1/products', headers: headers }

      it 'returns products with pagination metadata' do
        expect(json['data'].size).to eq(10) # Default per_page is 10
        expect(json['meta']).to include('page', 'count', 'pages')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when fetching a specific page' do
      before { get '/api/v1/products?page=2&per_page=5', headers: headers }

      it 'returns correct products for the page' do
        expect(json['data'].size).to eq(5)
        expect(json['meta']['page']).to eq(2)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when filtering by category" do
      it "returns products from the specified category" do
        category_id = @products.first.category.id
        get "/api/v1/products", params: { category_id: category_id }, headers: headers

        expect(response).to have_http_status(:ok)
        products = json["data"]
        products.each do |product|
          expect(product["category_id"]).to eq(category_id)
        end
      end
    end

    it "allows user to only see products with status true" do
      user_headers = { 'Content-Type': 'application/json', 'Authorization': "Bearer #{user_token}" }
      get "/api/v1/products?per_page=100", headers: user_headers
      expect(response).to have_http_status(:ok)

      returned_ids = json['data'].map { |category| category['id'] }
      expected_ids = @products.select(&:status).map(&:id)

      expect(returned_ids).to match_array(expected_ids)
    end
  end

  describe 'GET /api/v1/products/:id' do
    context 'when the product exists' do
      before { get "/api/v1/products/#{@product_id}", headers: headers }

      it 'returns the product' do
        expect(json['data']['id']).to eq(@product_id)
        expect(json['data']['name']).to eq(@products.first.name)
        expect(json['data']['category_id']).to eq(@products.first.category_id)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the product does not exist' do
      before { get '/api/v1/products/999999', headers: headers }

      it 'returns a not found error' do
        expect(json['error']).to eq('Record not found')
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/products' do
    let(:valid_attributes) { { name: 'New Product', description: 'Product description', price: 100.0,
                               metadata: { param_1: "Taylor" }.to_json, category_id: @categories.first.id }.to_json }

    context 'when the request is valid' do
      it 'creates a new product' do
        expect {
          post '/api/v1/products', params: valid_attributes, headers: headers
        }.to change(Product, :count).by(1)

        expect(json['data']['name']).to eq('New Product')
        expect(response).to have_http_status(:created)
      end
    end

    context 'when the request is invalid' do
      let(:invalid_attributes) { { description: 'No name', price: -10 }.to_json } # Missing name, invalid price

      it 'returns an error' do
        post '/api/v1/products', params: invalid_attributes, headers: headers
        expect(json['error']).to include('Invalid record')
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT /api/v1/products/:id' do
    let(:valid_attributes) { { name: 'Updated Product', price: 120.0 }.to_json }

    context 'when the product exists' do
      before { put "/api/v1/products/#{@product_id}", params: valid_attributes, headers: headers }

      it 'updates the product' do
        expect(json['data']['name']).to eq('Updated Product')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when product is invalid' do
      before { put "/api/v1/products/#{@product_id}", params: {name: ''}.to_json, headers: headers }
      it 'raises an ActiveRecord::RecordInvalid error' do
        expect(json['error']).to include('Invalid record')
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the product does not exist' do
      before { put '/api/v1/products/999', params: valid_attributes, headers: headers }

      it 'returns an error' do
        expect(json['error']).to eq('Record not found')
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/v1/products/:id' do
    context 'when the product exists' do
      it 'deletes the product' do
        expect {
          delete "/api/v1/products/#{@product_id}", headers: headers
        }.to change(Product, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the product does not exist' do
      before { delete '/api/v1/products/999', headers: headers }

      it 'returns an error' do
        expect(json['error']).to eq('Record not found')
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
