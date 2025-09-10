module Controller
  class HealthcheckController < Controller::BaseController
    get "/healthcheck" do
      status 200
    end
  end
end
