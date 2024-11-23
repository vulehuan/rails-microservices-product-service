class ApplicationController < ActionController::API
  rescue_from StandardError, with: :handle_error
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  def handle_error(exception)
    # SendErrorToSentryJob.perform_later(exception)
    Sentry.capture_exception(exception)
    logger.error "Error: #{exception.message}"
    logger.error "Backtrace: #{exception.backtrace.join("\n")}" if Rails.env.development? || Rails.env.test?

    render json: { error: "An unexpected error occurred" }, status: :internal_server_error
  end

  def record_not_found(exception)
    Sentry.capture_exception(exception)
    logger.error "Error: #{exception.message}"

    render json: { error: "Record not found" }, status: :not_found
  end

  def record_invalid(exception)
    Sentry.capture_exception(exception)
    logger.error "Error: #{exception.message}"

    render json: { error: "Invalid record" }, status: :unprocessable_entity
  end
end
