require 'test/unit'

# Point Bundle Support requires at the sibling checkout when running from a
# terminal. Inside TextMate the editor provides TM_SUPPORT_PATH.
ENV['TM_SUPPORT_PATH'] ||= File.expand_path('../../../bundle-support.tmbundle/Support/shared', __dir__)

require_relative '../lib/doctohtml'

# Regression test: generate_stylesheet_from_theme asks tm_query for the
# fontName and fontSize settings. On a machine whose settings chain does not
# define them, tm_query prints a complaint and exits nonzero. The complaint
# leaked into the generated HTML ahead of the doctype, and the || fallbacks
# were dead code because backticks never return nil, so the font family came
# out empty. The lookup now silences stderr and falls back on empty output.
class DocToHtmlTest < Test::Unit::TestCase
  FIXTURES = File.expand_path('fixtures', __dir__)

  def setup
    @original_env = ENV.to_hash
    ENV['TM_QUERY'] = "#{FIXTURES}/bin/tm_query"
    ENV['TM_CURRENT_THEME_PATH'] = "#{FIXTURES}/simple.tmTheme"
  end

  def teardown
    ENV.replace(@original_env)
  end

  def test_stylesheet_falls_back_when_tm_query_has_no_font_settings
    stylesheet = generate_stylesheet_from_theme('test_theme')

    assert_include(stylesheet, 'Menlo-Regular')
    assert_include(stylesheet, 'font-size: 12px')
    assert_not_include(stylesheet, 'not found')
    assert_include(stylesheet, '#101010')
  end
end
