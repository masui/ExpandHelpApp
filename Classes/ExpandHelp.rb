# -*- coding: utf-8 -*-
# ExpandHelp.rb
# ExpandHelpApp
#
# Created by Toshiyuki Masui on 11/02/26.
# Copyright 2011 Pitecan Systems. All rights reserved.

require 'Generator'
require 'HelpData'

#
# ExpandHelpAppのメインクラス
# MacRuby以外でも動くようにしたいものだが...
#
class ExpandHelp
  attr_accessor :input           # ヘルプキーワード入力枠
  attr_accessor :table           # 検索結果
  attr_accessor :command         # 実行するUnixコマンド
  attr_accessor :commandoutput   # 実行するUnixコマンド
	
  def initialize
    @helpdata = HelpData.new
    @generator = Generator.new
    @list = []
  end
	
  def generate(sender)
    @generator = Generator.new
    @helpdata.helpdata.each { |data|
      @generator.add data[0], data[1]
    }
    @list = @generator.generate(@input.stringValue)
    @table.reloadData
  end

  # NSTableView Tutorial
  # http://www.cocoadev.com/index.pl?NSTableViewTutorial

  def numberOfRowsInTableView(table)
    @table = table
    @list.length
  end
	
  def tableView(table, objectValueForTableColumn:val, row:r)
    @table = table
    @list[r][0]
  end
  
  # table要素がクリックされたとき呼ばれる
  def selected(sender)
    @command.setStringValue(@list[sender.selectedRow][1])
  end

  def execute(sender)
    @commandoutput.selectAll(sender)
    @commandoutput.cut(sender)
    @commandoutput.insertText(`#{@command.stringValue}`)
  end
end
