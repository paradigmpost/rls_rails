module RLS
  module Util
    def derive_fk tbl, rel
      obj_klass = tbl.to_s.classify.constantize
      obj_klass.reflections[rel.to_s].foreign_key
    rescue NameError
      rel.to_s + '_id'
    end

    def derive_rel_tbl rel
      if rel.respond_to? :table_name
        rel.table_name
      else
        rel_s = rel.to_s
        rel_klass = rel_s.classify.constantize

        rel_parts = rel_s.split('.')
        schema_parts = rel_parts[0,rel_parts.length-1]
        ActiveRecord::Base.connection.quote_table_name schema_parts.push(rel_klass.table_name).join('.')
      end
    rescue NameError
      rel_s = rel.to_s

      rel_parts = rel_s.split('.')
      schema_prefix = rel_parts[0,rel_parts.length-1]
      ActiveRecord::Base.connection.quote_table_name schema_parts.push(rel_s.pluralize).join('.')
    end

    def last_version_of table
      dir_path = self.policy_path(table)
      if Dir.exist? dir_path
        Dir.entries(dir_path).reject{|f| File.directory? f }.map{|n| n[-5..-4].to_i}.max || 0
      else
        0
      end
    end

    def policy_path table = false, version = false
      path = Railtie.config.rls_rails.policy_dir
      path = path + "/#{table}/" if table
      path << "#{table}_v#{sprintf('%02d', version)}.rb" if version
      path
    end

    def debug_print s
      print s if Railtie.config.rls_rails.verbose
    end
  end
end
