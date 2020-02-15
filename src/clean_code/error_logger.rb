#
# Defines a logger for error messages
#

class ErrorLogger

    def self.log_error_message(error_message)
        File.open('./errors.log', 'a') do |f|
            f.puts error_message
        end
    end

end