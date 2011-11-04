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


       ['Check the weather of (#{weather})',
        '`open http://local.msn.com/ten-day.aspx?eid=#{$1}`'],
       ['Find a (Chinese|Korean|Vietnamese) restaurant in (San Francisco|Chicago|New York) on Yelp.com',
        '`open "http://www.yelp.com/search?find_loc=#{$2}&find_desc=#{$1}"`'],
       ['Set the system clock to (0|1|2|3|4|5|6|7|8|9|10|11|12):(0|1|2|3|4|5)(0|1|2|3|4|5|6|7|8|9)(AM|PM)',
        'setdate(#{$1},#{$2},#{$3})',
        /[0-9]:[0-5][0-9]/],
       ['Set the alarm clock to (0|1|2|3|4|5|6|7|8|9|10|11|12):(0|1|2|3|4|5)(0|1|2|3|4|5|6|7|8|9)(AM|PM)',
        'setalarm(#{$1},#{$2},#{$3})',
        /[0-9]:[0-5][0-9]/],
       ['(Delete|Remove|Destroy) files older than (1|2|3|4|5|6|7|8|9) months',
        'rm_old_month(#{$1})',
        /[0-9]/],
       ['(Delete|Remove|Destroy) files older than (1|2|3|4|5|6|7|8|9) years',
        'rm_old_years(#{$1})',
        /[0-9]/],
       ['(Delete|Remove|Destroy) files bigger than (1|2|3|4|5|6|7|8|9)GB',
        'rm_big(#{$1})',
        /[0-9]/],
       ['List files bigger than (1|2|3|4|5|6|7|8|9)GB',
        'list_big(#{$1})',
        /[0-9]/],
       ['(Kill|Stop) application (#{ps})',
        '`kill -9 #{$1}`'],
       ['List all the (applications|programs)',
        '`ps -eaf`'],
       ['Read (#{twitteraccount})\'s twitter articles',
        '`open http://twitter.com/#{$1}`'],
       ['Open file "(#{ls})" in Firefox browser',
        '`open "#{$1}" -a firefox`'],
       ['Ring an alarm',
        'alarm'],
#       ['Ring an alarm at (0|1|2|3|4|5|6|7|8|9|10|11|12):(0|1|2|3|4|5)(0|1|2|3|4|5|6|7|8|9)(AM|PM)',
#        'alarm',
#        /[0-9]:[0-5][0-9]/], # 数字を入力したときだけ利用

       # 文書を編集する
       ['Open file "(#{ls})" in Emacs',
        '`open "#{$1}" -a emacs`'],

       # ブラウザを起動する
       ['Run Firefox browser',
        '`open -a firefox`'],
       # "abc fire"
      ]
    @cwd = ENV['HOME']
  end

  def people
    ["増井\tmasui", "山田\tyamada"].join("|")
  end

  def weather
    "San Francisco\t29247|New York\t23164"
  end

  def station
    "鎌倉|逗子|藤沢|戸塚|横浜|渋谷|新宿|東京|品川|湘南台"
  end

  def twitteraccount
    "Barack Obama\tbarackobama|Oprah Winfrey\tOPRAH"
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


