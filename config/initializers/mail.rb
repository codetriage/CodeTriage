if Rails.env.production? 
	ActionMailer::Base.smtp_settings = {
	  :address        => 'smtp.sendgrid.net',
	  :port           => '587',
	  :authentication => :plain,
	  :user_name      => ENV['SENDGRID_USERNAME'],
	  :password       => ENV['SENDGRID_PASSWORD'],
	  :domain         => 'codetriage.com'
	}
else
	# STMP using mailcatcher
	ActionMailer::Base.smtp_settings = {
	  :address        => 'localhost',
	  :port           => '1025'
	}
end
ActionMailer::Base.delivery_method = :smtp