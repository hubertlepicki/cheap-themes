module CheapThemes

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end

  # Methods included int this module are visible in controllers as class methods
  module ClassMethods

    # Execute this method in your controller's class body to enable theming of views
    # Example:
    #    class ShoppingController
    #
    #      before_filter :find_current_user
    #      has_themable_views :current_users_theme
    #
    #      def index
    #      end
    #
    #      private
    #      def find_current_user
    #        @current_user = User.find(session[:user])
    #      end
    #
    #      def current_users_theme
    #        @current_user.theme_name
    #      end
    #    end
    #
    def has_themable_views(finder_method)
      @theme_finder_method = finder_method
      before_filter :cheap_themes_setup_view_paths
    end


    # Provides getter for finding theme procedure's name
    def theme_finder_method #:nodoc:
      @theme_finder_method
    end

    # Execute this method in your controller's class body to enable costomized actions
    # Example:
    #    class ShoppingController
    #
    #      before_filter :find_current_user
    #      has_customizable_actions :current_users_theme
    #
    #      def index
    #        @products = Product.paginate :all, :order => "id DESC", :per_page => 40
    #      end
    #
    #      private
    #      def find_current_user
    #        @current_user = User.find(session[:user])
    #      end
    #
    #      def current_users_theme
    #        @current_user.theme_name
    #      end
    #
    #  And then define file RAILS_ROOT/themes/somethemename/controllers/shopping/index.rb with some different content:
    #    @products = Product.paginate :all, :order => "id ASC", :per_page => 20
    #
    def has_customizable_actions(finder_method)
      @actions_theme_finder_method = finder_method
      before_filter :cheap_themes_prepare_customized_actions
    end

    # Getter for action finding theme name
    def actions_theme_finder_method #:nodoc:
      @actions_theme_finder_method
    end

  end

  module InstanceMethods #:nodoc:

    private

    # This method dynamically sets view_paths where Rails is looking for template files
    def cheap_themes_setup_view_paths #:nodoc:
      theme = self.send(self.class.theme_finder_method)
      self.view_paths = ::ActionController::Base.view_paths.dup.unshift("#{RAILS_ROOT}/themes/#{theme}/views") \
        if theme and theme =~ /[a-z]/i
    end

    # Method which loads customized actions, adds them into controller as instance variables,
    # and aliases original action methods so that they dynamically make decision wether execute
    # standard, or themed action.
    def cheap_themes_prepare_customized_actions #:nodoc:
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
