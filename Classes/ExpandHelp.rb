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
#  attr_accessor :command         # 実行するUnixコマンド
  attr_accessor :commandoutput   # Unixコマンドの実行結果
  attr_accessor :cwd             # 現在のディレクトリ
  attr_accessor :window          # アプリのウィンドウ
  attr_accessor :statusview      # ステータスバー上に表示するアイコンのビュー

  attr_accessor :queryview       # ヘルプキーワード入力ビュー
  attr_accessor :querywindow     # ヘルプキーワード入力ウィンドウ

  attr_accessor :tablewindow     # 検索結果表示ウィンドウ
  attr_accessor :tableview       # 検索結果表示ビュー
	
  attr_accessor :outputwindow     # 出力表示ウィンドウ
  attr_accessor :outputview       # 出力結果表示ビュー

  attr_accessor :statusItem
	
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
    @statusItem = systemStatusBar.statusItemWithLength(NSVariableStatusItemLength)
    @statusItem.setHighlightMode(true)
    # p statusItem.statusBar.thickness
    #
    # アイコンを表示し、ステータスバーの位置を取得するために
    # 特別にNSViewを利用する
    #
    # p @statusview
    # @statusItem.setTitle("abc")
    @statusItem.setView(@statusview)
    statusViewPosy = @statusview.window.frame.origin.y
    statusViewPosx = @statusview.window.frame.origin.x

    #
    # キーワード入力ウィンドウを作成
    #
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
    y = statusViewPosy - @querywindow.frame.size.height
    x = statusViewPosx
    @querywindow.setFrameOrigin(NSPoint.new(x,y))

    #
    # 検索結果表示ウィンドウを作成
    #
    rect = NSZeroRect
    rect.size = @tableview.frame.size;
    mask = 0b0000
    @tablewindow.initWithContentRect(rect,
                                     styleMask:mask,
                                     backing:NSBackingStoreBuffered,
                                     defer:false)
    @tablewindow.contentView.addSubview(@tableview)
    @tablewindow.setBackgroundColor(NSColor.clearColor)
    @tablewindow.setMovableByWindowBackground(false)
    @tablewindow.setExcludedFromWindowsMenu(true)
    @tablewindow.setAlphaValue(1.0)
    @tablewindow.setOpaque(false)
    @tablewindow.setHasShadow(true)
    @tablewindow.useOptimizedDrawing(true)
    posy = @querywindow.frame.origin.y
    posx = @querywindow.frame.origin.x
    y = posy - @tablewindow.frame.size.height
    x = posx
    @tablewindow.setFrameOrigin(NSPoint.new(x,y+22))

    hideTableView

    #
    # 出力表示ウィンドウを作成
    #
    rect = NSZeroRect
    rect.size = @outputview.frame.size;
    mask = 0b0000
    @outputwindow.initWithContentRect(rect,
                                     styleMask:mask,
                                     backing:NSBackingStoreBuffered,
                                     defer:false)
    @outputwindow.contentView.addSubview(@outputview)
    @outputwindow.setBackgroundColor(NSColor.clearColor)
    @outputwindow.setMovableByWindowBackground(false)
    @outputwindow.setExcludedFromWindowsMenu(true)
    @outputwindow.setAlphaValue(1.0)
    @outputwindow.setOpaque(false)
    @outputwindow.setHasShadow(true)
    @outputwindow.useOptimizedDrawing(true)
    posy = @querywindow.frame.origin.y
    posx = @querywindow.frame.origin.x
    y = posy - @outputwindow.frame.size.height
    x = posx
    @outputwindow.setFrameOrigin(NSPoint.new(x,y+22))

    hideOutputView

    # GCされないためのハック
    @@xxx = @statusItem

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
        @tableShouldBeShown = true
        showTableView
        @outputShouldBeShown = false
        hideOutputView
      end
      @generating = false
    end
  end

  # NSTableView Tutorial を参考にしている
  # http://www.cocoadev.com/index.pl?NSTableViewTutorial
  # 以下のふたつのメソッドを定義しておけばテーブルが表示されるようだ。
  # IBで、tableからこのオブジェクトをdataSource, delegateとして登録しておく。

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
    if @prevSelected == sender.selectedRow then
      execute(sender)
    end
    @prevSelected = sender.selectedRow
    # @command.setStringValue(@list[sender.selectedRow][1])
    @commandString = @list[sender.selectedRow][1]
  end

  def execute(sender)
    s = eval @commandString
    if s.gsub(/\s/,'') != '' then
      @commandoutput.selectAll(sender)
      @commandoutput.cut(sender)
      @commandoutput.insertText(s.to_s)
      @outputShouldBeShown = true
      showOutputView
    end
    chdir(@helpdata.cwd)
    @tableShouldBeShown = false
    hideTableView
  end

  # NSTextViewが編集されると勝手に呼ばれる
  def textDidChange(notification)
    @tableShouldBeShown = false
    hideTableView
    @shouldgenerate = true
    generate(nil) unless @generating
  end

  def showQueryView
    @querywindow.contentView.addSubview(@queryview)
    @querywindow.setHasShadow(true)
    @querywindow.orderFront(self)
  end

  def hideQueryView
    @queryview.removeFromSuperview
    @querywindow.setHasShadow(false)
  end

  def showTableView
    if @tableShouldBeShown then
      @tablewindow.contentView.addSubview(@tableview)
      @tablewindow.setHasShadow(true)
      @tablewindow.orderFront(self)
    end
  end

  def hideTableView
    @tableview.removeFromSuperview
    @tablewindow.setHasShadow(false)
  end

  def showOutputView
    if @outputShouldBeShown then
      @outputwindow.contentView.addSubview(@outputview)
      @outputwindow.setHasShadow(true)
      @outputwindow.orderFront(self)
    end
  end

  def hideOutputView
    @outputview.removeFromSuperview
    @outputwindow.setHasShadow(false)
  end
end
