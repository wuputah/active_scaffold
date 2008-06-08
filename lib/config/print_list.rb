module ActiveScaffold::Config
  class PrintList < Base
    
    self.crud_type = :read

    def initialize(core_config)
      @core = core_config

      # inherit from global scope
      @empty_field_text = self.class.empty_field_text
      @maximum_rows = self.class.maximum_rows
    end

    # global level configuration
    # --------------------------
    # the ActionLink for this action
    
    cattr_accessor :empty_field_text
    @@empty_field_text = '-'
    
    cattr_accessor :maximum_rows
    @@maximum_rows = 10000
    
    # instance-level configuration
    # ----------------------------
    # the ActionLink for this action
    attr_accessor :link

    attr_accessor :empty_field_text

    attr_accessor :maximum_rows

    # the label for this List action. used for the header.
    attr_writer :label
    def label
      @label ? as_(@label) : @core.label
    end
    
  end
end
