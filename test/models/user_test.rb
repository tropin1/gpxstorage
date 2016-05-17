require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'user edit permissions' do
    user = users(:user)
    admin = users(:admin)

    assert user.permit_modify?(:user => user) && user.permit_modify?(:user => admin) && !admin.permit_modify?(:user => user)
  end

  test 'user view permissions' do
    user = users(:user)
    admin = users(:admin)

    assert user.permit?(:user => user) && user.permit?(:user => admin) && admin.permit?(:user => user)
  end
end
