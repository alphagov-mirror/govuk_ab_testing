module GovukAbTesting
  class AbTest
    attr_reader :ab_test_name

    def initialize(ab_test_name)
      @ab_test_name = ab_test_name
    end

    # @param request [ApplicationController::Request] the `request` in the
    # controller.
    def requested_variant(request)
      RequestedVariant.new(self, request)
    end

    # Internal name of the header
    def request_header
      "HTTP_GOVUK_ABTEST_#{ab_test_name.upcase}"
    end

    def response_header
      "GOVUK-ABTest-#{meta_tag_name}"
    end

    # `example` -> `Example`
    def meta_tag_name
      ab_test_name.capitalize
    end

    def self.with_ab_testing(ab_test_name, request)
      ab_test_name = ab_test_name.to_s
      ab_test = AbTest.new(ab_test_name)
      puts "Inside block"
      puts local_variables
      puts request
      requested_variant = ab_test.requested_variant request
      requested_variant.configure_response yield
    end
  end
end
