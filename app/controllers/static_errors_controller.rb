class StaticErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def too_many_requests
    render 'errors/too_many_requests', status: :too_many_requests, layout: false
  end

  def not_found
    render 'errors/not_found', status: :not_found, layout: false
  end

  def internal_error
    render 'errors/internal_error', status: :internal_server_error, layout: false
  end
end


