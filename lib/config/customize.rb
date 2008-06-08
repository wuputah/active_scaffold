module ActiveScaffold::Config
  class Customize < Base

    self.crud_type = :read

    def initialize(core_config)
      @core = core_config

      # inherit from global scope
    end

    # global level configuration
    # --------------------------
    # the ActionLink for this action
    cattr_reader :link
    @@link = ActiveScaffold::DataStructures::ActionLink.new('show_customize', :label => 'Customize', :type => :table, :security_method => :customize_authorized?)
        
    # instance-level configuration
    # ----------------------------

    # provides access to the list of columns specifically meant for this action to use
    def columns
      unless @columns
        self.columns = @core.columns._inheritable 
        self.columns.exclude @core.columns.active_record_class.locking_column.to_sym
      end
      @columns
    end
    def columns=(val)
      @columns = ActiveScaffold::DataStructures::ActionColumns.new(*val)
      @columns.action = self
    end
  end
end
