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
        assert_expression_is_compiled_to([["Def", "t", ['True']]],
          "alloc($r0, 1)\n"\
          "mov_int($t, 4)\n"\
          "store($r0, 0, $t)\n"\
          "mov_reg(@G_t, $r0)"
        )
      end
    end

    context 'False' do
      it 'returns the compiled code' do
        assert_expression_is_compiled_to([['Def', 'f', ['False']]],
          "alloc($r0, 1)\n"\
          "mov_int($t, 5)\n"\
          "store($r0, 0, $t)\n"\
          "mov_reg(@G_f, $r0)"
        )
      end
    end

    context 'Nil' do
      it 'returns the compiled code' do
        assert_expression_is_compiled_to([['Def', 'nil', ['Nil']]],
          "alloc($r0, 1)\n"\
          "mov_int($t, 6)\n"\
          "store($r0, 0, $t)\n"\
          "mov_reg(@G_nil, $r0)"
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
      assert_expression_is_compiled_to([['Def', 'foo', ['ExprNumber', 42]], ["Def", "main", ["ExprApply", %w(ExprVar unsafePrintInt), %w(ExprVar foo)]]],
        "alloc($r0, 2)\n"\
        "mov_int($t, 1)\n"\
        "store($r0, 0, $t)\n"\
        "mov_int($t, 42)\n"\
        "store($r0, 1, $t)\n"\
        "mov_reg(@G_foo, $r0)"\
        "mov_reg($r1, @G_foo)\n"\
        "load($r2, $r1, 1)\n"\
        "print($r2)\n"\
        "mov_reg(@G_main, $r1)"
      )
    end
  end

  context 'Let' do
    it 'returns the compiled code' do
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

  context 'Lambda' do
    it 'returns the compiled code' do
      assert_expression_is_compiled_to([["ExprLambda", "y", ["ExprVar", "y"]]],
        "rtn_1:\n"\
        "mov_reg($fun, @fun)\n"\
        "mov_reg($arg, @arg)\n"\
        "mov_reg($r0, $arg)\n"\
        "mov_reg($res, $r0)\n"\
        "mov_reg(@res, $res)\n"\
        "return()\n"
      )
    end

    it 'returns the compiled code' do
      assert_expression_is_compiled_to([["ExprLambda", "x", ["ExprLambda", "y", ["ExprVar", "x"]]]],
        "alloc($r0, 3)\n"\
        "mov_int($t, 3)\n"\
        "store($r0, 0, $t)\n"\
        ""\
        "rtn_1:\n"\
        "mov_reg($fun, @fun)\n"\
        "mov_reg($arg, @arg)\n"\
        "alloc($r1, 3)\n"\
        "mov_int($t, 3)\n"\
        "store($r1, 0, $t)\n"\
        ""\
        "rtn_2:\n"\
        "mov_reg($fun, @fun)\n"\
        "mov_reg($arg, @arg)\n"\
        "load($r2, $fun, 2)\n"\
        "mov_reg($res, $r2)\n"\
        "mov_reg(@res, $res)\n"\
        "return()\n"\
        ""\
        "mov_label($t, rtn_2)\n"\
        "store($r1, 1, $t)\n"\
        "store($r1, 2, $arg)\n"\
        "mov_reg($res, $r2)\n"\
        "mov_reg(@res, $res)\n"\
        "return()\n"\
        ""\
        "mov_label($t, rtn_1)\n"\
        "store($r0, 1, $t)\n"\
        "store($r0, 2, $arg)\n"
      )
    end
  end

  context 'Application - Common case' do
    it 'returns the compiled code' do
      assert_expression_is_compiled_to([["ExprApply", ["ExprVar", "y"], ["ExprNumber", 42]]],
        "mov_reg($r0, @G_y)\n"\
        "alloc($r1, 2)\n"\
        "mov_int($t, 1)\n"\
        "store($r1, 0, $t)\n"\
        "mov_int($t, 42)\n"\
        "store($r1, 1, $t)\n"\
        "load($r2, $r0, 1)\n"\
        "mov_reg(@fun, $r0)\n"\
        "mov_reg(@arg, $r1)\n"\
        "icall($r2)\n"\
        "mov_reg($r3, @res)\n"
      )
    end
  end

  context 'Application - Constructor' do
    it 'sarasa' do
      assert_expression_is_compiled_to([[%w'ExprConstructor Cons']],
        "rtn_1:\n"\
        "mov_reg($fun, @fun)\n"\
        "mov_reg($arg, @arg)\n"\
        "mov_reg($r0, $arg)\n"\
        "mov_reg($res, $r0)\n"\
        "mov_reg(@res, $res)\n"\
        "return()\n"\
        "alloc($r0, 3)\n"\
        "mov_int($t, 7)\n"\
        "store($r0, 0, $t)"\
      )
    end

    # it 'returns the compiled code' do
    #   assert_expression_is_compiled_to([['ExprApply', %w'ExprConstructor Cons', ['ExprNumber', 42]]],
    #
    #   # Cons (solo)
    #   "alloc($r0, 3)\n"\
    #   "mov_int($t, 7)\n"\
    #   "store($r0, 0, $t)"\
    #
    #   # 42
    #   "alloc($r1, 2)\n"\
    #     "mov_int($t, 1)\n"\
    #     "store($r1, 0, $t)\n"\
    #     "mov_int($t, 42)\n"\
    #     "store($r1, 1, $t)\n"\
    #
    #   # \x -> Cons 42 x
    #   "rtn_1:\n"\
    #   "mov_reg($fun, @fun)\n"\
    #   "mov_reg($arg, @arg)\n"\
    #
    #   "mov_reg($r0, $arg)\n"\
    #
    #   "mov_reg($res, $r0)\n"\
    #   "mov_reg(@res, $res)\n"\
    #   "return()\n"
    #
    #   # \x -> (\y -> Cons x y)
    #   # \y -> Cons 42 y
    #   # Cons 42 Nil
    #
    #
    #     "alloc($r2, 3)\n"\
    #     "mov_int($t, 7)\n"\
    #     "store($r2, 0, $t)\n"\
    #     "store($r2, 1, $r0)\n"\
    #     "store($r2, 2, $r1)\n"
    #   )
    # end
  end

  def assert_expression_is_compiled_to(expression, expected)
    expect(subject.call(expression)).to eq(expected)
  end
end