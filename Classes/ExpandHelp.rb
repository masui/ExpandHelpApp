# -*- coding: utf-8 -*-
# ExpandHelp.rb
# ExpandHelpApp
#
# Created by Toshiyuki Masui on 11/02/26.
# Copyright 2011 __MyCompanyName__. All rights reserved.

require 'Generator'
require 'HelpData'

class ExpandHelp
	attr_accessor :input
    attr_accessor :table
	attr_accessor :command
	
	def initialize
		@helpdata = HelpData.new
		@generator = Generator.new
		@list = [["(なし)",""]]
	end
	
	def doit(sender)
		puts "doit!"
		@generator = Generator.new
		@helpdata.helpdata.each { |data|
			@generator.add data[0], data[1]
		}
		@list = @generator.generate(@input.stringValue)
#		@output.selectAll(sender)
#		@output.cut(sender)
#		@output.insertText(@list.to_s)
		@table.reloadData
	end
	
	def numberOfRowsInTableView(table)
		@table = table
		puts @list.length
	    @list.length
	end
	
	def tableView(table, objectValueForTableColumn:b, row:c)
		@table = table
	    @list[c][0]
	end
	
	def selected(sender)
	    puts "selected"
		puts sender.selectedRow
		@command.setStringValue(@list[sender.selectedRow][1])
	end
end
