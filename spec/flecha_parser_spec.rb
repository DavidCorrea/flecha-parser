require 'spec_helper'
require_relative '../lib/flecha_reader'

describe 'Flecha Reader' do
  it 'no devuelve nada cuando hay espacios vacios' do
    resultado = FlechaReader.new.leer(' ')
    expect(resultado[0]).to be_nil
  end

  it 'no devuelve nada cuando hay tabs' do
    resultado = FlechaReader.new.leer('\\t')
    expect(resultado[0]).to be_nil
  end

  it 'no devuelve nada cuando hay saltos de linea' do
    resultado = FlechaReader.new.leer('\\n')
    expect(resultado[0]).to be_nil
  end

  it 'no devuelve nada cuando hay retornos de carro' do
    resultado = FlechaReader.new.leer('\\r')
    expect(resultado[0]).to be_nil
  end

  it 'no devuelve nada cuando hay comentarios' do
    resultado = FlechaReader.new.leer('-- comentario')
    expect(resultado[0]).to be_nil
  end
end