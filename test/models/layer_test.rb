require 'test_helper'

class LayerTest < ActiveSupport::TestCase
  test 'layer permissions' do
    item = layers(:layer)
    assert item.permit_modify?(:user => users(:admin)) && !item.permit_modify?(:user => users(:user))
  end
end
