# Monkey Patch Commander::UI to alias password to avoid conflicts
module Commander::UI
  alias :pw :password
end

class String
  include Term::ANSIColor
end

class Settings < Hash
  SETTINGS_FILE = File.join(Cupertino::CUPERTINO_DIR, "settings.yaml")

  class << self 
    def [] key
      instance.fetch key, nil
    end

    private
      def method_missing name, *args, &block
        instance.send name, *args, &block
      end

      def instance
        @instance = new unless @instance
        @instance
      end
  end

  def initialize
    if File.exists?(SETTINGS_FILE)
      File.open(SETTINGS_FILE, "r") do |f| 
        hash = YAML.load(f.read)
        self.replace hash
      end
    end
  end

  def save
    FileUtils.mkdir_p(Cupertino::CUPERTINO_DIR) if not File.directory?(Cupertino::CUPERTINO_DIR)

    output = File.new(SETTINGS_FILE, "w")
    output.puts YAML.dump(self)
    output.close
  end
end

module Cupertino
  module ProvisioningPortal
    module Helpers
      def agent
        unless @agent
          @agent = Cupertino::ProvisioningPortal::Agent.new

          @agent.instance_eval do
            def username
              @username ||= ask "Username:"
            end

            def password
              @password ||= pw "Password:"
            end

            def team
              teams = page.form_with(:name => 'saveTeamSelection').field_with(:name => 'memberDisplayId').options.collect(&:text)
              @team ||= choose "Select a team:", *teams
            end
          end
        end

        @agent
      end
      
      def pluralize(n, singular, plural = nil)
        n.to_i == 1 ? "1 #{singular}" : "#{n} #{plural || singular + 's'}"
      end
      
      def try
        return unless block_given?

        begin
          yield
        rescue UnsuccessfulAuthenticationError
          say_error "Could not authenticate with Apple Developer Center. Check that your username & password are correct, and that your membership is valid and all pending Terms of Service & agreements are accepted. If this problem continues, try logging into https://developer.apple.com/membercenter/ from a browser to see what's going on." and abort
        end
      end

      def user_hostname user = Settings[:current_user]
        return HOSTNAME + " (#{user})"
      end
    end
  end
end
