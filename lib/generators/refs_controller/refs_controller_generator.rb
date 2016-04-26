class RefsControllerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def create_controllers
    @name = name.underscore
    template 'refs_controller.rb', "app/controllers/#{@name}_controller.rb"
  end
end