# frozen_string_literal: true
require 'rails/generators/base'
require 'rails/generators/active_record'

module ShopifyApp
  module Generators
    class ScopesStorageGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)

      class_option :with_cookie_authentication, type: :boolean, default: false
      class_option :embedded, type: :string, default: 'true'

      def create_scopes_storage_in_shop_model
        scopes_column_prompt = <<~PROMPT
          It is highly recommended that apps record the access scopes granted by\
          merchants during app installation.
          
          The following migration will add an `access_scopes` column to the Shop model. Do you want to add this migration? [y/n]
        PROMPT

        if yes?(scopes_column_prompt)
          migration_template('db/migrate/add_scopes_column.erb', 'db/migrate/add_scopes_column.rb')
          copy_file('shop_with_scopes.rb', 'app/models/shop.rb')
        end
      end

      def include_scopes_verification_in_home_controller
        template(home_controller_template, 'app/controllers/home_controller.rb')
      end

      private

      def embedded?
        options['embedded'] == 'true'
      end

      def embedded_app?
        ShopifyApp.configuration.embedded_app?
      end

      def with_cookie_authentication?
        options['with_cookie_authentication']
      end

      def home_controller_template
        return 'unauthenticated_home_controller.rb' unless authenticated_home_controller_required?

        'home_controller.rb'
      end

      def authenticated_home_controller_required?
        with_cookie_authentication? || !embedded? || !embedded_app?
      end

      def rails_migration_version
        Rails.version.match(/\d\.\d/)[0]
      end

      class << self
        private :next_migration_number

        # for generating a timestamp when using `create_migration`
        def next_migration_number(dir)
          ActiveRecord::Generators::Base.next_migration_number(dir)
        end
      end
    end
  end
end