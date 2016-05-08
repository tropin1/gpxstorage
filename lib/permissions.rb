module Permissions
  def self.extract_user(*opts)
    user = opts.extract_options!.dup[:user]
    user if user.is_a?(User)
  end
end