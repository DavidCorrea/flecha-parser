require 'spec_helper'
require_relative '../lib/compiler'

describe Compiler do
  context 'empty program' do
    it 'returns an empty string' do
      assert_expression_is_compiled_to [], ''
    end
  end

  context 'Primitives' do
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
  end

  context 'isolated constructors' do
    context 'True' do
      it 'returns the compiled code' do
        assert_expression_is_compiled_to([["Def", "t", ['True']]],
          "alloc($r0, 1)\n"\
          "mov_int($t, 4)\n"\
          "store($r0, 0, $t)\n"\
          "mov_reg(@G_t, $r0)\n"
        )
      end
    end

    context 'False' do
      it 'returns the compiled code' do
        assert_expression_is_compiled_to([['Def', 'f', ['False']]],
          "alloc($r0, 1)\n"\
          "mov_int($t, 5)\n"\
          "store($r0, 0, $t)\n"\
          "mov_reg(@G_f, $r0)\n"
        )
      end
    end

    context 'Nil' do
      it 'returns the compiled code' do
        assert_expression_is_compiled_to([['Def', 'nil', ['Nil']]],
          "alloc($r0, 1)\n"\
          "mov_int($t, 6)\n"\
          "store($r0, 0, $t)\n"\
          "mov_reg(@G_nil, $r0)\n"
        )
      end
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
        "mov_reg(@G_foo, $r0)\n"
      )
    end

    it 'returns the compiled code for variable' do
      assert_expression_is_compiled_to([['Def', 'foo', ['ExprNumber', 42]], ["Def", "main", ["ExprApply", %w(ExprVar unsafePrintInt), %w(ExprVar foo)]]],
        "alloc($r0, 2)\n"\
        "mov_int($t, 1)\n"\
        "store($r0, 0, $t)\n"\
        "mov_int($t, 42)\n"\
        "store($r0, 1, $t)\n"\
        "mov_reg(@G_foo, $r0)\n"\
        "mov_reg($r1, @G_foo)\n"\
        "load($r2, $r1, 1)\n"\
        "print($r2)\n"\
        "mov_reg(@G_main, $r1)\n"
      )
    end

    it 'returns the compiled code for a char variable' do
      assert_expression_is_compiled_to([['Def', 'b_char', %w(ExprChar B)], ["Def", "main", ["ExprApply", %w(ExprVar unsafePrintChar), %w(ExprVar b_char)]]],
        "alloc($r0, 2)\n"\
        "mov_int($t, 2)\n"\
        "store($r0, 0, $t)\n"\
        "mov_int($t, 66)\n"\
        "store($r0, 1, $t)\n"\
        "mov_reg(@G_b_char, $r0)\n"\
        "mov_reg($r1, @G_b_char)\n"\
        "load($r2, $r1, 1)\n"\
        "print_char($r2)\n"\
        "mov_reg(@G_main, $r1)\n"
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
        "mov_reg(@G_t, $r0)\n"
      )
    end
  end

  context 'Lambda' do
    it 'returns the compiled code' do
      assert_expression_is_compiled_to([["ExprLambda", "y", %w(ExprVar y)]],
        "alloc($r0, 3)\n"\
        "mov_int($t, 3)\n"\
        "store($r0, 0, $t)\n"\
        "rtn_1:\n"\
        "mov_reg($fun, @fun)\n"\
        "mov_reg($arg, @arg)\n"\
        "mov_reg($r1, $arg)\n"\
        "mov_reg($res, $r1)\n"\
        "mov_reg(@res, $res)\n"\
        "return()\n"\
        "mov_label($t, rtn_1)\n"\
        "store($r0, 1, $t)\n"\
        "store($r0, 2, $arg)"
      )
    end

    it 'returns the compiled code for doble lambda' do
      assert_expression_is_compiled_to([["ExprLambda", "x", ["ExprLambda", "y", %w(ExprVar x)]]],
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
        "store($r0, 2, $arg)"
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
        "mov_reg($r3, @res)"
      )
    end
  end

  context 'Application - Constructor' do
    it 'builds a curried cons function' do
      assert_expression_is_compiled_to([%w'ExprConstructor Cons'],
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
        ""\
        "alloc($r3, 3)\n"\
        "mov_int($t, 7)\n"\
        "store($r3, 0, $t)\n"\
        "store($r3, 1, $arg)\n"\
        "store($r3, 2, $r2)\n"\
        ""\
        "mov_reg($res, $r3)\n"\
        "mov_reg(@res, $res)\n"\
        "return()\n"\
        ""\
        "mov_label($t, rtn_2)\n"\
        "store($r1, 1, $t)\n"\
        "store($r1, 2, $arg)\n"\
        "mov_reg($res, $r3)\n"\
        "mov_reg(@res, $res)\n"\
        "return()\n"\
        ""\
        "mov_label($t, rtn_1)\n"\
        "store($r0, 1, $t)\n"\
        "store($r0, 2, $arg)"
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
    expect(subject.compile(expression)).to eq(expected)
  end
end