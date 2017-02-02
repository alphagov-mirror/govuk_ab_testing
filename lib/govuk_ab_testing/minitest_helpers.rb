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
      ab_test = GovukAbTesting::AbTest.new(ab_test_name)
      requested_variant = ab_test.requested_variant @request

      assert_equal ab_test.response_header, response.headers['Vary']
      assert_meta_tag "govuk:ab-test", ab_test.meta_tag_name + ':' + requested_variant.variant_name
    end

  private

    def assert_meta_tag(name, content)
      assert_select "meta[name='#{name}'][content='#{content}']"
    end
  end
end
