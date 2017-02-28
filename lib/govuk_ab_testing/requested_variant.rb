module GovukAbTesting
  class RequestedVariant
    attr_reader :ab_test, :request_headers

    # @param ab_test [AbTest] the A/B test being performed
    # @param request_headers [ActionDispatch::Http::Headers] the
    # `request.headers` in the controller.
    # @param dimension [Integer] the dimension registered with Google Analytics
    # for this specific A/B test
    def initialize(ab_test, request_headers, dimension)
      @ab_test = ab_test
      @request_headers = request_headers
      @dimension = dimension
    end

    # Get the bucket this user is in
    #
    # @return [String] the current variant, "A" or "B"
    def variant_name
      request_headers[ab_test.request_header] == "B" ? "B" : "A"
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
    def configure_response(response)
      response.headers['Vary'] = [response.headers['Vary'], ab_test.response_header].compact.join(', ')
    end

    # HTML meta tag used to track the results of your experiment
    #
    # @return [String]
    def analytics_meta_tag
      '<meta name="govuk:ab-test" ' +
        'content="' + ab_test.meta_tag_name + ':' + variant_name + '" ' +
        'data-analytics-dimension="' + @dimension.to_s + '">'
    end
  end
end
