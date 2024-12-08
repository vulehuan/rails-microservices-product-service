# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: 'http://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'product.local'
            }
          }
        }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearer_format: :JWT
          }
        },
        schemas: {
          RecordNotFound: {
            type: :object,
            properties: {
              error: { type: :string }
            }
          },
          PaginationMeta: {
            type: :object,
            properties: {
              total_pages: { type: :integer },
              page: { type: :integer },
              total_result: { type: :integer },
              next_page: { type: [ :integer, :null ] }
            }
          },
          ProductCollection: {
            type: :array,
            items: {
              properties: {
                id: { type: :integer },
                image: { type: :string },
                category_id: { type: :integer },
                name: { type: :string },
                price: { type: :number },
                stock_quantity: { type: :integer },
                status: { type: :boolean }
              }
            }
          },
          ProductsResponse: {
            type: :object,
            properties: {
              data: { '$ref' => '#/components/schemas/ProductCollection' },
              meta: { '$ref' => '#/components/schemas/PaginationMeta' }
            }
          },
          Product: {
            type: :object,
            properties: {
              id: { type: :integer },
              image: { type: :string },
              category_id: { type: :integer },
              name: { type: :string },
              price: { type: :number },
              stock_quantity: { type: :integer },
              status: { type: :boolean },
              description: { type: :string },
              metadata: { type: :object }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
