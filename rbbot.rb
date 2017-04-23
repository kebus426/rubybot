# coding: utf-8
require 'slack-ruby-client'
require 'yaml'
require 'json'

file = File.open("token.txt","r") #token読み出し
TOKEN = file.read.strip()

Slack.configure do |conf| #tokenセット
  conf.token = TOKEN
end

client = Slack::RealTime::Client.new #realtimeclient slackからリアルタイムで情報を取得 トリガーとして使う
clientWeb = Slack::Web::Client.new #webclient トリガーを受けて処理する
commands = ["command","moko","hello","status"]

client.on :hello do #接続
  puts "connected!"
  clientWeb.chat_postMessage(channel: "kebus-memo",text: "むくり",username: "3go",as_user: false,icon_emoji: ":3:")
end

client.on :channel_joined do |data| #kebus-memoにjoinしたら挨拶する
  if(data["channel"]["name"] == "kebus-memo")#このイベントがkebus-memoのものか判断
   clientWeb.chat_postMessage(channel: "kebus-memo",text: "kebus-memoにようこそ～",username: "3go",as_user: false,icon_emoji: ":3:")
  end
end

client.on :reaction_added do |data|#kebusにリアクションがつくとstatusが変わる
  if("U04970D3P" == data["item_user"])
    clientWeb.users_profile_set ({:name => "status_emoji",:value => ":#{data["reaction"]}:"})
  end
end

client.on :message do |data|#発言をトリガーに動く
  case data.text
  when 'moko' then #発言がmoko 
    clientWeb.chat_postMessage(channel: 'kebus-memo',text: 'is god',username: '3go',as_user: false,icon_emoji: ':3:')
    puts data.user

  when 'hello' then#発言がhello
    users_data =  client.users
    user_data = users_data[data.user]
    user = data.user
    clientWeb.chat_postMessage(channel: 'kebus-memo',text: "やあ #{user_data.name}",username: '3go',as_user: false,icon_emoji:":3:")

  when 'status' then#発言がstatus
  users_data =  client.users #全userのデータ
  user_data = users_data[data.user] #発言者のデータ
  emoji = user_data.profile.status_emoji #発言者のstatus_emoji
  clientWeb.users_profile_set ({:name => "status_emoji",:value => emoji})#情報をset
  clientWeb.chat_postMessage(channel: 'kebus-memo',text: "kebusのstatusを#{emoji}に変えたよ～",username: '3go',as_user: false,icon_emoji: ':3:')

  when 'command' then #発言がcommand
    command = ''
    for moji in commands 
      command += moji + ' '
    end
      clientWeb.chat_postMessage(channel: 'kebus-memo',text: command + 'が使えるよ～',username: '3go',as_user: false,icon_emoji: ':3:')
  end
end
client.start!
