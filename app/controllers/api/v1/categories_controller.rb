module Api
  module V1
    class CategoriesController < ApplicationController
      include Pagy::Backend

      before_action :set_category, only: [:show, :update, :destroy]

      # GET /api/v1/categories
      def index
        authorize! :read, Category
        pagy, categories = pagy(Category.accessible_by(current_ability), limit: params[:per_page] || 10)
        render json: {
          data: ActiveModelSerializers::SerializableResource.new(categories).as_json,
          meta: pagy_metadata(pagy)
        }, status: :ok
      end

      # GET /api/v1/categories/:id
      def show
        authorize! :read, @category
        render json: { data: ActiveModelSerializers::SerializableResource.new(@category).as_json }, status: :ok
      end

      # POST /api/v1/categories
      def create
        authorize! :create, Category
        category = Category.new(category_params)
        raise ActiveRecord::RecordInvalid unless category.save

        render json: { message: 'Category created successfully',
                       data: ActiveModelSerializers::SerializableResource.new(category).as_json }, status: :created
      end

      # PUT /api/v1/categories/:id
      def update
        authorize! :update, @category
        raise ActiveRecord::RecordInvalid unless @category.update(category_params)

        render json: { message: 'Category updated successfully',
                       data: ActiveModelSerializers::SerializableResource.new(@category).as_json }, status: :ok
      end

      # DELETE /api/v1/categories/:id
      def destroy
        authorize! :destroy, @category
        @category.destroy
        render json: { message: 'Category deleted successfully' }, status: :ok
      end

      private

      def set_category
        @category = Category.accessible_by(current_ability).find(params[:id])
      end

      def category_params
        params.require(:category).permit(:name, :status)
      end
    end
  end
end
