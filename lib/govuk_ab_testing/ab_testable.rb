module GovukAbTesting
  class AbTestable < Module
    def initialize(ab_test_name)
      @ab_test_name = ab_test_name

      define_method "#{ab_test_name}_ab_test" do
        GovukAbTesting::AbTest.new(ab_test_name)
      end

      define_method "requested_#{ab_test_name}_variant" do
        self.send("#{ab_test_name}_ab_test").requested_variant request
      end

      define_method "set_#{ab_test_name}_ab_header" do
        self.send("requested_#{ab_test_name}_variant").configure_response response
      end
    end

    def included(base)
      base.after_filter "set_#{@ab_test_name}_ab_header".to_sym
      base.helper_method "requested_#{@ab_test_name}_variant".to_sym
    end
  end
end