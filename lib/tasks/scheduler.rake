desc "This task is called by the Heroku scheduler add-on"
task :first_action => :environment do
  puts "It's 21 o'clock. Sending message..."
  WebhookController.first_action
  puts "done."
end
