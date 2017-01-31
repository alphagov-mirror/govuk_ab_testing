module GovukAbTesting
  class AbTest
    attr_reader :experiment_name

    def initialize(experiment_name)
      @experiment_name = experiment_name
    end

    # Internal name of the header
    def request_header
      "HTTP_GOVUK_ABTEST_#{experiment_name.upcase}"
    end

    def response_header
      "GOVUK-ABTest-#{cookie_name}"
    end

    # `example` -> `Example`
    def cookie_name
      experiment_name.capitalize
    end
  end
end
