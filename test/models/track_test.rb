require 'test_helper'

class TrackTest < ActiveSupport::TestCase
  # is user allowed to view other user's public tracks (yes)
  test 'public tracks permissions for non-owner view' do
    assert tracks(:public_admin_track).permit?(:user => users(:user))
  end

  # is user allowed to change other user's public tracks (no)
  test 'public track permissions for non-owner edit' do
    assert !tracks(:public_admin_track).permit_modify?(:user => users(:user))
  end

  # is user allowed to view other user's private tracks (no)
  test 'private tracks permissions for non-owner view' do
    assert !tracks(:private_admin_track).permit?(:user => users(:user))
  end

  # is user allowed to change other user's private tracks (no)
  test 'private tracks permissions for non-owner edit' do
    assert !tracks(:private_admin_track).permit_modify?(:user => users(:user))
  end

  # is admin allowed to view and edit other's private tracks
  test 'private tracks for admin' do
    track = tracks(:private_user_track)
    assert track.permit?(:user => users(:admin)) && track.permit_modify?(:user => users(:admin))
  end
end
