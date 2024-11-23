module Api
  module V1
    class ProductsController < ApplicationController
      include Pagy::Backend

      before_action :set_product, only: [:show, :update, :destroy]

      # GET /api/v1/products
      def index
        pagy, products = pagy(filtered_products, items: params[:per_page] || 10)

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
          raise ActiveRecord::RecordInvalid
        end
      end

      # PUT/PATCH /api/v1/products/:id
      def update
        if @product.update(product_params)
          render json: { message: 'Product updated successfully', data: @product }, status: :ok
        else
          raise ActiveRecord::RecordInvalid
        end
      end

      # DELETE /api/v1/products/:id
      def destroy
        @product.destroy
        render json: { message: 'Product deleted successfully' }, status: :ok
      end

      private

      def filtered_products
        if params[:category_id].present?
          Product.where(category_id: params[:category_id])
        else
          Product.all
        end
      end

      def product_params
        params.require(:product).permit(:name, :description, :price, :status, :metadata, :category_id)
      end

      def set_product
        @product = Product.find(params[:id])
      end
    end
  end
end
