module Api
  module V1
    class ProductsController < ApplicationController
      include Pagy::Backend

      before_action :set_product, only: [:show, :update, :destroy]

      # GET /api/v1/products
      def index
        pagy, products = pagy(Product.all, items: params[:per_page] || 10)

        render json: {
          data: products,
          meta: pagy_metadata(pagy)
        }
      end

      # GET /api/v1/products/:id
      def show
        render json: { data: @product }, status: :ok
      end

      # POST /api/v1/products
      def create
        product = Product.new(product_params)

        if product.save
          render json: { message: 'Product created successfully', data: product }, status: :created
        else
          render json: { error: product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PUT/PATCH /api/v1/products/:id
      def update
        if @product.update(product_params)
          render json: { message: 'Product updated successfully', data: @product }, status: :ok
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/products/:id
      def destroy
        @product.destroy
        render json: { message: 'Product deleted successfully' }, status: :ok
      end

      private

      def product_params
        params.require(:product).permit(:name, :description, :price, :status, :metadata, :category_id)
      end

      # Set product by finding it from database based on ID
      def set_product
        @product = Product.find_by(id: params[:id])
        render json: { error: 'Product not found' }, status: :not_found unless @product
      end
    end
  end
end
