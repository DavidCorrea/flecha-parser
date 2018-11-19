require 'spec_helper'
require_relative '../lib/compilador'

describe Compilador do
  context 'empty program' do
    it 'returns an empty string' do
      assert_expression_is_compiled_to [], ''
    end
  end

  context 'isolated constructors' do
    context 'True' do
      it 'returns the compiled code' do
        assert_expression_is_compiled_to([['True']],
          "alloc($r, 1)\n"\
          "mov_int($t, 4)\n"\
          "store($r, 0, $t)"
        )
      end
    end

    context 'False' do
      it 'returns the compiled code' do
        assert_expression_is_compiled_to([['False']],
          "alloc($r, 1)\n"\
          "mov_int($t, 5)\n"\
          "store($r, 0, $t)"
        )
      end
    end

    context 'Nil' do
      it 'returns the compiled code' do
        assert_expression_is_compiled_to([['Nil']],
          "alloc($r, 1)\n"\
          "mov_int($t, 6)\n"\
          "store($r, 0, $t)"
        )
      end
    end
  end

  context 'Char' do
    it 'returns the compiled code' do
      assert_expression_is_compiled_to([["ExprChar", 'A']],
        "alloc($r0, 2)\n"\
        "mov_int($t, 2)\n"\
        "store($r0, 0, $t)\n"\
        "mov_int($t, 65)\n"\
        "store($r0, 1, $t)"
      )
    end
  end

  context 'Int' do
    it 'returns the compiled code' do
      assert_expression_is_compiled_to([["ExprNumber", 100]],
        "alloc($r0, 2)\n"\
        "mov_int($t, 1)\n"\
        "store($r0, 0, $t)\n"\
        "mov_int($t, 100)\n"\
        "store($r0, 1, $t)"
      )
    end
  end

  context 'Variables' do
    it 'returns the compiled code' do
      assert_expression_is_compiled_to([['Def', 'foo', ['ExprNumber', 42]]],
        "alloc($r0, 2)\n"\
        "mov_int($t, 1)\n"\
        "store($r0, 0, $t)\n"\
        "mov_int($t, 42)\n"\
        "store($r0, 1, $t)\n"\
        "mov_reg(@G_foo, $r0)"
      )
    end

    it 'returns the compiled code for variable' do
      assert_expression_is_compiled_to([["Def", "main", ["ExprApply", %w(ExprVar unsafePrintInt), %w(ExprVar foo)]]],
        "mov_reg($r0, @G_foo)\n"\
        "load($r1, $r0, 1)\n"\
        "print($r1)\n"\
        "mov_reg(@G_main, $r0)"
      )
    end
  end

  context 'Let' do
    it 'returns the compiled code' do
      # [["Def", "t", ["ExprLet", "x", ["ExprNumber", 1], ["ExprVar", "x"]]]]
      assert_expression_is_compiled_to([["Def", "t", ["ExprLet", "x", ["ExprNumber", 1], %w(ExprVar x)]]],
        "alloc($temp, 2)\n"\
        "mov_int($t, 1)\n"\
        "store($temp, 0, $t)\n"\
        "mov_int($t, 1)\n"\
        "store($temp, 1, $t)\n"\
        "mov_reg($r0, $temp)\n"\
        "mov_reg(@G_t, $r0)"
      )
    end
  end

  def assert_expression_is_compiled_to(expression, expected)
    expect(subject.call(expression)).to eq(expected)
  end
end