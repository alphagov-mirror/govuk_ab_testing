require 'spec_helper'

RSpec.describe GovukAbTesting::Experiment do
  describe '#variant_name' do
    it "returns the variant" do
      activesupport_request = double(headers: { 'HTTP_GOVUK_ABTEST_EDUCATION' => 'A'})

      experiment = GovukAbTesting::Experiment.new("education", activesupport_request)

      expect(experiment.variant_name).to eql("A")
    end
  end

  describe '#analytics_meta_tag' do
    it "returns the tag" do
      activesupport_request = double(headers: { 'HTTP_GOVUK_ABTEST_EDUCATION' => 'A'})

      experiment = GovukAbTesting::Experiment.new("education", activesupport_request)

      expect(experiment.analytics_meta_tag).to eql("<meta name=\"govuk:ab-test\" content=\"Education:A\">")
    end
  end
end
