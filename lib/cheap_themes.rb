module CheapThemes

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end

  module ClassMethods

    def has_themable_views(finder_method)
      @theme_finder_method = finder_method
      before_filter :cheap_themes_setup_view_paths
    end

    def theme_finder_method
      @theme_finder_method
    end

    def has_customizable_actions(finder_method)
      @actions_theme_finder_method = finder_method
      before_filter :cheap_themes_prepare_customized_actions
    end

    def actions_theme_finder_method
      @actions_theme_finder_method
    end

  end

  module InstanceMethods

    private
    def cheap_themes_setup_view_paths
      theme = self.send(self.class.theme_finder_method)
      self.view_paths = ::ActionController::Base.view_paths.dup.unshift("#{RAILS_ROOT}/themes/#{theme}/views") \
        if theme and theme =~ /[a-z]/i
    end

    def cheap_themes_prepare_customized_actions
      theme = self.send(self.class.actions_theme_finder_method)
      if theme != nil and theme =~ /[a-z]/i and File.exists?("#{RAILS_ROOT}/themes/#{theme}/controllers/#{controller_name}/#{action_name}.rb")
        if Rails.configuration.cache_classes == false or not (self.respond_to? "cheap_themes_customized_action_#{controller_name}_#{action_name}")
          ruby_code = "def cheap_themes_customized_action_#{theme}_#{controller_name}_#{action_name}\n"
          f = File.new "#{RAILS_ROOT}/themes/#{theme}/controllers/#{controller_name}/#{action_name}.rb"
          ruby_code += f.read
          f.close
          ruby_code += "\nend"
          eval ruby_code
        end

        #self.send "cheap_themes_customized_action_#{controller_name}_#{action_name}"
        unless self.respond_to? "cheap_themes_original_action_#{action_name}"
          self.class_eval <<CLS_EVAL
            alias_method "cheap_themes_original_action_#{action_name}".to_sym, "#{action_name}".to_sym
            private "cheap_themes_original_action_#{action_name}".to_sym
CLS_EVAL

          ruby_code = <<INS_EVAL
          def #{action_name}
            theme = self.send(self.class.actions_theme_finder_method)
            if self.respond_to? "cheap_themes_customized_action_\#{theme}_\#{controller_name}_\#{action_name}"
              self.send("cheap_themes_customized_action_\#{theme}_\#{controller_name}_\#{action_name}")
            else
              cheap_themes_original_action_\#{action_name}
            end
          end
INS_EVAL
         self.class_eval ruby_code
        end
      end
    end

  end

end
