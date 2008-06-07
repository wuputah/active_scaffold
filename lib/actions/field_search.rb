module ActiveScaffold::Actions
  module FieldSearch
    include ActiveScaffold::Search
    def self.included(base)
      base.before_filter :field_search_authorized?, :only => :show_search
      base.before_filter :store_search_session_info
      base.before_filter :do_search
    end

    # FieldSearch uses params[:search] and not @record because search conditions do not always pass the Model's validations.
    # This facilitates for example, textual searches against associations via .search_sql
    def show_search
      params[:search] = active_scaffold_session_storage[:search] || {}
      do_show_search
      
      respond_to do |type|
        type.html do
          if successful?
            render(:partial => "field_search", :layout => true)
          else
            return_to_main
          end
        end
        type.js { render(:partial => "field_search", :layout => false) }
      end
    end

    def reset_search
      reset_search_session_info
      update_table      
    end
    
    protected

    def do_search
      unless params[:search].nil?
        like_pattern = active_scaffold_config.field_search.full_text_search? ? '%?%' : '?%'
        conditions = self.active_scaffold_conditions
        params[:search].each do |key, value|
          next unless active_scaffold_config.field_search.columns.include?(key)
          column = active_scaffold_config.columns[key]
          conditions = merge_conditions(conditions, condition_for_search_column(column, value, like_pattern))
        end
        self.active_scaffold_conditions = conditions

        columns = active_scaffold_config.field_search.columns
        includes_for_search_columns = columns.collect{ |column| column.includes}.flatten.uniq.compact
        self.active_scaffold_joins.concat includes_for_search_columns

        active_scaffold_config.list.user.page = nil
      end
    end

    def do_show_search
      init_params = {}
      params[:search].each do |key, value|
        next unless active_scaffold_config.field_search.columns.include?(key)
        column = active_scaffold_config.columns[key]
        column_type, search_type = type_for_search_column(column, value)
        next if column_type.nil? or search_type == :range or column_type == :set
        value = value[:id] if column_type == :id_hash
        #TODO 2008-01-04 (EJM) Level=0 - Support virtual columns and associations that are not tied to RecordSelect ie. there values may be strings.
        if column.association and value
          lookup_value = value.to_i if value.kind_of?(Numeric) and value.to_i > 0
          lookup_value ||= value unless value.kind_of?(String)
          init_params[key] = column.association.klass.find(lookup_value) if lookup_value
        end
        init_params[key] ||= value unless column.association
      end
      @record = active_scaffold_config.model.new(init_params)
    end
    
    def condition_for_search_column(column, value, like_pattern = '%?%')
      column_type, search_type = type_for_search_column(column, value)
      return unless column_type and value and not value.empty?
      case column_type
        when :boolean, :checkbox
          ["#{column.search_sql} = ?", (value.to_i == 1)]
        when :integer
          if search_type == :range
            return ["#{column.search_sql} >= ? and #{column.search_sql} <= ?", value[:range_from], value[:range_to]] if value[:range_from] and value[:range_to]
            return ["#{column.search_sql} >= ?", value[:range_from]] if value[:range_from]
            return ["#{column.search_sql} <= ?", value[:range_to]] if value[:range_to]
          else
            ["#{column.search_sql} = ?", value.to_i]
          end
        when :id_hash
          value = value[:id]
          return unless value and not value.empty?
          ["#{column.search_sql} = ?", value.to_i]
        when :set
          ["#{column.search_sql} IN (?)", value.join(",")]
        else
          case search_type
          when :range
            tmp_model = active_scaffold_config.model.new
            return ["#{column.search_sql} >= ? and #{column.search_sql} <= ?", tmp_model.cast_to_date(value[:range_from]), tmp_model.cast_to_date(value[:range_to])] if value[:range_from] and value[:range_to]
            return ["#{column.search_sql} >= ?", tmp_model.cast_to_date(value[:range_from])] if value[:range_from]
            return ["#{column.search_sql} <= ?", tmp_model.cast_to_date(value[:range_to])] if value[:range_to]
          when :exact
            ["#{column.search_sql} = ?", value]
          else
            ["LOWER(#{column.search_sql}) LIKE ?", like_pattern.sub('?', value.downcase)]
          end
      end
    end    

    def type_for_search_column(column, value)
      return(nil) unless column and column.search_sql and value
      column_type = column.form_ui || column.column.type
      # Support :options => {:field_search => :select}, the value as [:id => ?].
      if value.is_a?(Hash) and value.has_key?(:id) 
        column_type = :id_hash 
      end
      if column_type == :record_select
        if value.is_a?(Array)
          column_type = :set
        else
          column_type = :integer
        end
      end
      search_type = :exact if [:exact, :select].include?(column.options[:field_search]) or [:usa_state].include?(column_type)
      # Support :options => {:field_search => :range}, the value as [:range_from => ?, :range_to => ?].
      search_type = :range if value.is_a?(Hash) and value.has_key?(:range_from)
      search_type ||= column_type
      return column_type, search_type
    end    

    # The default security delegates to ActiveRecordPermissions.
    # You may override the method to customize.
    def field_search_authorized?
      authorized_for?(:action => :read)
    end
  end
end
