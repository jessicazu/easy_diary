require 'line/bot'

class WebhookController < ApplicationController
  protect_from_forgery except: [:callback]

  def simple_message(text, event)
    message = {
      "type": "text",
      "text": text
    }
    client.reply_message(event['replyToken'], message)
  end

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)
    events.each { |event|
      return if event == Line::Bot::Event::Follow # 友だち追加では何もしない

      user = User.find_by(uid: event["source"]["userId"])
      if user.blank? # イベントの送信者がユーザー登録していなかった場合、登録を促す
        message = {
          "type": "template",
          "altText": "スマートフォンでご利用ください。",
          "template": {
            "type": "buttons",
            "actions": [
              {
                "type": "uri",
                "label": "登録に進む",
                "uri": "https://f547c81a.ngrok.io/users/sign_up"
              }
            ],
            "title": "はじめまして！",
            "text": "このサービスを利用するためには、Easy Diaryのユーザー登録をしてください。"
          }
        }
        client.reply_message(event['replyToken'], message)


      else # ユーザー登録していた場合
        case event # イベントの種類で分岐
        when Line::Bot::Event::Postback # 選択肢をクリックした場合

          if Diary.where(user_id: user.id, created_at: Time.zone.now.all_day, end: true).present? # すでに今日に日記を登録し終わっている場合
            simple_message("すでに今日の日記は書いています。", event)
          end


          case event["postback"]["data"] # クリックした選択肢の種類で分岐

          when "Feeling-Good" # 選択肢「良かった」をクリックした場合
            diary = Diary.new(user_id: user.id, feeling: "good")
            if diary.save
              simple_message("どんなことが良かったですか？", event)
            else
              simple_message("エラーが発生しました", event)
            end

          when "Feeling-Normal" # 選択肢「普通」をクリックした場合
            diary = Diary.new(user_id: user.id, feeling: "normal")
            if diary.save
              message = {
                "type": "template",
                "altText": "スマートフォンでご利用ください。",
                "template": {
                  "type": "confirm",
                  "actions": [
                    {
                      "type": "postback",
                      "label": "はい",
                      "displayText": "はい",
                      "data": "ImpressiveEvent-Yes"
                    },
                    {
                      "type": "postback",
                      "label": "いいえ",
                      "displayText": "いいえ",
                      "data": "ImpressiveEvent-No"
                    }
                  ],
                  "text": "何か印象的な出来事はありましたか？"
                }
              }
              client.reply_message(event['replyToken'], message)
            else
              simple_message("エラーが発生しました", event)
            end

          when "Feeling-Bad" # 選択肢「悪かった」をクリックした場合
            diary = Diary.new(user_id: user.id, feeling: "bad")

            if diary.save
              simple_message("どんなことが悪かったですか？", event)
            else
              simple_message("エラーが発生しました", event)
            end

          when "ImpressiveEvent-Yes" # 「印象的な出来事があった」場合
            diary = Diary.where(user_id: user.id, feeling: "normal", created_at: Time.zone.now.all_day).first

            if diary
              diary.impressive_event_exist = true
              if diary.save
                message = {
                  "type": "template",
                  "altText": "スマートフォンでご利用ください。",
                  "template": {
                    "type": "confirm",
                    "actions": [
                      {
                        "type": "postback",
                        "label": "はい",
                        "displayText": "はい",
                        "data": "ImpressiveEvent-Good"
                      },
                      {
                        "type": "postback",
                        "label": "いいえ",
                        "displayText": "いいえ",
                        "data": "ImpressiveEvent-Bad"
                      }
                    ],
                    "text": "それは良い出来事でしたか？"
                  }
                }
                client.reply_message(event['replyToken'], message)
              else
                simple_message("エラーが発生しました", event)
              end
            else
              simple_message("エラーが発生しました", event)
            end

          when "ImpressiveEvent-No" # 「印象的な出来事がなかった」場合
            diary = Diary.where(user_id: user.id, feeling: "normal", created_at: Time.zone.now.all_day).first

            if diary
              diary.impressive_event_exist = false
              if diary.save
                simple_message("明日は良いことがあるといいですね。\n今日は100点満点で何点でしたか？", event)
              else
                simple_message("エラーが発生しました", event)
              end
            else
              simple_message("エラーが発生しました", event)
            end

          when "ImpressiveEvent-Good" #「印象的な出来事が、良いことだった」場合
            diary = Diary.where(user_id: user.id, feeling: "normal", impressive_event_exist: true, created_at: Time.zone.now.all_day).first

            if diary
              diary.impressive_event_good = true
              if diary.save
                simple_message("明日も良いことがあるといいですね！\n今日は100点満点で何点でしたか？", event)
              else
                simple_message("エラーが発生しました", event)
              end
            else
              simple_message("エラーが発生しました", event)
            end

          when "ImpressiveEvent-Bad" #「印象的な出来事が、悪いことだった」場合」
            diary = Diary.where(user_id: user.id, feeling: "normal", impressive_event_exist: true, created_at: Time.zone.now.all_day).first

            if diary
              diary.impressive_event_good = false
              if diary.save
                simple_message("明日は良いことがあるといいですね！\n今日は100点満点で何点でしたか？", event)
              else
                simple_message("エラーが発生しました", event)
              end
            else
              simple_message("エラーが発生しました", event)
            end
          end


        when Line::Bot::Event::Message # イベントがメッセージの場合
          case event.type
          when Line::Bot::Event::MessageType::Text # イベントがテキストメッセージの場合
            text = event.message['text']

            if text == "テスト" || text == "test"
              first_action(event)
              return
            elsif text == "リセット"
              diary = Diary.where(user_id: user.id, created_at: Time.zone.now.all_day).destroy_all
              simple_message("今日の日記を消去しました。", event)
              return
            end

            if Diary.where(user_id: user.id, created_at: Time.zone.now.all_day, end: true).present? # すでに今日に日記を登録し終わっている場合
              simple_message("すでに今日の日記は書いています。", event)
            end


            diary = Diary.where(user_id: user.id, created_at: Time.zone.now.all_day).first # 現在のユーザーが今日投稿したDiary
            if diary # 現在のユーザーが今日投稿したDiaryが存在する
              if diary.detail.blank? && diary.impressive_event_exist.nil? # detailをまだ入力していないし、印象的な出来事について答えていない
                case diary.feeling
                when "good", "bad" # =>　feelingが"good"か"bad"なら送られたテキストはdetail
                  diary.detail = text

                  if diary.save
                    case diary.feeling
                    when "good"
                      simple_message("明日も良いことがあるといいですね！\n今日は100点満点で何点でしたか？", event)
                    when "bad"
                      simple_message("明日は良いことがあるといいですね！\n今日は100点満点で何点でしたか？", event)
                    end
                  else
                    simple_message("エラーが発生しました", event)
                  end

                else # 例外
                  simple_message("エラーが発生しました", event)
                end


              else # detailを入力済み または 印象的な出来事について答えている => 送られたテキストは点数
                score = text.to_i
                if  !(/^\d/ === text) || (score < 0 || score > 100) # 無効な点数(先頭が数字でない、0~100点でない)
                  simple_message("点数は、0〜100の数字で入力してください！", event)
                  return
                end

                diary.score = score
                diary.end = true # すべての入力が終わった

                if diary.save
                  message = {
                    "type": "template",
                    "altText": "スマートフォンでご利用ください。",
                    "template": {
                      "type": "buttons",
                      "actions": [
                        {
                          "type": "uri",
                          "label": "日記を見る",
                          "uri": "https://5f5212dd.ngrok.io"
                        }
                      ],
                      "title": "日記の投稿が完了しました！",
                      "text": "明日も、良い一日を。おやすみなさい♪"
                    }
                  }
                  client.reply_message(event['replyToken'], message)
                else
                  simple_message("エラーが発生しました", event)
                end
              end

            else # 今日投稿したdiaryが存在しない
              simple_message("日記を書くのは、21時になるまでお待ち下さい♪", event)
            end
          end
        end
      end
    }

    head :ok
  end

  def first_action(event) # 毎日21時に、Herokuでこのアクションを呼び出す。登録者のuidに対してPUSH MESSAGEを送る
    message = {
      "type": "template",
      "altText": "今日の日記をつけましょう！",
      "template": {
        "type": "buttons",
        "actions": [
          {
            "type": "postback",
            "label": "良かった",
            "displayText": "良かった",
            "data": "Feeling-Good"
          },
          {
            "type": "postback",
            "label": "普通",
            "displayText": "普通",
            "data": "Feeling-Normal"
          },
          {
            "type": "postback",
            "label": "悪かった",
            "displayText": "悪かった",
            "data": "Feeling-Bad"
          }
        ],
        "title": "今日の日記をつけましょう！",
        "text": "21時になりました。本日はどのような一日でしたか？"
      }
    }
    client.reply_message(event['replyToken'], message)
  end

  private
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end
