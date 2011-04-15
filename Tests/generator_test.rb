# -*- coding: utf-8 -*-
require 'test/unit'

$: << 'Classes'
require 'Generator'

class GeneratorTest < Test::Unit::TestCase
  def setup
  end
  
  def teardown
  end
  
  def test_clock
    g = Generator.new
    g.add '(時計|時間|時刻)を(0|1|2|3|4|5|6|7|8|9|10|11|12)時に(セットする|設定する|あわせる)', 'set time #{$2}:00'
    res = g.generate('10')
    assert res.member?(['時刻を10時に設定する','set time 10:00'])
    assert res.member?(['時計を10時にセットする','set time 10:00'])
    assert !res.member?(['時計を8時にセットする','set time 8:00'])
  end
end


