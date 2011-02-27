# -*- coding: utf-8 -*-
# HelpData.rb
# ExpandHelpApp
#
# Created by Toshiyuki Masui on 11/02/27.
# Copyright 2011 Pitecan Systems. All rights reserved.

class HelpData
  def initialize
    @helpdata =
      [
       ['明日の天気を調べたい',
        'open http://3memo.com/masui/tenki'],
       ['(時計|時間|時刻)を(0|1|2|3|4|5|6|7|8|9|10|11|12)時に(セットする|設定する|あわせる)',
        '# date #{$2}:00'],
       ['(0|1|2|3|4|5|6|7|8|9|10|11|12)時に(時計|時間|時刻)を(セットする|設定する|あわせる)',
        '# date #{$1}:00'],
       ['(1|2|3|4|5|6|7|8|9)時間ごとにプログラムを(起動する|動かす)',
        '# cron repeat #{$1}'],
       ['(1|2|3|4|5|6|7|8|9)時間後にプログラムを(起動する|動かす)',
        '# at #{$1}'],
       ['(1|2|3|4|5|6|7|8|9)日以上使っていないファイルを(消す|削除する)',
        '# rm file older than #{$1} days'],
       ['(1|2|3|4|5|6|7|8|9)日以上使っていないファイルを(表示する|リストする)',
        '# list file older than #{$1} days'],
       ['ファイルを((きっちり(きっちり)?)?)消す',
        '# delete file #{$1}'],
       ['(今の|現在)(時間|時刻)は(#{date})です',
        'date'],
       ['(1|2|3|4|5|6|7|8|9)MBより大きなファイルを(消す|削除する)',
        '# delete file bigger than #{$1}MB'],
       ['(#{people})さんからのメールを(消す|削除する)',
        '# delete mail from #{$1}'],
       ['(#{ps})という(プロセス|アプリケーション|プログラム)を(消す|止める|停止する|殺す)',
        'kill -9 #{$1}'],
       ['(走って|動いて)いる(プロセス|アプリケーション|プログラム)をリストする',
        'ps -eaf'],
       ['ファイルをリストする',
        'ls -l'],
      ]
  end

  def people
    ["増井\tmasui", "山田\tyamada"].join("|")
  end

  def ps
    pslines = `ps -eaf`.split(/[\r\n]/)
    pslines.shift
    pslines.collect { |line|
      line.sub!(/^\s+/,'')
      elements = line.split(/ +/)
      pid = elements[1].to_i
      pname = elements[7].to_s
      pname.sub!(/^.*\//,'')
      "#{pname}\t#{pid}"
    }.join('|')
  end

  def date
    Time.now.to_s
  end

  def helpdata
    @helpdata.collect { |data|
      [eval('"'+data[0]+'"'), data[1]]
    }
  end
end


