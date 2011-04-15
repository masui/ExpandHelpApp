# -*- coding: utf-8 -*-
# Generator.rb
# ExpandHelpApp
#
# Created by Toshiyuki Masui on 11/02/26.
# Copyright 2011 Pitecan Systems. All rights reserved.

#
#          ( (  )  )  ( (    ) (  (  )  ) (   )  )  | (  (  )  )
#  pars   [1]     
#           [1,2]
#                    [3]
#                     [3,4]
#                             [3,5]

require 'Scanner'
require 'Node'

class Generator
  def initialize(s = nil)
    @s = (s ? [s] : [])
    @matchedlist = []
    @par = 0
    @commands = []
  end

  def add(pat,command)
    @s << pat
    @commands << command
  end

  #
  # patを解析して状態遷移機械を作成し、
  #
  def generate(pat, app = nil)
    res = []
	
    patterns = pat.split

    scanner = Scanner.new(@s.join('|'))
    (startnode, endnode) = regexp(scanner,true) # top level
	
    output = {}
    #
    # n個のノードを経由して生成される状態の集合をlists[n]に入れる
    # 状態文字列はノードID, 生成文字列, マッチ文字列をタブで区切って並べる。
    # e.g. statestr = "123 時刻を7時に 時刻 7"
    # 受理状態のときは list[statestr] にルール番号を入れる。
    #
    lists = []
    #
    # 初期状態
    #
    list = {}
    list["#{startnode.id}\t"] = false
    lists[0] = list
    #
    #
    #
    (0..1000).each { |length|
      break if app && app.inputPending
      list = lists[length]
      newlist = {}
      list.keys.each { |entry|
        (id, s, *substrings) = entry.split(/\t/)
        s = "" if s.nil?
        substrings = [] if substrings.nil?

        srcnode = Node.node(id)
        if list.keys.length * srcnode.trans.length < 10000 then
          srcnode.trans.each { |trans|
            ss = substrings.dup
            destnode = trans.dest
            destid = destnode.id
            srcnode.pars.each { |i|
              ss[i-1] = ss[i-1].to_s + trans.pat
            }
            statestr = [destid, s+trans.pat, ss].join("\t")
            newlist[statestr] = destnode.accept
          }
        end
      }
      newlist.each { |statestr,ruleno|
        break if app && app.inputPending
        if ruleno then
          (id, s, *substrings) = statestr.split(/\t/)
          if !output[s] then
            matched = true
            #
            # 入力文字列とマッチング (ここが遅いはず)
            #
            patterns.each { |pat|
              if !s.downcase.index(pat.downcase) then
                matched = false
                break
              end
            }
            if matched then
              # substringsの配列を$1, $2...に入れる
#              b = []
#              substrings.each { |string|
#                b << (string =~ /\t(.*)$/ ? $1 : string)
#              }
#              patstr = Array.new(b.length,"(.*)").join("\t")
#              /#{patstr}/ =~ b.join("\t")

              if substrings.length > 0 then
                patstr = "(.*)\t" * (substrings.length-1) + "(.*)"
                /#{patstr}/ =~ substrings.join("\t")
              end

              # 'set date #{$2}' のような記述の$変数にsubstringの値を代入
              res << [s, eval('%('+@commands[ruleno]+')')]
            end
          end
          output[s] = true
        end
      }
      lists << newlist
    }
    app.inputPending = false if app
    res
  end

  #
  # 正規表現をパースして状態遷移機械を作る
  #

  private

  #
  #  n1  'abc'  n2
  #  □ ------> □
  #
  def regexp(s,toplevel=false) # regcat { '|' regcat }
    startnode = Node.new
    endnode = Node.new
    if toplevel then
      @pars = []
      @parno = 0
      @ruleid = 0
    end
    startnode.pars = @pars
    endnode.pars = @pars
    (n1, n2) = regcat(s)
    startnode.addTrans('',n1)
    if toplevel then
      n2.accept = @ruleid
    end
    n2.addTrans('',endnode)
    while s.gettoken == '|' && s.nexttoken != '' do
      if toplevel then
        @pars = []
        @parno = 0
        @ruleid += 1
      end
      (n1, n2) = regcat(s)
      startnode.addTrans('',n1)
      if toplevel then
        n2.accept = @ruleid
      end
      n2.addTrans('',endnode)
    end
    s.ungettoken
    return [startnode, endnode]
  end

  def regcat(s) # regfactor { regfactor }
    (startnode, endnode) = regfactor(s)
    while s.gettoken !~ /^[\)\]\|]$/ && s.nexttoken != '' do
      s.ungettoken
      (n1, n2) = regfactor(s)
      endnode.addTrans('',n1)
      endnode = n2
    end
    s.ungettoken
    return [startnode, endnode]
  end

  def regfactor(s) # regterm [ '?' | '+' | '*' ]
    (startnode, endnode) = regterm(s)
    t = s.gettoken
    if t =~ /^[\?]$/ then
      startnode.addTrans('',endnode)
    elsif t =~ /^[\+]$/ then
      endnode.addTrans('',startnode)
    elsif t =~ /^[\*]$/ then
      startnode.addTrans('',endnode)
      endnode.addTrans('',startnode)
    else
      s.ungettoken
    end
    return [startnode,endnode]
  end

  def regterm(s) # '(' regexp ')' | token
    t = s.gettoken
    if t == '(' then
      @parno += 1
      @pars.push(@parno)
      (n1, n2) = regexp(s)
      n1.pars = @pars.dup
      t = s.gettoken
      if t == ')' then
        @pars.pop
        n2.pars = @pars.dup
        return [n1, n2]
      else
        puts 'missing )'
        exit
      end
    else
      startnode = Node.new
      startnode.pars = @pars.dup
      endnode = Node.new
      endnode.pars = @pars.dup
      startnode.addTrans(t,endnode)
      return [startnode, endnode]
    end
  end
end
