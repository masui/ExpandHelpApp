# -*- coding: utf-8 -*-
# HelpData.rb
# ExpandHelpApp
#
# Created by Toshiyuki Masui on 11/02/27.
# Copyright 2011 Pitecan Systems. All rights reserved.

class HelpData
  attr_accessor :cwd

  def initialize
    @helpdata =
      [
       ['(#{weather})の天気を調べる',
        '`open http://tenki.jp/forecast/point-#{$1}.html`'],
       ['(#{restaurant})のレストランを調べる',
        '`open #{$1}`'],
       ['(時計|時間|時刻)を(0|1|2|3|4|5|6|7|8|9|10|11|12)時に(セットする|設定する|あわせる)',
        '# date #{$2}:00',
        /[0-9]/], # 数字を入力したときだけ利用
       ['(0|1|2|3|4|5|6|7|8|9|10|11|12)時に(時計|時間|時刻)を(セットする|設定する|あわせる)',
        '# date #{$1}:00',
        /[0-9]/],
       ['(1|2|3|4|5|6|7|8|9)時間ごとにプログラムを(起動する|動かす)',
        '# cron repeat #{$1}',
        /[0-9]/],
       ['(1|2|3|4|5|6|7|8|9)時間後にプログラムを(起動する|動かす)',
        '# at #{$1}',
        /[0-9]/],
       ['(1|2|3|4|5|6|7|8|9)日以上使っていないファイルを(消す|削除する)',
        '# rm file older than #{$1} days',
        /[0-9]/],
       ['(1|2|3|4|5|6|7|8|9)日以上使っていないファイルを(表示する|リストする)',
        '# list file older than #{$1} days',
        /[0-9]/],
       ['ファイルを((きっちり(きっちり)?)?)消す',
        '# delete file #{$1}'],
       ['(今の|現在)(時間|時刻)は(#{date})です',
        'Time.new'],
       ['(1|2|3|4|5|6|7|8|9)MBより大きなファイルを(消す|削除する)',
        '# delete files bigger than #{$1}MB',
        /[0-9]/],
       ['(1|2|3|4|5|6|7|8|9)MBより大きなファイルをリストする',
        '# list files bigger than #{$1}MB',
        /[0-9]/],
       ['(10|20|30|40|50|60|70|80|90)KBより大きなファイルをリストする',
        'bigfiles(#{$1}*1024)',
        /[0-9]/],
       ['(#{people})さんからのメールを(消す|削除する)',
        '# delete mail from #{$1}'],
       ['(#{ps})という(プロセス|アプリケーション|プログラム)を(消す|止める|停止する|殺す|落とす)',
        '`kill -9 #{$1}`'],
       ['(走って|動いて)いる(プロセス|アプリケーション|プログラム)をリストする',
        '`ps -eaf`'],
       ['現在のディレクトリのファイルをリストする',
        '`ls -l`'],
       ['(#{ls})というファイルを見る',
        'show "#{$1}"'],
       ['tmpディレクトリに移動する',
        'chdir("/tmp"); `ls -l`'],
       ['(#{station})駅から(#{station})駅までの電車(の(時刻|時間))を調べる',
        '`open "http://www.jorudan.co.jp/norikae/cgi/nori.cgi?rf=top&eok1=&eok2=&pg=0&eki1=#{$1}&eki2=#{$2}&Cway=0&S=検索&Csg=1"`',
        /電車|駅|時刻|時間/],
       ['(#{twitteraccount})のtwitterを読む',
        '`open http://twitter.com/#{$1}`'],
       ['twitterを読む',
        '`open http://twitter.com/`'],
       ['アラームを鳴らす',
        'alarm'],
       # 文書を編集する
       ['(#{ls})というファイルをEmacsエディタで開く',
        '`open "#{$1}" -a emacs`'],
       # 文書を編集する
       ['(#{ls})というファイルをEmacsエディタで編集する',
        '`open "#{$1}" -a emacs`'],
       # 新しいファイルを作るとき困るのね

       # ブラウザを起動する
       ['Firefox(ブラウザ)を(起動する|動かす|使う|走らせる)',
        '`open -a firefox`'],
       # "abc fire"
       # abc.htmlというファイルをfirefoxで開く
       ['(#{ls})というファイルをFirefox(ブラウザ)で開く',
        '`open "#{$1}" -a firefox`'],
      ]
    @cwd = ENV['HOME']
  end

  def people
    ["増井\tmasui", "山田\tyamada"].join("|")
  end

  def weather
    ["鎌倉\t773",
     "平塚\t772",
     "藤沢\t774",
     "秋葉原\t682",
     "渋谷\t694",
     "横浜\t744",
    ].join("|")
  end

  def station
    "鎌倉|逗子|藤沢|戸塚|横浜|渋谷|新宿|東京|品川|湘南台"
  end

  def twitteraccount
    "増井\tmasui|池田信夫\tikedanob"
  end

  def restaurant
    "鎌倉\thttp://r.tabelog.com/kanagawa/A1404/A140402/R2568/|湘南台\thttp://r.tabelog.com/kanagawa/A1404/A140405/lst/"
  end

  def date
    Time.now.to_s
  end

  def chdir(dir)
    @cwd = dir
    Dir.chdir(dir)
  end

  def helpdata
    @helpdata.collect { |data|
      [eval('%('+data[0]+')'), data[1], data[2]]
    }
  end
end


