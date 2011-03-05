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
  attr_accessor :window          # アプリのウィンドウ
  attr_accessor :statusview

  attr_accessor :queryview
  attr_accessor :querywindow
	
  def initialize
    @helpdata = HelpData.new
    @generator = Generator.new
    @list = []
  end

  # IBデータを読み込んだ後で呼ばれる
  def awakeFromNib
    chdir(ENV['HOME'])

    # ステータスバー
    systemStatusBar = NSStatusBar.systemStatusBar
    statusItem = systemStatusBar.statusItemWithLength(NSVariableStatusItemLength)

p statusItem.statusBar.thickness
p @statusview
    statusItem.setView(@statusview)

    posy = @statusview.window.frame.origin.y
    posx = @statusview.window.frame.origin.x
    y = posy - @window.frame.size.height
    x = posx
    @window.setFrameOrigin(NSPoint.new(x,y-122))

    rect = NSZeroRect
    rect.size = @queryview.frame.size;
    mask = @querywindow.styleMask
    #
    # enum {
    #    NSBorderlessWindowMask = 0,
    #    NSTitledWindowMask = 1 << 0,
    #    NSClosableWindowMask = 1 << 1,
    #    NSMiniaturizableWindowMask = 1 << 2,
    #    NSResizableWindowMask = 1 << 3,
    #    NSTexturedBackgroundWindowMask = 1 << 8
    # };
    mask = 0b0000
    @querywindow.initWithContentRect(rect,
                                     styleMask:mask,
                                     backing:NSBackingStoreBuffered,
                                     defer:false)
#    @querywindow.makeKeyWindow
    @querywindow.contentView.addSubview(@queryview)
    @querywindow.setBackgroundColor(NSColor.clearColor)
    @querywindow.setMovableByWindowBackground(false)
    @querywindow.setExcludedFromWindowsMenu(true)
    @querywindow.setAlphaValue(1.0)
    @querywindow.setOpaque(false)
    @querywindow.setHasShadow(true)
    @querywindow.useOptimizedDrawing(true)
    posy = @statusview.window.frame.origin.y
    posx = @statusview.window.frame.origin.x
    y = posy - @querywindow.frame.size.height
    x = posx
    @querywindow.setFrameOrigin(NSPoint.new(x,y))

    # GCされないためのハック
    @@xxx = statusItem

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

  # NSTableView Tutorial を参考にしている
  # http://www.cocoadev.com/index.pl?NSTableViewTutorial
  # 以下のふたつのメソッドを定義しておけばテーブルが表示されるようだ

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
    chdir(@helpdata.cwd)
  end

  # NSTextViewが編集されると勝手に呼ばれる
  def textDidChange(notification)
    puts notification
    @shouldgenerate = true
    generate(nil) unless @generating
  end
end
