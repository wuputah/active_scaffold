require "rails_generator/generators/components/scaffold/scaffold_generator"

class ActiveScaffoldingSandbox < ScaffoldingSandbox #:nodoc:
  def default_input_block
    input_block = Proc.new { |record, column| "
      <li class=\"form-element <%= 'required' if active_scaffold_config.columns[:#{column.name}].required? %>\">
        <dl>
          <dt>
            <label for=\"record_#{column.name}\"><%= active_scaffold_config.columns[:#{column.name}].label %></label>
          </dt>
          <dd>
            <%= active_scaffold_input_for active_scaffold_config.columns[:#{column.name}] %>
              <span class=\"description\"><%= active_scaffold_config.columns[:#{column.name}].description %></span>
          </dd>
        </dl>
      </li>"}
  end
  
  def default_show_block
    input_block = Proc.new { |record, column| "
          <dt><%= active_scaffold_config.columns[:#{column.name}].label -%></dt>
          <dd><%= get_column_value(@record, active_scaffold_config.columns[:#{column.name}]) -%> &nbsp;</dd>"}
  end
  
  def default_column_block
    Proc.new { |record, column| 
      column_name = column.name
      column_name = column_name[0..-4] if column_name[-3, 3] == "_id"
"      [:#{column_name} => {
        :exclude => [:field_search, :list]
      }]," }
  end
  
  def all_columns(record, record_name, options) 
    if options[:has_columns]
      input_block = options[:input_block] || default_column_block
    elsif options[:show_columns]
      input_block = options[:input_block] || default_show_block
    else
      input_block = options[:input_block] || default_input_block
    end
    
    if !options[:exclude].blank?
      filtered_content_columns = record.class.columns.reject { |column| options[:exclude].include?(column.name) }
    else
      filtered_content_columns = record.class.columns
    end
    
    filtered_content_columns.collect{ |column| input_block.call(record_name, column) }.join("\n")
  end

end

class Rails::Generator::Commands::Base #:nodoc:
  def template_part_mark(name, id)
    if name.blank?
      "\n"
    else
      "<!--[#{name}:#{id}]-->\n"
    end
  end  

end

class ActionView::Helpers::InstanceTag #:nodoc:
  alias_method :base_to_input_field_tag, :to_input_field_tag

  def to_input_field_tag(field_type, options={})
    options[:class] = 'text-input'  
    base_to_input_field_tag field_type, options
  end
  
  def to_boolean_select_tag(options = {})
    options = options.stringify_keys
    add_default_name_and_id(options)
    tag_text = "<%= select \"#{@object_name}\", \"#{@method_name}\", [[\"True\", true], [\"False\", false]], { :selected => @#{@object_name}.#{@method_name} } %>"
  end
  
end

class ActiveScaffoldGenerator < ScaffoldGenerator #:nodoc:

  alias_method :base_controller_file_path, :controller_file_path
  attr_reader :flags
  
  def initialize(*runtime_args)
    super(*runtime_args)
    @flags = args
  end  

  def controller_file_path
    "/" + base_controller_file_path
  end

  def manifest
  
    record do |m|
      
      # Check for class naming collisions.
      m.class_collisions controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}ControllerTest", "#{controller_class_name}Helper"
      m.class_collisions class_path, class_name, "#{singular_name}Test"

      # Model, controller, helper, views, and test directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join('test/unit', class_path)
      m.directory File.join('test/fixtures', class_path)
      m.directory File.join('app/controllers', controller_class_path)
      m.directory File.join('app/helpers', controller_class_path)
      m.directory File.join('app/views', controller_class_path, controller_file_name)
      m.directory File.join('app/views/layouts', controller_class_path)
      m.directory File.join('test/functional', controller_class_path)

      # Unit test, and fixtures.
      m.template 'unit_test.rb',  File.join('test/unit', "#{singular_name}_test.rb")
      m.template 'fixtures.yml',  File.join('test/fixtures', "#{singular_name}.yml")
      
      m.complex_template 'model.rb',
        File.join('app/models', "#{singular_name}.rb"),
        :insert => 'model_scaffolding.rhtml',
        :sandbox => lambda { create_sandbox }

      m.complex_template('form.rhtml',
        File.join('app/views',
                  controller_class_path,
                  controller_file_name,
                  '_form.rhtml'),
        :insert => 'form_scaffolding.rhtml',
        :sandbox => lambda { create_sandbox },
        :begin_mark => 'form',
        :end_mark => 'eoform',
        :mark_id => singular_name) if less_dry_partial?

      m.complex_template('show.rhtml',
        File.join('app/views',
                  controller_class_path,
                  controller_file_name,
                  '_show.rhtml'),
        :insert => 'show_scaffolding.rhtml',
        :sandbox => lambda { create_sandbox },
        :begin_mark => 'show',
        :end_mark => 'eoshow',
        :mark_id => singular_name) if less_dry_partial?

      # Controller class, functional test, helper, and views.
      controller_template_name = 'controller.rb'
      controller_template_name = 'controller_methods.rb' if less_dry_partial?      
      m.complex_template controller_template_name,
        File.join('app/controllers',
                controller_class_path,
                "#{controller_file_name}_controller.rb"),
        :insert => 'controller_scaffolding.rhtml',
        :sandbox => lambda { create_sandbox }
      m.template 'helper.rb',
        File.join('app/helpers',
                  controller_class_path,
                  "#{controller_file_name}_helper.rb")  
    end
  end

  protected
  
    def quote(value)
      case value
        when NilClass                 then "NULL"
        when TrueClass                then "TRUE"
        when FalseClass               then "FALSE"
        when Float, Fixnum, Bignum    then value.to_s
        # BigDecimals need to be output in a non-normalized form and quoted.
        when BigDecimal               then value.to_s('F')
        else
          value.inspect
      end
    end
  
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} active_scaffold ModelName [ControllerName] [less_dry]\n   Example: #{$0} active_scaffold Event Events less_dry"
    end

    def scaffold_views
      []
    end

    def scaffold_actions
      []
    end

    def unscaffolded_actions
      []
    end

    def less_dry_partial?
      args.include?("less_dry")
    end

    def create_sandbox
      sandbox = ActiveScaffoldingSandbox.new
      sandbox.singular_name = singular_name
      begin
        sandbox.model_instance = model_instance
        sandbox.instance_variable_set("@#{singular_name}", sandbox.model_instance)
      rescue ActiveRecord::StatementInvalid => e
        logger.error "Before updating scaffolding from new DB schema, try creating a table for your model (#{class_name})"
        raise SystemExit
      end
      sandbox.suffix = suffix
      sandbox
    end

end
