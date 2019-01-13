require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'warning_svg' do
    assert_equal warning_svg, WARNING_SVG
  end

  test 'star_svg' do
    assert_equal star_svg, STAR_SVG
  end

  test 'flash_class levels' do
    assert_equal flash_class(:notice), 'info'
    assert_equal flash_class(:error), 'error'
    assert_equal flash_class(:alert), 'warning'
  end
end
