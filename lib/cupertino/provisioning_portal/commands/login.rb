command :login do |c|
  c.syntax = 'ios login'
  c.summary = 'Save account credentials'
  c.description = ''

  c.action do |args, options|
    users = Settings.fetch :users, []
    user = args.first || ask("Username:")
    Settings[:current_user] = user

    if users.include? user
      say_ok "Using #{user} account"
    else
      pass = password "Password:"

      users << user
      Settings[:users] = users
      Security::InternetPassword.add(user_hostname(), user, pass)

      say_ok "Account credentials saved"
    end

    Settings.save
  end
end

command :'login:list' do |c|
  c.syntax = 'ios login:list'
  c.summary = 'List all logged in accounts'
  c.description = ''

  c.action do |args, options|
    users = Settings[:users]
    user = Settings[:current_user]

    if users
      users.sort.each do |u| 
        is_current_user = u == user
        puts is_current_user ? "* " + u.green : "  " + u
      end
    end
  end
end
