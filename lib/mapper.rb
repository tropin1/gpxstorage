class ActionDispatch::Routing::Mapper
  REF_ACTIONS = [:index, :show, :update, :new, :create, :remove, :index_items].freeze

  def ref_resources(*resources)
    options = resources.extract_options!.dup
    options.merge!({ :only => REF_ACTIONS - ( options[:except] || [] ) }) unless options[:only]

    resources.each do |resource|
      name, res, opts = resource.to_s, resource_controller_class(resource), options.dup
      if res.respond_to?(:ref_options)
        list = res.ref_options[:ref_actions]
        opts[:only] = list if list
      end

      scope resource do
        delete 'remove'      => "#{name}#remove", :as => "remove_#{name}" if opts[:only].include?(:remove)
        get    'index_items' => "#{name}#index_items", :as => "index_items_#{name}" if opts[:only].include?(:index_items)
      end

      opts[:only] = opts[:only] - [:remove, :index_items]
      resources resource, opts
    end

    resource_scope(:resources, Resource.new(resources.pop, options)) { yield } if block_given?

    self
  end

protected
  def resource_controller_class(res)
    "#{res.to_s.camelize}Controller".constantize
  end
end

module ActiveRecord
  module ConnectionAdapters
    module PostgreSQL
      module DatabaseStatements
        # общая таблица объектов
        def object_table_create(table_name = :objects)
          execute <<-SQL
            create sequence #{table_name.to_s}_id_seq;
          SQL

          create_table(table_name, :primary_key => :id, :id => false) do |t|
            t.integer     :id, :primary_key => true
            t.tsvector    :txt_index
            t.string      :type, :null => false, :limit => 50, :index => true
            t.timestamps  null: false
          end

          execute <<-SQL
            ALTER TABLE #{table_name.to_s}
              ALTER COLUMN id SET DEFAULT nextval('#{table_name.to_s}_id_seq');
            ALTER TABLE #{table_name.to_s}
              ALTER COLUMN updated_at SET DEFAULT now() at time zone 'UTC';
            ALTER TABLE #{table_name.to_s}
              ALTER COLUMN created_at SET DEFAULT now() at time zone 'UTC';
          SQL

          add_index table_name, :txt_index, using: :gin
        end

        # таблица объекта
        # inherits - наследуемая сущность
        # objects - таблица объектов
        def object_ref_create(table_name, options = {}, &block)
          obj_name = options[:objects] || 'objects'
          indexed_columns = options[:indexed_columns]

          create_table(table_name, options.merge(:primary_key => :id, :id => false, :options => "inherits (#{options[:inherits] || obj_name.to_s})"), &block)

          add_index table_name, :txt_index, using: :gin
          add_index table_name, :type

          execute <<-SQL
            ALTER TABLE #{table_name}
              ADD PRIMARY KEY (id);
            ALTER TABLE #{table_name}
              ALTER COLUMN type SET DEFAULT '#{table_name.camelize.singularize}';
          SQL

          if indexed_columns
            list = indexed_columns.map{|x| "coalesce(new.#{x.to_s}, '')"}.join(' || \' \' || ')

            execute <<-SQL
CREATE FUNCTION tu_change_#{table_name}()
RETURNS trigger AS
$body$
begin
 new.txt_index:=to_tsvector(unaccent(#{list}));
 return new;
end;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER;

CREATE TRIGGER #{table_name}_tbiu
  BEFORE INSERT OR UPDATE OF #{indexed_columns.join(',')}
  ON #{table_name} FOR EACH ROW
  EXECUTE PROCEDURE tu_change_#{table_name}();
            SQL
          end
        end

        def object_table_drop(table_name = :objects)
          drop_table table_name
          execute <<-SQL
            drop sequence #{table_name.to_s}_id_seq;
          SQL
        end

        def object_ref_drop(table_name, options = {})
          drop_table table_name
          execute <<-SQL
            drop function if exists tu_change_#{table_name}();
          SQL
        end
      end
    end
  end

  class Migration
    class CommandRecorder
      def object_table_create(*args, &block)
        record(:object_table_create, args, &block)
      end

      def object_ref_create(*args, &block)
        record(:object_ref_create, args, &block)
      end

      def invert_object_table_create(args, &block)
        [:object_table_drop, args, block]
      end

      def invert_object_ref_create(args, &block)
        [:object_ref_drop, args, block]
      end
    end
  end
end