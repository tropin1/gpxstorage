module Permissions
  def self.extract_user(*opts)
    user = opts[:user]
    user if user.is_a?(User)
  end
end