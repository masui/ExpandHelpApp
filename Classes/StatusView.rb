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
      app.queryview.removeFromSuperview
      app.querywindow.setHasShadow(false)
    else
      app.querywindow.contentView.addSubview(app.queryview)
      app.querywindow.setHasShadow(true)
    end
    @visible = !@visible
  end
end
