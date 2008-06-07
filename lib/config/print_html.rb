module ActiveScaffold::Config
  class PrintHtml < PrintList
    
    self.crud_type = :read

    def initialize(*args)
      super
    end

    # global level configuration
    # --------------------------
    # the ActionLink for this action
    cattr_reader :link
    @@link = ActiveScaffold::DataStructures::ActionLink.new('print_html', :label => 'Print', :type => :table, :security_method => :print_html_authorized?, :popup => true)
  end
end