#Based on http://coderrr.wordpress.com/2009/01/08/activerecord-threading-issues-and-resolutions/

require 'active_record/connection_adapters/mysql_adapter'

module ActiveRecord::ConnectionAdapters
  class MysqlAdapter
    alias_method :execute_without_retry, :execute
    def execute(*args)
      execute_without_retry(*args)
    rescue ActiveRecord::StatementInvalid
      if $!.message =~ /server has gone away/i
        warn "Server timed out, retrying"
        reconnect!
        retry
      end

      raise
    end
  end
end