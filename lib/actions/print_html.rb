module ActiveScaffold::Actions
  module PrintHtml
    include ActiveScaffold::Actions::PrintList
    def self.included(base)
      base.before_filter :print_html_authorized?, :only => [:print_html]
      base.before_filter :store_search_session_info
    end

    def print_html
      do_print_list active_scaffold_config.print_html

      respond_to do |type|
        type.html {
          render(:partial => 'print_list', :layout => false)
        }
        type.xml { render :xml => response_object.to_xml, :content_type => Mime::XML, :status => response_status }
        type.json { render :text => response_object.to_json, :content_type => Mime::JSON, :status => response_status }
        type.yaml { render :text => response_object.to_yaml, :content_type => Mime::YAML, :status => response_status }
      end
    end

    protected
    
    # The default security delegates to ActiveRecordPermissions.
    # You may override the method to customize.
    def print_html_authorized?
      authorized_for?(:action => :read)
    end
    
  end
end