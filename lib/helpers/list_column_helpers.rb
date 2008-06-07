module ActiveScaffold
  module Helpers
    # Helpers that assist with the rendering of a List Column
    module ListColumns
      def get_column_value(record, column)
        # check for an override helper
        value = if column_override? column
          # we only pass the record as the argument. we previously also passed the formatted_value,
          # but mike perham pointed out that prohibited the usage of overrides to improve on the
          # performance of our default formatting. see issue #138.
          send(column_override(column), record)
        # second, check if the dev has specified a valid list_ui for this column
        elsif column.list_ui and override_column_ui?(column.list_ui)
          send(override_column_ui(column.list_ui), column, record)

        elsif column.inplace_edit and record.authorized_for?(:action => :update, :column => column.name)
          active_scaffold_inplace_edit(record, column)
        else
          value = record.send(column.name)

          if column.association.nil? or column_empty?(value)
            formatted_value = clean_column_value(format_column(value))
          else
            case column.association.macro
              when :has_one, :belongs_to
                formatted_value = clean_column_value(format_column(value.to_label))

              when :has_many, :has_and_belongs_to_many
                firsts = value.first(4).collect { |v| v.to_label }
                firsts[3] = '…' if firsts.length == 4
                formatted_value = clean_column_value(format_column(firsts.join(', ')))
            end
          end

          formatted_value
        end

        value = '&nbsp;' if value.nil? or (value.respond_to?(:empty?) and value.empty?) # fix for IE 6
        return value
      end

      # TODO: move empty_field_text and &nbsp; logic in here?
      # TODO: move active_scaffold_inplace_edit in here?
      # TODO: we need to distinguish between the automatic links *we* create and the ones that the dev specified. some logic may not apply if the dev specified the link.
      def render_list_column(text, column, record)
        if column.link
          return "<a class='disabled'>#{text}</a>" unless record.authorized_for?(:action => column.link.crud_type)
          return text if column.singular_association? and column_empty?(text)

          url_options = params_for(:action => nil, :id => record.id, :link => text)
          if column.singular_association? and column.link.action != 'nested' and associated = record.send(column.association.name)
            url_options[:id] = associated.id
          end

          render_action_link(column.link, url_options)
        else
          text
        end
      end

      # There are two basic ways to clean a column's value: h() and sanitize(). The latter is useful
      # when the column contains *valid* html data, and you want to just disable any scripting. People
      # can always use field overrides to clean data one way or the other, but having this override
      # lets people decide which way it should happen by default.
      #
      # Why is it not a configuration option? Because it seems like a somewhat rare request. But it
      # could eventually be an option in config.list (and config.show, I guess).
      def clean_column_value(v)
        h(v)
      end

      ##
      ## Overrides
      ##
      def active_scaffold_column_checkbox(column, record)
        column_value = record.send(column.name)
        if column.inplace_edit and record.authorized_for?(:action => :update, :column => column.name)
          id_options = {:id => record.id.to_s, :action => 'update_column', :name => column.name.to_s}
          tag_options = {:tag => "span", :id => element_cell_id(id_options), :class => "in_place_editor_field"}
          script = remote_function(:url => {:controller => params_for[:controller], :action => "update_column", :column => column.name, :id => record.id.to_s, :value => !column_value})
          content_tag(:span, check_box_tag(tag_options[:id], 1, column_value || column_value == 1, {:onchange => script}) , tag_options)
        else
          check_box_tag(nil, 1, column_value || column_value == 1, :disabled => true)
        end
      end

      def active_scaffold_column_percentage(column, record)
        number_to_percentage(record[column.name].to_s, :precision => 1)
      end

      def active_scaffold_column_ssn(column, record)
        usa_number_to_ssn(record[column.name].to_s)
      end

      def active_scaffold_column_usa_money(column, record)
        number_to_currency(record[column.name].to_s)
      end

      def active_scaffold_column_usa_phone(column, record)
        usa_number_to_phone(record[column.name].to_s)
      end

      def active_scaffold_column_usa_zip(column, record)
        usa_number_to_zip(record[column.name].to_s)
      end


      def column_override(column)
        "#{column.name.to_s.gsub('?', '')}_column" # parse out any question marks (see issue 227)
      end

      def column_override?(column)
        respond_to?(column_override(column))
      end

      def override_column_ui?(list_ui)
        respond_to?(override_column_ui(list_ui))
      end

      # the naming convention for overriding column types with helpers
      def override_column_ui(list_ui)
        "active_scaffold_column_#{list_ui}"
      end

      ##
      ## Formatting
      ##

      def format_column(column_value)
        if column_empty?(column_value)
          active_scaffold_config.list.empty_field_text
        elsif column_value.instance_of? Time
          format_time(column_value)
        elsif column_value.instance_of? Date
          format_date(column_value)
        else
          column_value.to_s
        end
      end

      def format_time(time)
        format = ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS[:default] || "%m/%d/%Y %I:%M %p"
        time.strftime(format)
      end

      def format_date(date)
        format = ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS[:default] || "%m/%d/%Y"
        date.strftime(format)
      end

      # ==========
      # = Inline Edit =
      # ==========
      def format_inplace_edit_column(record,column)
        value = record.send(column.name)
        if column.list_ui == :checkbox
          active_scaffold_column_checkbox(column, record)
        else
          clean_column_value(format_column(value))
        end
      end
      
      def active_scaffold_in_place_editor_js(field_id, options = {})
        function =  "new Ajax.InPlaceEditor("
        function << "'#{field_id}', "
        function << "'#{url_for(options[:url])}'"

        js_options = {}
        js_options['cancelText'] = %('#{options[:cancel_text]}') if options[:cancel_text]
        js_options['okText'] = %('#{options[:save_text]}') if options[:save_text]
        js_options['loadingText'] = %('#{options[:loading_text]}') if options[:loading_text]
        js_options['savingText'] = %('#{options[:saving_text]}') if options[:saving_text]
        js_options['rows'] = options[:rows] if options[:rows]
        js_options['htmlResponse'] = options[:html_response] if options.has_key?(:html_response)
        js_options['cols'] = options[:cols] if options[:cols]
        js_options['size'] = options[:size] if options[:size]
        js_options['externalControl'] = "'#{options[:external_control]}'" if options[:external_control]
        js_options['loadTextURL'] = "'#{url_for(options[:load_text_url])}'" if options[:load_text_url]        
        js_options['ajaxOptions'] = options[:options] if options[:options]
        js_options['evalScripts'] = options[:script] if options[:script]
        js_options['callback']   = "function(form) { return #{options[:with]} }" if options[:with]
        js_options['clickToEditText'] = %('#{options[:click_to_edit_text]}') if options[:click_to_edit_text]
        function << (', ' + options_for_javascript(js_options)) unless js_options.empty?
        
        function << ')'

        javascript_tag(function)
      end
      
      # def active_scaffold_inplace_edit(record, column)
      #   formatted_column = format_inplace_edit_column(record,column)
      #   id_options = {:id => record.id.to_s, :action => 'update_column', :name => column.name.to_s}
      #   tag_options = {:tag => "span", :id => element_cell_id(id_options), :class => "in_place_editor_field"}
      #   in_place_editor_options = {:url => {:controller => params_for[:controller], :action => "update_column", :column => column.name, :id => record.id.to_s},
      #    :click_to_edit_text => as_("Click to edit"),
      #    :cancel_text => as_("Cancel"),
      #    :loading_text => as_("Loading…"),
      #    :save_text => as_("Update"),
      #    :saving_text => as_("Saving…"),
      #    :html_response => false,
      #    :options => "{method: 'post'}",
      #    :script => true}.merge(column.options)
      #   content_tag(:span, formatted_column, tag_options) + active_scaffold_in_place_editor_js(tag_options[:id], in_place_editor_options)
      # end

      # Allow in_place_editor to pass along nested information so the update_column can call refresh_record properly.
      def active_scaffold_inplace_edit(record, column, options = {})
        formatted_column = options[:formatted_column] || format_inplace_edit_column(record, column)
        id_options = {:id => record.id.to_s, :action => 'update_column', :name => column.name.to_s}
        tag_options = {:tag => "span", :id => element_cell_id(id_options), :class => "in_place_editor_field"}
        in_place_editor_options = {:url => {:controller => params_for[:controller], :action => "update_column", :eid => params[:eid], :parent_model => params[:parent_model], :column => column.name, :id => record.id.to_s},
         :click_to_edit_text => as_("Click to edit"),
         :cancel_text => as_("Cancel"),
         :loading_text => as_("Loading…"),
         :save_text => as_("Update"),
         :saving_text => as_("Saving…"),
         :script => true}.merge(column.options)
        html =  html_for_inplace_display(formatted_column, tag_options[:id], in_place_editor_options)
        html << form_for_inplace_display(record, column, tag_options[:id], in_place_editor_options, options)
      end

      def check_for_choices(options)
        raise ArgumentError, "Missing choices for select! Specify options[:choices] for in_place_select" if options[:choices].nil?
      end
      
      def html_for_inplace_display(display_text, id_string, in_place_editor_options)
        content_tag(:span, display_text,
          :onclick => "Element.hide(this);$('#{id_string}_form').show();", 
          :onmouseover => visual_effect(:highlight, id_string), 
          :title => in_place_editor_options[:click_to_edit_text], 
          :id => id_string,
          :class => "inplace_span")
      end

      def form_for_inplace_display(record, column, id_string, in_place_editor_options, options)
        retval = ""
        in_place_editor_options[:url] ||= {}
        in_place_editor_options[:url][:action] ||= "set_record_#{column.name}"
        in_place_editor_options[:url][:id] ||= record.id
        loader_message = in_place_editor_options[:saving_text] || as_("Saving...")
        retval << form_remote_tag(:url => in_place_editor_options[:url],
  				:method => in_place_editor_options[:http_method] || :post,
          :loading => "$('#{id_string}_form').hide(); $('loader_#{id_string}').show();",
          :complete => "$('loader_#{id_string}').hide();",
          :html => {:class => "in_place_editor_form", :id => "#{id_string}_form", :style => "display:none" } )

        retval << field_for_inplace_editing(record, options, column )
        retval << content_tag(:br) if in_place_editor_options[:br]
        retval << submit_tag(as_("OK"), :class => "inplace_submit")
        retval << link_to_function( "Cancel", "$('#{id_string}_form').hide();$('#{id_string}').show() ", {:class => "inplace_cancel" })
        retval << "</form>"
        # #FIXME 2008-01-14 (EJM) Level=0 - Use AS's spinner
        # retval << invisible_loader( loader_message, "loader_#{id_string}", "inplace_loader")
        retval << content_tag(:br)
      end

      def field_for_inplace_editing(record, options, column)
        input_type = column.list_ui
        options[:class] = "inplace_#{input_type}"
        htm_opts = {:class => options[:class] }
        case input_type
        when :textarea
          text_area(:record, column.name, options )
        when :select
          select(:record, column.name,  options[:choices], {:selected => record.send(column.name)}.merge(options), htm_opts )
        when :checkbox
          options[:label_class] = "inplace_#{input_type}_label"
          checkbox_collection(:record, column.name, record,  options[:choices], options )
        when :radio
          options[:label_class] = "inplace_#{input_type}_label"
          radio_collection(:record, column.name, record,  options[:choices], options )
        # when :date_select
        #   calendar_date_select( :record, column.name, options)
        else
          text_field(:record, column.name, options )
        end
      end
      
    end
  end
end
