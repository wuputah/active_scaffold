module ActiveScaffold::Config
  class ExportTool < Base

    self.crud_type = :read

    def initialize(core_config)
      @core = core_config

      # inherit from global scope
      @empty_field_text = self.class.empty_field_text
      @delimiter = self.class.delimiter
      @force_quotes = self.class.force_quotes
      @skip_header = self.class.skip_header
      @maximum_rows = self.class.maximum_rows
    end

    # global level configuration
    # --------------------------
    # the ActionLink for this action
    cattr_reader :link
    @@link = ActiveScaffold::DataStructures::ActionLink.new('show_export_tool', :label => 'Export', :type => :table, :security_method => :export_tool_authorized?)
    
    cattr_accessor :empty_field_text
    @@empty_field_text = ''
    
    cattr_accessor :delimiter
    @@delimiter = ","

    cattr_accessor :force_quotes
    @@force_quotes = false
    
    cattr_accessor :maximum_rows
    @@maximum_rows = 10000

    cattr_accessor :skip_header
    @@skip_header = false

    # instance-level configuration
    # ----------------------------

    attr_accessor :empty_field_text

    attr_accessor :delimiter

    attr_accessor :force_quotes
    
    attr_accessor :maximum_rows

    attr_accessor :skip_header

  end
end
