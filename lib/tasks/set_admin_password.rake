namespace :redmine do
    desc "Set admin password and disable forced password change"
    task set_admin_password: :environment do
      admin = User.find_by(login: 'admin')
      if admin
        puts "Admin user found: #{admin.inspect}"
        admin.must_change_passwd = false # Correct field name
        admin.passwd_changed_on = Time.now # Update password changed timestamp
        if admin.save
          puts "Admin users forced password change disabled."
        else
          puts "Failed to update admin user: #{admin.errors.full_messages.join(', ')}"
        end
      else
        puts "Admin user not found. Ensure the default data is loaded first."
      end
    end
  end
  