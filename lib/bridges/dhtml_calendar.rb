module ActiveScaffold::Config
  class Core < Base

    def initialize_with_dhtml_calendar(model_id)
      initialize_without_dhtml_calendar(model_id)
      
      dhtml_calendar_fields = self.model.columns.collect{|c| c.name.to_sym if [:date, :datetime].include?(c.type) }.compact
      # check to see if file column was used on the model
      return if dhtml_calendar_fields.empty?
      
      # automatically set the forum_ui to a file column
      dhtml_calendar_fields.each{|field|
        self.columns[field].form_ui = :dhtml_calendar
      }
    end
    
    alias_method_chain :initialize, :dhtml_calendar
    
  end
end


module ActiveScaffold
  module Helpers
    # Helpers that assist with the rendering of a Form Column
    module FormColumns
      def active_scaffold_input_dhtml_calendar(column, options)
        active_scaffold_input_calendar(column, options)
      end      
    end
  end
end