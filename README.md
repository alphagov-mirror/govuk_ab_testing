# GOV.UK A/B Testing

Gem to help with A/B testing on the GOV.UK platform.

## Technical documentation

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'govuk_ab_testing', '~> VERSION'
```

And then execute:

    $ bundle

### Usage

Before starting this, you'll need to

- get your cookie listed on [/help/cookies](https://www.gov.uk/help/cookies)
- configure the CDN [like we did for the Education Navigation test](https://github.com/alphagov/govuk-cdn-config/pull/17).
The cookie and header name in the CDN config must match the test name parameter
that you pass to the Gem. The cookie name is case-sensitive.
- configure Google Analytics (guidelines to follow)

To enable testing in the app, your Rails app needs:

1. Some piece of logic to be A/B tested
2. A HTML meta tag that will be used to measure the results, and which specifies
the dimension to use in Google Analytics
3. A response HTTP header that tells Fastly you're doing an A/B test

Start by defining which acceptance testing framework you will use. This gem
supports both Capybara and ActiveSupport. In order to configure it, add this to
your test helper file:

```
GovukAbTesting.configure do |config|
  config.acceptance_test_framework = :capybara # or :active_support
end
```

If we use capybara, the gem expects `page` to be defined in the scope of the
test cases. If we use ActiveSupport, the gem expects `@request` to be defined in
the scope of the test cases.

Now, let's say you have this controller:

```ruby
# app/controllers/party_controller.rb
class PartyController < ApplicationController
  def show
    ab_test = GovukAbTesting::AbTest.new("your_ab_test_name", dimension: 300)
    @requested_variant = ab_test.requested_variant(request.headers)
    @requested_variant.configure_response(response)

    if @requested_variant.variant_b?
      render "new_show_template_to_be_tested"
    else
      render "show"
    end
  end
end
```

Add this to your layouts, so that we have a meta tag that can be picked up
by the extension and analytics.

```html
<!-- application.html.erb -->
<head>
  <%= @requested_variant.analytics_meta_tag.html_safe %>
</head>
```

#### Test helpers

##### Minitest

The most common usage of an A/B test is to serve two different variants of the
same page. In this situation, you can test the controller using `with_variant`.
It will configure the request and assert that the response is configured
correctly:

```ruby
# test/controllers/party_controller_test.rb
class PartyControllerTest < ActionController::TestCase
  include GovukAbTesting::MinitestHelpers

  should "show the user the B version" do
    with_variant your_ab_test_name: "B" do
      get :show

      # Optional assertions about page content of the B variant
    end
  end
end
```

Pass the `assert_meta_tag: false` option to skip assertions about the `meta`
tag, for example because the variant returns a redirect response rather than
returning an HTML page.

```ruby
# test/controllers/party_controller_test.rb
class PartyControllerTest < ActionController::TestCase
  include GovukAbTesting::MinitestHelpers

  should "redirect the user the B version" do
    with_variant your_ab_test_name: "B", assert_meta_tag: false do
      get :show

      assert_response 302
      assert_redirected_to { controller: "other_controller", action: "show" }
    end
  end
end
```

To test the negative case in which a page is unaffected by the A/B test:

```ruby
# test/controllers/party_controller_test.rb
class PartyControllerTest < ActionController::TestCase
  include GovukAbTesting::MinitestHelpers

  should "show the original" do
    setup_ab_variant("your_ab_test_name", "B") # optionally pass in a analytics dimension as the third argument

    get :show

    assert_response_not_modified_for_ab_test("your_ab_test_name")
  end
end
```

There are some more fine-grained assertions which you can use to test a page
with A/B variants which should be cached separately, but which should be
excluded from the analytics:

```ruby
# test/controllers/party_controller_test.rb
class PartyControllerTest < ActionController::TestCase
  include GovukAbTesting::MinitestHelpers

  should "cache each variant but not add analytics" do
    setup_ab_variant("your_ab_test_name", "B")

    get :show

    assert_response_is_cached_by_variant("your_ab_test_name")
    assert_page_not_tracked_in_ab_test("your_ab_test_name")
  end
end
```

##### RSpec

It is also possible to use `with_variant` and all the individual setup and
assertions steps in RSpec tests. Here is an example of a spec file:

```ruby
# spec/features/ab_testing_spec.rb
feature "Viewing a page with an A/B test" do
  include GovukAbTesting::RspecHelpers

  scenario "viewing the B version of the page" do
    with_variant your_ab_test_name: 'B' do
      visit root_path

      expect(page).to have_breadcrumbs
      expect(page).to have_beta_label
    end
  end
end
```

As with the `minitest` version, you can also pass in the following options to
`with_variant`:

- `assert_meta_tag: false`
- `dimension: <number>`

### Current limitations

This library assumes we are only using one A/B test per page. The acceptance
test classes look for only one analytics' meta tag and will fail in the presence
of more than one.

### Running the test suite

`bundle exec rake`

### Documentation

See [RubyDoc](http://www.rubydoc.info/gems/govuk_ab_testing) for some limited documentation.

To run a Yard server locally to preview documentation, run:

    $ bundle exec yard server --reload

## Licence

[MIT License](LICENCE.txt)
