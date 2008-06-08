module ActiveScaffold
  module Helpers
    # Helpers that assist with the rendering of a Form Column
    module FormColumns
      # This method decides which input to use for the given column.
      # It does not do any rendering. It only decides which method is responsible for rendering.
      def active_scaffold_input_for(column, scope = nil)
        options = active_scaffold_input_options(column, scope)

        # first, check if the dev has created an override for this specific field
        if override_form_field?(column)
          send(override_form_field(column), @record, options[:name])

        # second, check if the dev has specified a valid form_ui for this column
        elsif column.form_ui and override_input?(column.form_ui)
          send(override_input(column.form_ui), column, options)

        # fallback: we get to make the decision
        else
          if column.association
            # if we get here, it's because the column has a form_ui but not one ActiveScaffold knows about.
            raise "Unknown form_ui `#{column.form_ui}' for column `#{column.name}'"
          elsif column.virtual?
            active_scaffold_input_virtual(column, options)

          else # regular model attribute column
            # if we (or someone else) have created a custom render option for the column type, use that
            if override_input?(column.column.type)
              send(override_input(column.column.type), column, options)
            # final ultimate fallback: use rails' generic input method
            else
              # for textual fields we pass different options
              text_types = [:text, :string, :integer, :float, :decimal]
              options = active_scaffold_input_text_options(options) if text_types.include?(column.column.type)

              input(:record, column.name, options)
            end
          end
        end
      end

      alias form_column active_scaffold_input_for

      def active_scaffold_input_for_search(column, options = {}, scope = nil)
        options[:name] ||= "search[#{column.name}]"
        options[:id] ||= "search_#{column.name}"
        if override_search_field?(column)
          options[:column] = column
          send(override_search_field(column), @record, options)
        else
          case column.column.type
          when :boolean
            select_options = [
              ['', ''],
              [as_('True'), 1],
              [as_('False'), 0]
            ]
            select_tag options[:name], options_for_select(select_options, options[:value])
          else
            if column.options[:field_search] == :select
              active_scaffold_input_select(column, options)
            else
              if column.form_ui and override_input?(column.form_ui)
                send(override_input(column.form_ui), column, options)
              else
                options = active_scaffold_input_text_options(options)
                input(:record, column.name, options) || text_field_tag(column.name, options[:value], options)
              end
            end
          end
        end
      end

      def active_scaffold_input_text_options(options = {})
        options[:autocomplete] ||= 'off'
        options[:size] ||= 20
        options[:class] = "#{options[:class]} text-input".strip
        options
      end

      def active_scaffold_input_hidden(column, options)
    		input(:record, column.name, options.merge(:type => :hidden))
      end

      def active_scaffold_input_ssn(column, options)
        column.description ||= as_("Ex. 555-22-3333")
    		text_field :record, column.name, options.merge(
                      :value => usa_number_to_ssn(@record[column.name].to_s),
                      :onblur => "SsnDashAdd(this);return true;").merge(active_scaffold_input_text_options)
      end
      
      def active_scaffold_input_timezone(column, options)
        time_zone_select(:record, column.name)
      end

      def active_scaffold_input_percentage(column, options)
        column.description ||= as_("Ex. 10%")
        options[:onblur] ||= "PercentageFormat(this);return true;"
    		text_field :record, column.name, options.merge(
                      :value => number_to_percentage(@record[column.name].to_s, :precision => 1)).merge(active_scaffold_input_text_options)
      end

      # :usa_money requires some type casting help like the following in your Model
      #
      # def write_attribute(attr, value)
      #   if column_for_attribute(attr).precision
      #    value = BigDecimal(value.gsub(",", "").gsub("$", "")) if value.is_a?(String)
      #   end
      #   super
      # end
      def active_scaffold_input_usa_money(column, options)
        column.description ||= as_("Ex. 1,333")
        options[:onblur] ||= "UsaMoney(this);return true;"
        value = number_to_currency(@record[column.name].to_s) unless options[:blank_if_nil] == true
        value ||= "" 
    		text_field :record, column.name, options.merge(
                      :value => value).merge(active_scaffold_input_text_options)
      end

      def active_scaffold_input_usa_phone(column, options)
        column.description ||= as_("Ex. 111-333-4444")
        options[:onblur] ||= "UsaPhoneDashAdd(this);return true;"
    		text_field :record, column.name, options.merge(
                      :value => usa_number_to_phone(@record[column.name].to_s)).merge(active_scaffold_input_text_options)
      end

      def active_scaffold_input_usa_zip(column, options)
        column.description ||= as_("Ex. 88888-3333")
        options[:onblur] ||= "UsaZipDashAdd(this);return true;"
    		text_field :record, column.name, options.merge(
                      :value => usa_number_to_zip(@record[column.name].to_s)).merge(active_scaffold_input_text_options)
      end

      def override_search_field?(column)
        respond_to?(override_search_field(column))
      end

      # the naming convention for overriding form fields with helpers
      def override_search_field(column)
        "#{column.name}_search_column"
      end

      # the standard active scaffold options used for class, name and scope
      def active_scaffold_input_options(column, scope = nil)
        options = {}
        if active_scaffold_config.upper_case_form_fields and column.column and [:text, :string].include?(column.column.type) and column.form_ui.nil? and (!column.options.has_key?(:upper_case_form_fields) or column.options[:upper_case_form_fields] != false)
          options[:onchange] ||= ''
          options.merge!(:onchange => options[:onchange] + "ToUpper(this);") 
        end
        name = scope ? "record#{scope}[#{column.name}]" : "record[#{column.name}]"
        { :name => name, :class => "#{column.name}-input", :id => "record_#{column.name}_#{params[:eid] || params[:id]}"}.merge(options)
      end
      
      ##
      ## Form input methods
      ##

      def active_scaffold_input_singular_association(column, options)
        associated = @record.send(column.association.name)

        select_options = [[as_('- select -'),nil]]
        select_options += [[ associated.to_label, associated.id ]] unless associated.nil?
        select_options += options_for_association(column.association)

        selected = associated.nil? ? nil : associated.id

        options[:name] += '[id]'
        select(:record, column.name, select_options.uniq, { :selected => selected }, options)
      end

      def active_scaffold_input_plural_association(column, options)
        associated_options = @record.send(column.association.name).collect {|r| [r.to_label, r.id]}
        select_options = associated_options | options_for_association(column.association)
        return 'no options' if select_options.empty?

        html = '<ul class="checkbox-list">'

        associated_ids = associated_options.collect {|a| a[1]}
        select_options.each_with_index do |option, i|
          label, id = option
          this_name = "#{options[:name]}[#{i}][id]"
          html << "<li>"
          html << check_box_tag(this_name, id, associated_ids.include?(id))
          html << "<label for='#{this_name}'>"
          html << label
          html << "</label>"
          html << "</li>"
        end

        html << '</ul>'
        html
      end

      def active_scaffold_input_select(column, options)
        if column.singular_association?
          active_scaffold_input_singular_association(column, options)
        elsif column.plural_association?
          active_scaffold_input_plural_association(column, options)
        else
          select(:record, column.name, column.options, { :selected => @record.send(column.name) }, options)
        end
      end

      # only works for singular associations
      # requires RecordSelect plugin to be installed and configured.
      # ... maybe this should be provided in a bridge?
      def active_scaffold_input_record_select(column, options)
        remote_controller = active_scaffold_controller_for(column.association.klass).controller_path

        # if the opposite association is a :belongs_to, then only show records that have not been associated yet
        params = if column.association and [:has_one, :has_many].include?(column.association.macro)
          {column.association.primary_key_name => ''}
        else
          {}
        end

        if column.singular_association?
          record_select_field(
            "#{options[:name]}",
            @record.send(column.name) || column.association.klass.new,
            {:controller => remote_controller, :id => options[:id], :params => params.merge(:parent_id => @record.id, :parent_model => @record.class)}.merge(active_scaffold_input_text_options).merge(column.options)
          )
        elsif column.plural_association?
          record_multi_select_field(
            options[:name],
            @record.send(column.name),
            {:controller => remote_controller, :id => options[:id], :params => params.merge(:parent_id => @record.id, :parent_model => @record.class)}.merge(active_scaffold_input_text_options).merge(column.options)
          )
        end
      end

      def active_scaffold_input_checkbox(column, options)
        check_box(:record, column.name, options)
      end

      def active_scaffold_input_country(column, options)
        priority = ["United States"]
        select_options = {:prompt => as_('- select -')}
        select_options.merge!(options)
        country_select(:record, column.name, column.options[:priority] || priority, select_options, column.options)
      end

      def active_scaffold_input_password(column, options)
        password_field :record, column.name, active_scaffold_input_text_options(options)
      end

      def active_scaffold_input_textarea(column, options)
        text_area(:record, column.name, options.merge(:cols => column.options[:cols], :rows => column.options[:rows]))
      end

      def active_scaffold_input_usa_state(column, options)
        select_options = {:prompt => as_('- select -')}
        select_options.merge!(options)
        select_options.delete(:size)
        options.delete(:prompt)
        options.delete(:priority)
        usa_state_select(:record, column.name, column.options[:priority], select_options, column.options.merge!(options))
      end

      def active_scaffold_input_virtual(column, options)
        text_field :record, column.name, active_scaffold_input_text_options(options)
      end

      #
      # Column.type-based inputs
      #

      def active_scaffold_input_boolean(column, options)
        select_options = []
        select_options << [as_('- select -'), nil] if column.column.null
        select_options << [as_('True'), true]
        select_options << [as_('False'), false]

        select_tag(options[:name], options_for_select(select_options, @record.send(column.name)))
      end

      ##
      ## Form column override signatures
      ##

      def override_form_field_partial?(column)
        path, partial_name = partial_pieces(override_form_field_partial(column))
        file_exists? File.join(path, "_#{partial_name}")
      end

      # the naming convention for overriding form fields with partials
      def override_form_field_partial(column)
        "#{column.name}_form_column"
      end

      def override_form_field?(column)
        respond_to?(override_form_field(column))
      end

      # the naming convention for overriding form fields with helpers
      def override_form_field(column)
        "#{column.name}_form_column"
      end

      def override_input?(form_ui)
        respond_to?(override_input(form_ui))
      end

      # the naming convention for overriding form input types with helpers
      def override_input(form_ui)
        "active_scaffold_input_#{form_ui}"
      end

      def form_partial_for_column(column)
        if override_form_field_partial?(column)
          override_form_field_partial(column)
        elsif column_renders_as(column) == :field or override_form_field?(column)
          "form_attribute"
        elsif column_renders_as(column) == :subform
          "form_association"
        elsif column_renders_as(column) == :hidden
          "form_hidden_attribute"
        end
      end

      ##
      ## Macro-level rendering decisions for columns
      ##

      def column_renders_as(column)
        if column.is_a? ActiveScaffold::DataStructures::ActionColumns
          return :subsection
        elsif column.active_record_class.locking_column.to_s == column.name.to_s
          return :hidden
        elsif column.association.nil? or column.form_ui or !active_scaffold_config_for(column.association.klass).actions.include?(:subform)
          return :field
        else
          return :subform
        end
      end

      def is_subsection?(column)
        column_renders_as(column) == :subsection
      end

      def is_subform?(column)
        column_renders_as(column) == :subform
      end
    end
  end
end
