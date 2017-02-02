module GovukAbTesting
  module MinitestHelpers
    def with_variant(args)
      ab_test_name, variant = args.first

      ab_test = GovukAbTesting::AbTest.new(ab_test_name)

      previous_variant = @request.headers[ab_test.request_header]
      @request.headers[ab_test.request_header] = variant

      yield

      @request.headers[ab_test.request_header] = previous_variant
    end

    def assert_ab_test_rendered(ab_test_name)
      requested_variant = GovukAbTesting::RequestedVariant.new(ab_test_name, @request)

      assert_equal requested_variant.response_header, response.headers['Vary']
      assert_meta_tag "govuk:ab-test", requested_variant.meta_tag_name + ':' + requested_variant.variant_name
    end

  private

    def assert_meta_tag(name, content)
      assert_select "meta[name='#{name}'][content='#{content}']"
    end
  end
end
