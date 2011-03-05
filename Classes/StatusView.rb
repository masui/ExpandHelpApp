# -*- coding: utf-8 -*-
# StatusView.rb
# ExpandHelpApp
#
# Created by Toshiyuki Masui on 11/03/05.
# Copyright 2011 __MyCompanyName__. All rights reserved.

class StatusView < NSView
  attr_accessor :app
  
  def initWithFrame(rect)
    # http://d.hatena.ne.jp/swallow_life/20090614
    if super then # [super initWithFrame(rect)] のかわりらしい
      @visible = true
      self
    end
  end

  def mouseDown(event)
    puts "mouseDown"
    if @visible then
      p app.statusItem
      app.statusItem.setHighlightMode(false)
      app.hideQueryView
      app.hideOutputView
      app.hideTableView
    else
      app.statusItem.setHighlightMode(true)
      app.showQueryView
      app.showOutputView
      app.showTableView
    end
    @visible = !@visible
  end
end
