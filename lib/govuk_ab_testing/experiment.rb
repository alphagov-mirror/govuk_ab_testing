module GovukAbTesting
  class Experiment
    attr_reader :ab_test, :request

    delegate :request_header, :cookie_name, :response_header, to: :ab_test

    # @param experiment_name [String] Lowercase experiment name, like `example`
    # @param request [ApplicationController::Request] the `request` in the
    # controller.
    def initialize(experiment_name, request)
      @ab_test = AbTest.new(experiment_name)
      @request = request
    end

    # Get the bucket this user is in
    #
    # @return [String] the current variant, "A" or "B"
    def variant_name
      request.headers[request_header] == "B" ? "B" : "A"
    end

    # Configure the response
    #
    # @param [ApplicationController::Response] the `response` in the controller
    def add_response_header(response)
      response.headers['Vary'] = response_header
    end

    # HTML meta tag used to track the results of your experiment
    #
    # @return [String]
    def analytics_meta_tag
      '<meta name="govuk:ab-test" content="' + cookie_name + ':' + variant_name + '">'
    end
  end
end
