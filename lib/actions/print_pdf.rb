module ActiveScaffold::Actions
  module PrintPdf
    include ActiveScaffold::Actions::PrintList
    def self.included(base)
      base.before_filter :print_pdf_authorized?, :only => [:print_pdf]
      base.before_filter :store_search_session_info
    end

    def print_pdf
      do_print_list active_scaffold_config.print_pdf
      
      respond_to do |type|
        type.html {
          @html = render_to_string(:partial => "print_list", :layout => false)
          render :action => 'print_pdf', :layout => false      
        }
      end
    end
    
    protected
    
    # The default security delegates to ActiveRecordPermissions.
    # You may override the method to customize.
    def print_pdf_authorized?
      authorized_for?(:action => :read)
    end
    
  end
end