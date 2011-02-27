# -*- coding: utf-8 -*-
# ExpandHelp.rb
# ExpandHelpApp
#
# Created by Toshiyuki Masui on 11/02/26.
# Copyright 2011 Pitecan Systems. All rights reserved.

require 'Generator'
require 'HelpData'
require 'Lib'

#
# ExpandHelpAppのメインクラス
# MacRuby以外でも動くようにしたいものだが...
#
class ExpandHelp
  attr_accessor :input           # ヘルプキーワード入力枠
  attr_accessor :table           # 検索結果
  attr_accessor :command         # 実行するUnixコマンド
  attr_accessor :commandoutput   # Unixコマンドの実行結果
  attr_accessor :cwd             # 現在のディレクトリ
	
  def initialize
    @helpdata = HelpData.new
    @generator = Generator.new
    @list = []
  end

  def awakeFromNib
    chdir(ENV['HOME'])
#    @cwd.setStringValue(ENV['HOME'])
#    Dir.chdir(@cwd.stringValue)
  end

  def chdir(dir)
    @helpdata.chdir(dir)
    @cwd.setStringValue(dir)
  end
	
  def generate(sender)
    t = Thread.new do
      @generating = true
      while @shouldgenerate do
        @shouldgenerate = false
        @generator = Generator.new
        @helpdata.helpdata.each { |data|
          #     if !data[2] || data[2] =~ @input.stringValue.to_s then 
          if !data[2] || data[2] =~ @input.string then 
            @generator.add data[0], data[1]
          end
        }
        #   @list = @generator.generate(@input.stringValue)
        @list = @generator.generate(@input.string)
        @table.reloadData
      end
      @generating = false
    end
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
    s = eval @command.stringValue
    @commandoutput.insertText(s.to_s)
#    @commandoutput.insertText(`#{@command.stringValue}`)

    chdir(@helpdata.cwd)
  end

  def keyDown(event) # ???
    puts event
  end

  def textDidChange(notification)
    puts notification
    @shouldgenerate = true
    generate(nil) unless @generating
  end
end
