module ActiveScaffold::Config
  class Core < Base

    def initialize_with_checkbox(model_id)
      initialize_without_checkbox(model_id)
      
      checkbox_fields = self.model.columns.collect{|c| c.name.to_sym if [:boolean].include?(c.type) }.compact
      # check to see if file column was used on the model
      return if checkbox_fields.empty?
      
      # automatically set the forum_ui to a file column
      checkbox_fields.each{|field|
        self.columns[field].form_ui = :checkbox
      }
    end
    
    alias_method_chain :initialize, :checkbox
    
  end
end