desc "This task is called by the Heroku scheduler add-on"
task :first_action => :environment do
  puts "21時になりました。メッセージを送ります..."
  WebhookController.first_action
  puts "完了しました。"
end
