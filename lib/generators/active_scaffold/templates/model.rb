# == Schema Information<% 
version = ActiveRecord::Migrator.current_version rescue 0
klass = class_name.constantize
if version > 0 %>
# Schema version: <%= version %><% end %>
#
# Table name: <%= klass.table_name %>
#
<%
max_size = klass.column_names.collect{|name| name.size}.max + 1
klass.columns.each do |col|
  attrs = []
  attrs << "default(#{quote(col.default)})" if col.default
  attrs << "not null" unless col.null
  attrs << "primary key" if col.name == klass.primary_key

  col_type = col.type.to_s
  if col_type == "decimal"
    col_type << "(#{col.precision}, #{col.scale})"
  else
    col_type << "(#{col.limit})" if col.limit
  end %><%= sprintf("#  %-#{max_size}.#{max_size}s:%-13.13s %s\n", col.name, col_type, attrs.join(", ")) %><%
end
%>#

class <%= class_name %> < ActiveRecord::Base
	<%= template_for_inclusion -%>
end
