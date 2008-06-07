module ActiveScaffold
  module Search
    def reset_search_session_info
      active_scaffold_session_storage[:search] = {}
    end

    def store_search_session_info
      active_scaffold_session_storage[:search] = params[:search] if params[:search] || params[:commit] == as_('Search')
    end    
  end
end