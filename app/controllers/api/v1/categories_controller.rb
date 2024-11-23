module Api
  module V1
    class CategoriesController < ApplicationController
      include Pagy::Backend

      before_action :set_category, only: [:show, :update, :destroy]

      # GET /api/v1/categories
      def index
        pagy, categories = pagy(Category.all, items: params[:per_page] || 10)
        render json: {
          data: categories,
          meta: pagy_metadata(pagy)
        }, status: :ok
      end

      # GET /api/v1/categories/:id
      def show
        render json: { data: @category }, status: :ok
      end

      # POST /api/v1/categories
      def create
        category = Category.new(category_params)
        if category.save
          render json: { message: 'Category created successfully', data: category }, status: :created
        else
          render json: { error: category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/categories/:id
      def update
        if @category.update(category_params)
          render json: { message: 'Category updated successfully', data: @category }, status: :ok
        else
          render json: { error: @category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/categories/:id
      def destroy
        @category.destroy
        render json: { message: 'Category deleted successfully' }, status: :ok
      end

      private

      def set_category
        @category = Category.find_by(id: params[:id])
        render json: { error: 'Category not found' }, status: :not_found unless @category
      end

      def category_params
        params.require(:category).permit(:name, :status)
      end
    end
  end
end
