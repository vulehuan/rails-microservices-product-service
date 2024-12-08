module Api
  module V1
    class ProductsController < ApplicationController
      before_action :set_product, only: [:show, :update, :destroy, :update_stock]

      # GET /api/v1/products
      def index
        authorize! :read, Product
        pagy, products = pagy(filtered_products, limit: per_page, page: current_page)

        render json: {
          data: ActiveModelSerializers::SerializableResource.new(products,
                                                                 each_serializer: ProductCollectionSerializer).as_json,
          meta: pagination_meta(pagy)
        }
      end

      # GET /api/v1/products/:id
      def show
        authorize! :read, @product
        render json: { data: ActiveModelSerializers::SerializableResource.new(@product).as_json }, status: :ok
      end

      # POST /api/v1/products
      def create
        authorize! :create, Product
        product = Product.new(product_params)
        raise ActiveRecord::RecordInvalid unless product.save

        render json: { message: 'Product created successfully',
                       data: ActiveModelSerializers::SerializableResource.new(product).as_json }, status: :created
      end

      # PUT/PATCH /api/v1/products/:id
      def update
        authorize! :update, @product
        raise ActiveRecord::RecordInvalid unless @product.update(product_params)

        render json: { message: 'Product updated successfully',
                       data: ActiveModelSerializers::SerializableResource.new(@product).as_json }, status: :ok
      end

      # DELETE /api/v1/products/:id
      def destroy
        authorize! :destroy, @product
        @product.destroy
        render json: { message: 'Product deleted successfully' }, status: :ok
      end

      # Todo: Use Event-Driven Architecture (message queue such as RabbitMQ, Kafka, Redis or Amazon SNS & Amazon SQS) in practice
      # PATCH /api/v1/products/:id/update_stock
      def update_stock
        return render json: { success: false }, status: :bad_request if params[:quantity].to_i <= 0

        @product.stock_quantity -= params[:quantity].to_i
        @product.stock_quantity = 0 if @product.stock_quantity < 0
        @product.save!
        render json: { success: true }, status: :ok
      end

      # Todo: Use Event-Driven Architecture (message queue such as RabbitMQ, Kafka, Redis or Amazon SNS & Amazon SQS) in practice
      # PATCH /api/v1/products/update_stock_batch
      def update_stock_batch
        params[:products].each do |product_data|
          product = Product.find(product_data[:product_id])
          quantity = product_data[:quantity].to_i
          product.stock_quantity -= quantity
          product.stock_quantity = 0 if product.stock_quantity < 0
          product.save!
        end

        render json: { success: true }, status: :ok
      end

      private

      def filtered_products
        if params[:category_id].present?
          Product.accessible_by(current_ability).where(category_id: params[:category_id])
        else
          Product.accessible_by(current_ability)
        end
      end

      def product_params
        params.require(:product).permit(:name, :description, :price, :status, :metadata, :category_id)
      end

      def set_product
        @product = Product.accessible_by(current_ability).find(params[:id])
      end
    end
  end
end
