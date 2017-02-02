module GovukAbTesting
  module MinitestHelpers
    def with_variant(args)
      experiment_name, variant = args.first

      experiment = GovukAbTesting::AbTest.new(experiment_name)

      previous_variant = @request.headers[experiment.request_header]
      @request.headers[experiment.request_header] = variant

      yield

      @request.headers[experiment.request_header] = previous_variant
    end

    def assert_ab_test_rendered(experiment_name)
      experiment = GovukAbTesting::RequestedVariant.new(experiment_name, @request)

      assert_equal experiment.response_header, response.headers['Vary']
      assert_meta_tag "govuk:ab-test", experiment.cookie_name + ':' + experiment.variant_name
    end

  private

    def assert_meta_tag(name, content)
      assert_select "meta[name='#{name}'][content='#{content}']"
    end
  end
end
