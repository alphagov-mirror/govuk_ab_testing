module GovukAbTesting
  module AbstractHelpers
    def acceptance_test_framework
      @acceptance_test_framework ||= GovukAbTesting.configuration.framework_class.new(self)
    end

    def with_variant(args)
      ab_test_name, variant = args.first
      dimension = args[:dimension]

      setup_ab_variant(ab_test_name, variant, dimension)

      yield

      assert_response_is_cached_by_variant(ab_test_name)

      unless args[:assert_meta_tag] == false
        assert_page_tracked_in_ab_test(ab_test_name, variant, dimension)
      end
    end

    def setup_ab_variant(ab_test_name, variant, dimension = 300)
      ab_test = AbTest.new(ab_test_name, dimension: dimension)
      acceptance_test_framework.set_header(ab_test.request_header, variant)
    end

    def assert_response_is_cached_by_variant(ab_test_name)
      ab_test = AbTest.new(ab_test_name, dimension: 300)
      vary_header_value = acceptance_test_framework.vary_header

      assert_contains_substring(
        string: vary_header_value,
        substring: ab_test.response_header,
        error_message: <<-ERROR
          The 'Vary' header is not being set for the '#{ab_test.name}' A/B test.
          You will need to use GovukAbTesting::RequestedVariant#configure_response in your controller:

            requested_variant.configure_response(response)

        ERROR
      )
    end

    def assert_response_not_modified_for_ab_test(ab_test_name)
      vary_header = acceptance_test_framework.vary_header
      assert_does_not_contain_substring(
        string: vary_header,
        substring: ab_test_name,
        error_message: <<-ERROR
          The 'Vary' header is being set by A/B test '#{ab_test_name}' on a page that should not be modified
          by the A/B test. Check for incorrect usage of GovukAbTesting::RequestedVariant#configure_response
          in your controller.

            'Vary': #{vary_header}

        ERROR
      )
    end

    def assert_page_not_tracked_in_ab_test(ab_test_name)
      ab_test_meta_tags =
        acceptance_test_framework.analytics_meta_tags_for_test(ab_test_name)

      assert_is_empty(
        enumerable: ab_test_meta_tags,
        error_message: <<-ERROR
          Found the following '#{ab_test_name}' A/B testing meta tag on a page that should not be modified by
          the A/B test:

            #{ab_test_meta_tags.first.content}

          Check for incorrect usage of GovukAbTesting::RequestedVariant#analytics_meta_tag
        ERROR
      )
    end

    def assert_page_tracked_in_ab_test(ab_test_name, variant, dimension)
      ab_test = AbTest.new(ab_test_name, dimension: dimension)

      ab_test_meta_tags =
        acceptance_test_framework.analytics_meta_tags_for_test(ab_test.name)

      assert_has_size(
        enumerable: ab_test_meta_tags,
        size: 1,
        error_message: <<-ERROR
          Incorrect number of analytics meta tags on the page for A/B test '#{ab_test.name}'.
          You may need to check usage of GovukAbTesting::RequestedVariant#analytics_meta_tag in your template(s):

            <%= requested_variant.analytics_meta_tag %>

        ERROR
      )

      meta_tag = ab_test_meta_tags.first
      expected_metatag_content = "#{ab_test.meta_tag_name}:#{variant}"

      assert_is_equal(
        expected: expected_metatag_content,
        actual: meta_tag.content,
        error_message: <<-ERROR
          The analytics meta tag content for A/B test '#{ab_test.name}' does not match the expected value.
          You may need to use GovukAbTesting::RequestedVariant#analytics_meta_tag in your template(s):

            <%= requested_variant.analytics_meta_tag %>

        ERROR
      )

      assert_not_blank(
        string: meta_tag.dimension,
        error_message: <<-ERROR
          The meta tag dimension for the '#{ab_test_name}' A/B test is blank.
        ERROR
      )

      unless ab_test.dimension.nil?
        assert_is_equal(
          expected: ab_test.dimension.to_s,
          actual: meta_tag.dimension.to_s,
          error_message: <<-ERROR
            The analytics meta tag for the '#{ab_test.name}' A/B test does not match the expected value.
          ERROR
        )
      end
    end
  end
end
