require 'rails/generators'

class RefsControllerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def create_controllers
    @name = name.underscore

    template 'refs_controller.rb.template', "app/controllers/#{@name}_controller.rb"
    directory 'views', "app/views/#{@name}"
    directory 'locales', 'config/locales'
  end
end