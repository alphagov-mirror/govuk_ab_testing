module GovukAbTesting
  class RequestedVariant
    attr_reader :ab_test, :request

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
      request.headers[ab_test.request_header] == "B" ? "B" : "A"
    end

    # @return [Boolean] if the user is to be served variant A
    def variant_a?
      variant_name == "A"
    end

    # @return [Boolean] if the user is to be served variant B
    def variant_b?
      variant_name == "B"
    end

    # Configure the response
    #
    # @param [ApplicationController::Response] the `response` in the controller
    def add_response_header(response)
      response.headers['Vary'] = ab_test.response_header
    end

    # HTML meta tag used to track the results of your experiment
    #
    # @return [String]
    def analytics_meta_tag
      '<meta name="govuk:ab-test" content="' + ab_test.cookie_name + ':' + variant_name + '">'
    end
  end
end
