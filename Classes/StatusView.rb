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
      @visible = false
      self
    end
  end

  def mouseDown(event)
    if @visible then
      app.hideQueryView
      app.hideOutputView
      app.hideTableView
      app.highlight(false)
    else
      app.showQueryView
      app.showOutputView
      app.showTableView
      app.highlight(true)
    end
    @visible = !@visible
  end
end
