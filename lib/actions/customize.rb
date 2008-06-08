#TODO 2007-11-16 (EJM) Level=0 - Ignore lock_version
module ActiveScaffold::Actions
  module Customize
    include ActiveScaffold::Actions::PrintList
    def self.included(base)
      base.before_filter :customize_authorized?, :only => [:customize]
      base.before_filter :store_custum_list
      base.before_filter :do_customize
    end
    
    def show_customize
      respond_to do |wants|
        wants.html do
          if successful?
            render(:partial => 'show_customize', :layout => true)
          else
            return_to_main
          end
        end
        wants.js do
          render(:partial => 'show_customize', :layout => false)
        end
      end
    end

    def reset_customize
      active_scaffold_session_storage[:custom_columns] = {}
      @list_columns = nil
      update_table
    end
    
    def store_custum_list
      active_scaffold_session_storage[:custom_columns] ||= {}
      active_scaffold_session_storage[:custom_columns] = params[:custom_columns] if params[:custom_columns]
    end
    
    protected

    # The default security delegates to ActiveRecordPermissions.
    # You may override the method to customize.
    def customize_authorized?
      authorized_for?(:action => :read)
    end

    def do_customize
      # active_scaffold_session_storage[:custom_columns_default] ||= active_scaffold_tools_list_columns.collect { |col| col.name.to_sym }

      if !active_scaffold_session_storage[:custom_columns].empty? and params[:action] != :reset_custom
        @list_columns = active_scaffold_config.customize.columns.reject { |col| active_scaffold_session_storage[:custom_columns][col.name.to_sym].nil? }
      end
    end

  end
end
