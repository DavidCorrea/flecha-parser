require 'spec_helper'
require_relative '../lib/compilador'

describe Compilador do
  context 'empty program' do
    it 'returns an empty string' do
      expect(subject.call([])).to eq ''
    end
  end

  context 'isolated constructors' do
    context 'True' do
      it 'returns the compiled code' do
        expect(subject.call([['True']])).to eq(
          "alloc($r, 1)\n"\
          "mov_int($t, 4)\n"\
          "store($r, 0, $t)"
        )
      end
    end

    context 'False' do
      it 'returns the compiled code' do
        expect(subject.call([['False']])).to eq(
          "alloc($r, 1)\n"\
          "mov_int($t, 5)\n"\
          "store($r, 0, $t)"
        )
      end
    end

    context 'Nil' do
      it 'returns the compiled code' do
        expect(subject.call([['Nil']])).to eq(
          "alloc($r, 1)\n"\
          "mov_int($t, 6)\n"\
          "store($r, 0, $t)"
        )
      end
    end
  end

  context 'Char' do
    it 'returns the compiled code' do
      expect(subject.call([["ExprChar", 'A']])).to eq(
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
      expect(subject.call([["ExprNumber", 100]])).to eq(
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
      expect(subject.call([['Def', 'foo', ['ExprNumber', 42]]])).to eq(
        "alloc($r0, 2)\n"\
        "mov_int($t, 1)\n"\
        "store($r0, 0, $t)\n"\
        "mov_int($t, 42)\n"\
        "store($r0, 1, $t)\n"\
        "mov_reg(@G_foo, $r0)"
      )
    end
  end
end