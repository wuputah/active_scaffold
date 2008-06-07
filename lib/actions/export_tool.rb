module ActiveScaffold::Actions
  module ExportTool
    include ActiveScaffold::Actions::PrintList
    def self.included(base)
      base.before_filter :export_tool_authorized?, :only => [:export_tool]
      base.before_filter :store_search_session_info
    end
    
    def show_export_tool
      respond_to do |wants|
        wants.html do
          if successful?
            render(:partial => 'show_export_tool', :layout => true)
          else
            return_to_main
          end
        end
        wants.js do
          render(:partial => 'show_export_tool', :layout => false)
        end
      end
    end

    def export_tool
      do_print_list(active_scaffold_config.export_tool)
      active_scaffold_config.export_tool.delimiter = params[:delimiter]
      active_scaffold_config.export_tool.skip_header = params[:skip_header]
      response.headers['Cache-Control'] = 'max-age=60' # IE 6 needs this!
      response.headers['Content-Disposition'] = "attachment; filename=\"#{self.controller_name}.csv\""
      render :partial => 'export_csv', :content_type => Mime::CSV, :status => response_status 
    end

    protected

    # The default security delegates to ActiveRecordPermissions.
    # You may override the method to customize.
    def export_tool_authorized?
      authorized_for?(:action => :read)
    end
  end
end
