crumb :root do
  link t('title'), root_path
end

[User, Track, Layer].each do |klass|
  crumb klass.pl_name do
    link klass.model_name.human(:count => 2), send("#{klass.pl_name}_path")
  end

  crumb klass.sm_name do |item|
    link item.name || t('lib_support.refs.new'), item.new_record? ? nil : send("#{klass.sm_name}_path", item)
    parent klass.pl_name
  end unless klass.sm_name == :track
end

crumb :user_tracks do |user|
  link Track.model_name.human(:count => 2), user_tracks_path(user || current_user)
  parent :user, user || current_user
end

crumb :track do |item|
  link item.name || t('lib_support.refs.new'), track_path(item)
  parent :user_tracks, item.user
end


# crumb :projects do
#   link "Projects", projects_path
# end

# crumb :project do |project|
#   link project.name, project_path(project)
#   parent :projects
# end

# crumb :project_issues do |project|
#   link "Issues", project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).