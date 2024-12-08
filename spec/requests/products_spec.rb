require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Products API', type: :request do
  let(:admin_token) { jwt_token_for('admin') }
  let(:user_token) { jwt_token_for('user') }

  before do
    @categories = create_list(:category, 5)
    @products = create_list(:product, 15)
    @product_id = @products.first.id
  end
  let(:headers) { { 'Content-Type': 'application/json', 'Authorization': "Bearer #{admin_token}" } }

  path '/api/v1/products' do
    get 'Retrieve the list of products with admin role' do
      tags 'Products'
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'
      parameter name: :category_id, in: :query, type: :integer, required: false, description: 'Category ID'

      security [ { bearer_auth: [] } ]
      let(:Authorization) { "Bearer #{admin_token}" }

      response '200', 'Products retrieved without page query' do
        let(:page) { nil }
        schema '$ref' => '#/components/schemas/ProductsResponse'
        run_test! do |response|
          json_response = Oj.load(response.body)
          aggregate_failures 'returns products with the correct items count' do
            expect(json_response['data'].size).to eq(10)
          end

          aggregate_failures "does not include description in the response" do
            expect(json_response['data'].first).not_to have_key('description')
          end

          aggregate_failures "does not include lock_version in the response" do
            expect(json_response['data'].first).not_to have_key('lock_version')
          end
        end
      end

      response '200', 'Products when fetching a specific page' do
        let(:page) { 2 }
        let(:per_page) { 5 }
        schema '$ref' => '#/components/schemas/ProductsResponse'
        run_test! do |response|
          json_response = Oj.load(response.body)
          aggregate_failures 'returns correct products for the page' do
            expect(json_response['data'].size).to eq(5)
            expect(json_response['meta']['page']).to eq(2)
            expect(response).to have_http_status(:ok)
          end
        end
      end

      response '200', 'Products when filtering by category' do
        let(:category_id) { @products.first.category.id }
        schema '$ref' => '#/components/schemas/ProductsResponse'
        run_test! do |response|
          json_response = Oj.load(response.body)
          aggregate_failures "returns products from the specified category" do
            category_id = @products.first.category.id

            expect(response).to have_http_status(:ok)
            products = json_response["data"]
            products.each do |product|
              expect(product["category_id"]).to eq(category_id)
            end
          end
        end
      end
    end

    get 'Retrieve the list of products' do
      tags 'Products'
      produces 'application/json'

      security [ { bearer_auth: [] } ]
      let(:Authorization) { "Bearer #{user_token}" }
      response '200', 'Product list retrieved successfully' do
        let(:per_page) { 100 }
        schema '$ref' => '#/components/schemas/ProductsResponse'
        run_test! do |response|
          json_response = Oj.load(response.body)
          aggregate_failures "allows user to only see products with status true" do
            expect(response).to have_http_status(:ok)

            returned_ids = json_response['data'].map { |category| category['id'] }
            expected_ids = @products.select(&:status).map(&:id)

            expect(returned_ids).to match_array(expected_ids)
          end
        end
      end
    end
  end

  path '/api/v1/products/{id}' do
    get 'Retrieve product details' do
      tags 'Products'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'ID of the product'

      security [ { bearer_auth: [] } ]
      let(:Authorization) { "Bearer #{admin_token}" }
      let(:id) { @product_id }
      response '200', 'Product details retrieved successfully' do
        schema '$ref' => '#/components/schemas/Product'
        run_test! do |response|
          json_response = Oj.load(response.body)
          aggregate_failures 'returns the product' do
            expect(json_response['data']['id']).to eq(@product_id)
            expect(json_response['data']['name']).to eq(@products.first.name)
            expect(json_response['data']['category_id']).to eq(@products.first.category_id)
          end

          aggregate_failures "does not include lock_version in the response" do
            expect(json_response['data']).not_to have_key('lock_version')
          end

          aggregate_failures "includes description in the response" do
            expect(json_response['data']).to have_key('description')
          end
        end
      end

      response '404', 'Product does not exist' do
        schema '$ref' => '#/components/schemas/RecordNotFound'
        let(:id) { 999999 }
        run_test! do |response|
          json_response = Oj.load(response.body)
          aggregate_failures 'returns a not found error' do
            expect(json_response['error']).to eq('Record not found')
          end
        end
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
      before { put "/api/v1/products/#{@product_id}", params: { name: '' }.to_json, headers: headers }
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

  describe "PATCH #update_stock_batch" do
    context 'when all products have enough stock' do
      it 'reduces the stock_quantity correctly for each product' do
        products_data = [
          { product_id: @products.first.id, quantity: 2 },
          { product_id: @products.second.id, quantity: 3 }
        ]
        new_quantity1 = @products.first.stock_quantity - 2
        new_quantity2 = @products.second.stock_quantity - 3

        patch "/api/v1/products/update_stock/batch", params: { products: products_data }.to_json, headers: headers

        @products.first.reload
        @products.second.reload

        expect(@products.first.stock_quantity).to eq(new_quantity1)
        expect(@products.second.stock_quantity).to eq(new_quantity2)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['success']).to eq(true)
      end
    end

    context 'when a product has insufficient stock' do
      it 'sets stock_quantity to 0 if it goes below 0' do
        products_data = [
          { product_id: @products.first.id, quantity: 9999 },
          { product_id: @products.second.id, quantity: 9999 }
        ]

        patch "/api/v1/products/update_stock/batch", params: { products: products_data }.to_json, headers: headers

        @products.first.reload
        @products.second.reload

        expect(@products.first.stock_quantity).to eq(0)
        expect(@products.second.stock_quantity).to eq(0)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['success']).to eq(true)
      end
    end

    context 'when product_id is invalid' do
      it 'returns 404 for invalid product_id' do
        products_data = [
          { product_id: 999999, quantity: 5 }
        ]

        patch "/api/v1/products/update_stock/batch", params: { products: products_data }.to_json, headers: headers

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Record not found')
      end
    end
  end

  describe "PATCH #update_stock" do
    context "when the quantity is valid" do
      it "reduces stock_quantity correctly" do
        patch "/api/v1/products/#{@product_id}/update_stock",
              params: { quantity: 3 }.to_json, headers: headers
        new_quantity = @products.first.stock_quantity - 3
        @products.first.reload
        expect(@products.first.stock_quantity).to eq(new_quantity)
        expect(response).to have_http_status(:ok)
        expect(json).to eq({ "success" => true })
      end
    end

    context "when the quantity is greater than stock_quantity" do
      it "sets stock_quantity to 0" do
        patch "/api/v1/products/#{@product_id}/update_stock", params: { quantity: 9999 }.to_json, headers: headers
        @products.first.reload
        expect(@products.first.stock_quantity).to eq(0)
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ "success" => true })
      end
    end

    context "when the product does not exist" do
      it "returns a 404 not found error" do
        patch "/api/v1/products/9999/update_stock", params: { quantity: 10 }.to_json, headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the quantity is missing" do
      it "does not update stock_quantity and returns a 400 error" do
        patch "/api/v1/products/#{@product_id}/update_stock", params: {}.to_json, headers: headers
        quantity = @products.first.stock_quantity
        @products.first.reload
        expect(@products.first.stock_quantity).to eq(quantity)
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
