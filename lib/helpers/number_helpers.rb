module ActionView
  module Helpers
    # Provides methods for converting a number into a formatted string that currently represents
    # one of the following forms: phone number, percentage, money, or precision level.
    module NumberHelper
      # Formats a +number+ into a US ssn number string. The +options+ can be a hash used to customize the format of the output.
      # The delimiter can be set using +:delimiter+; default is "-"
      # Examples:
      #   usa_number_to_ssn(123551234)   => 123-55-1234
      def usa_number_to_ssn(number, options = {})
        return "" if number.nil?
        options   = options.stringify_keys
        delimiter = options[:delimiter] || "-"
        begin
          str = number.to_s.gsub(/([0-9]{3})([0-9]{2})([0-9]{4})/,"\\1#{delimiter}\\2#{delimiter}\\3")
        rescue
          number
        end
      end

      # Formats a +number+ into a US zip code string. The +options+ can be a hash used to customize the format of the output.
      # The delimiter can be set using +:delimiter+; default is "-"
      # Examples:
      #   usa_number_to_zip(123551234)   => 12355-1234
      def usa_number_to_zip(number, options = {})
        return "" if number.nil?
        options   = options.stringify_keys
        delimiter = options[:delimiter] || "-"
        begin
          str = number.to_s.gsub(/([0-9]{5})([0-9]{4})/,"\\1#{delimiter}\\2")
        rescue
          number
        end
      end

      # Formats a +number+ into a US phone number string. The +options+ can be a hash used to customize the format of the output.
      # The area code can be surrounded by parentheses by setting +:area_code+ to true; default is false
      # The delimiter can be set using +:delimiter+; default is "-"
      # Examples:
      #   usa_number_to_phone(1235551234)   => 123-555-1234
      #   usa_number_to_phone(1235551234, {:area_code => true})   => (123) 555-1234
      #   usa_number_to_phone(1235551234, {:delimiter => " "})    => 123 555 1234
      #   usa_number_to_phone(1235551234, {:area_code => true, :extension => 555})  => (123) 555-1234 x 555
      def usa_number_to_phone(number, options = {})
        return "" if number.nil?
        options   = options.stringify_keys
        options[:area_code] ||= false
        options[:delimiter] ||= "-"
        options[:extension] ||= ""
        begin
          str = options[:area_code] == true ? number.to_s.gsub(/([0-9]{3})([0-9]{3})([0-9]{4})/,"(\\1) \\2#{options[:delimiter]}\\3") : number.to_s.gsub(/([0-9]{3})([0-9]{3})([0-9]{4})/,"\\1#{options[:delimiter]}\\2#{options[:delimiter]}\\3")
          options[:extension].to_s.strip.empty? ? str : "#{str} x #{options[:extension].to_s.strip}"
        rescue
          number
        end
      end

      # Formats a +number+ into a currency string. The +options+ hash can be used to customize the format of the output.
      # The +number+ can contain a level of precision using the +precision+ key; default is 2
      # The currency type can be set using the +unit+ key; default is "$"
      # The unit separator can be set using the +separator+ key; default is "."
      # The delimiter can be set using the +delimiter+ key; default is ","
      # Examples:
      #    number_to_currency(1234567890.50)     => $1,234,567,890.50
      #    number_to_currency(1234567890.506)    => $1,234,567,890.51
      #    number_to_currency(1234567890.50, {:unit => "&pound;", :separator => ",", :delimiter => ""}) => &pound;1234567890,50
      def number_to_currency(number, options = {})
        return "" if number.nil?
        options = options.stringify_keys
        options[:precision] ||= 2
        options[:unit] ||= "$"
        options[:separator] ||= "."
        options[:delimiter] ||= ","
        options[:separator] = "" unless options[:precision] > 0
        begin
          parts = number_with_precision(number, options[:precision]).split('.')
          options[:unit] + number_with_delimiter(parts[0], options[:delimiter]) + options[:separator] + parts[1].to_s
        rescue
          number
        end
      end

      # Formats a +number+ as into a percentage string. The +options+ hash can be used to customize the format of the output.
      # The +number+ can contain a level of precision using the +precision+ key; default is 3
      # The unit separator can be set using the +separator+ key; default is "."
      # Examples:
      #   number_to_percentage(100)    => 100.000%
      #   number_to_percentage(100, {:precision => 0}) => 100%
      #   number_to_percentage(302.0574, {:precision => 2})  => 302.06%
      def number_to_percentage(number, options = {})
        return "" if number.nil?
        options = options.stringify_keys
        options[:precision] ||= 2
        options[:separator] ||= "."
        begin
          number = number_with_precision(number, options[:precision])
          parts = number.split('.')
          if parts.at(1).nil?
            parts[0] + "%"
          else
            parts[0] + options[:separator] + parts[1].to_s + "%"
          end
        rescue
          number
        end
      end

      # Formats a +number+ with a +delimiter+.
      # Example:
      #    number_with_delimiter(12345678) => 12,345,678
      def number_with_delimiter(number, delimiter=",")
        return "" if number.nil?
        number.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
      end

      # Returns a formatted-for-humans file size.
      # 
      # Examples:
      #   human_size(123)          => 123 Bytes
      #   human_size(1234)         => 1.2 KB
      #   human_size(12345)        => 12.1 KB
      #   human_size(1234567)      => 1.2 MB
      #   human_size(1234567890)   => 1.1 GB
      def number_to_human_size(size)
        return "" if size.nil?
        case 
          when size < 1.kilobyte: '%d Bytes' % size
          when size < 1.megabyte: '%.1f KB'  % (size / 1.0.kilobyte)
          when size < 1.gigabyte: '%.1f MB'  % (size / 1.0.megabyte)
          when size < 1.terabyte: '%.1f GB'  % (size / 1.0.gigabyte)
          else                    '%.1f TB'  % (size / 1.0.terabyte)
        end.sub('.0', '')
      rescue
        ""
      end

      alias_method :human_size, :number_to_human_size # deprecated alias

      # Formats a +number+ with a level of +precision+.
      # Example:
      #    number_with_precision(111.2345) => 111.235
      def number_with_precision(number, precision=3)
        sprintf("%01.#{precision}f", number)
      end
    end
  end
end