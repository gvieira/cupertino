command :logout do |c|
  c.syntax = 'ios logout'
  c.summary = 'Remove account credentials'
  c.description = ''

  c.action do |args, options|
    users = Settings.fetch :users, []
  	user = args.first || Settings[:current_user]

    say_error "You are not authenticated" and abort if not users.include? user

	  Security::InternetPassword.delete(:server => user_hostname(user))

    Settings.delete(:current_user) if user == Settings[:current_user]
    Settings[:users].delete user
    Settings.save

    say_ok "Account credentials removed"
  end
end
