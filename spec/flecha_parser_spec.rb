require 'spec_helper'
require_relative '../lib/flecha_lexer'
require_relative '../lib/flecha_parser'

describe FlechaParser do
  let(:parser) { FlechaParser.new }
  let(:lexer) { FlechaLexer.new }

  shared_examples 'parsea' do |string, a:|
    it do
      tokens = lexer.lex(string)

      expect(parser.parse(tokens)).to eq(a)
    end
  end

  # Programa

  it_behaves_like 'parsea', '', a: []

  # Números

  it_behaves_like 'parsea', 'def variable = 2', a: [
    ['Def', 'variable', ['ExprNumber', 2]]
  ]

  # Variables

  it_behaves_like 'parsea', 'def suma x = x + 2', a: [
    ['Def', 'suma',
      ['ExprLambda', 'x',
        ['ExprApply',
          ['ExprApply', %w(ExprVar ADD),
            %w'ExprVar x'
          ],
          ['ExprNumber', 2]
        ]
      ]
    ]
  ]

  # Constructor

  it_behaves_like 'parsea', 'def a = A', a: [
    ['Def', 'a', %w'ExprConstructor A']
  ]

  # Caracteres

  it_behaves_like 'parsea', "def a = 'a' def z = 'z'", a: [
    ['Def', 'a', ['ExprChar', 97 ]],
    ['Def', 'z', ['ExprChar', 122]]
  ]

  # Estructuras

  it_behaves_like 'parsea', 'def lista123 = Cons 1 (Cons 2 (Cons 3 Nil))', a: [
    ['Def', 'lista123',
      ['ExprApply',
        ['ExprApply',
          %w'ExprConstructor Cons',
          ['ExprNumber', 1]
        ],
        ['ExprApply',
          ['ExprApply',
            %w'ExprConstructor Cons',
            ['ExprNumber', 2]
          ],
          ['ExprApply',
            ['ExprApply',
              %w'ExprConstructor Cons',
              ['ExprNumber', 3]
            ],
            %w'ExprConstructor Nil'
          ]
        ]
      ]
    ]
  ]

  # Strings

  it_behaves_like 'parsea', 'def abc = "abc"', a: [
    ['Def', 'abc',
      ['ExprApply',
        ['ExprApply',
          %w'ExprConstructor Cons',
          ['ExprChar', 97]
        ],
        ['ExprApply',
          ['ExprApply',
            %w'ExprConstructor Cons',
            ['ExprChar', 98]
          ],
          ['ExprApply',
            ['ExprApply',
              %w'ExprConstructor Cons',
              ['ExprChar', 99]
            ],
            %w'ExprConstructor Nil'
          ]
        ]
      ]
    ]
  ]

  # If

  it_behaves_like 'parsea', 'def t1 = if x then y else z', a: [
    ['Def', 't1',
      ['ExprCase',
        %w'ExprVar x',
        [
          ['CaseBranch', 'True',  [], %w'ExprVar y'],
          ['CaseBranch', 'False', [], %w'ExprVar z']
        ]
      ]
    ]
  ]

  # Elif

  it_behaves_like 'parsea', 'def t2 = if x1 then y1 elif x2 then y2 else z', a: [
    ['Def', 't2',
      ['ExprCase',
        %w'ExprVar x1',
        [
          ['CaseBranch', 'True', [],
            %w'ExprVar y1'
          ],
          ['CaseBranch', 'False', [],
            ['ExprCase',
              %w'ExprVar x2',
              [
                ['CaseBranch', 'True', [],
                  %w'ExprVar y2'
                ],
                ['CaseBranch', 'False', [],
                  %w'ExprVar z'
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]

  # Case

  it_behaves_like 'parsea', 'def t5 = case x | X1 -> a | X2 -> b | X3 -> c', a: [
    ['Def', 't5',
      ['ExprCase',
        %w'ExprVar x',
        [
          ['CaseBranch', 'X1', [],
            %w'ExprVar a'
          ],
          ['CaseBranch', 'X2', [],
            %w'ExprVar b'
          ],
          ['CaseBranch', 'X3', [],
            %w'ExprVar c'
          ]
        ]
      ]
    ]
  ]

  # Let

  it_behaves_like 'parsea', 'def t1 = let x = y in z', a: [
    ['Def', 't1',
      ['ExprLet', 'x',
        %w'ExprVar y',
        %w'ExprVar z'
      ]
    ]
  ]

  # Lambdas

  it_behaves_like 'parsea', 'def t4 = \ x y -> y', a: [
    ['Def', 't4',
      ['ExprLambda', 'x',
        ['ExprLambda', 'y',
          %w'ExprVar y'
        ]
      ]
    ]
  ]

  # Secuenciación

  it_behaves_like 'parsea', 'def t1 = a ; b', a: [
    ['Def', 't1',
      ['ExprLet', '_',
        %w'ExprVar a',
        %w'ExprVar b'
      ]
    ]
  ]

  # Operadores

  it_behaves_like 'parsea', 'def foo = 2 + 1',  a: [['Def', 'foo', ['ExprApply', ['ExprApply', %w(ExprVar ADD), ['ExprNumber', 2]], ['ExprNumber', 1]]]]
  it_behaves_like 'parsea', 'def foo = 3 - 1',  a: [['Def', 'foo', ['ExprApply', ['ExprApply', %w(ExprVar SUB), ['ExprNumber', 3]], ['ExprNumber', 1]]]]
  it_behaves_like 'parsea', 'def foo = 4 * 12', a: [['Def', 'foo', ['ExprApply', ['ExprApply', %w(ExprVar MUL), ['ExprNumber', 4]], ['ExprNumber', 12]]]]
  it_behaves_like 'parsea', 'def foo = 12 / 4', a: [['Def', 'foo', ['ExprApply', ['ExprApply', %w(ExprVar DIV), ['ExprNumber', 12]], ['ExprNumber', 4]]]]
  it_behaves_like 'parsea', 'def foo = 20 % 5', a: [['Def', 'foo', ['ExprApply', ['ExprApply', %w(ExprVar MOD), ['ExprNumber', 20]], ['ExprNumber', 5]]]]
  it_behaves_like 'parsea', 'def foo = -5',     a: [['Def', 'foo', ['ExprApply', %w(ExprVar UMINUS), ['ExprNumber', 5]]]]

  it_behaves_like 'parsea', 'def bool = True || False', a: [['Def', 'bool', ['ExprApply', ['ExprApply', %w(ExprVar OR), %w'ExprConstructor True'], %w'ExprConstructor False']]]
  it_behaves_like 'parsea', 'def bool = True && False', a: [['Def', 'bool', ['ExprApply', ['ExprApply', %w(ExprVar AND), %w'ExprConstructor True'], %w'ExprConstructor False']]]
  it_behaves_like 'parsea', 'def bool = !True',         a: [['Def', 'bool', ['ExprApply', %w(ExprVar NOT), %w'ExprConstructor True']]]

  it_behaves_like 'parsea', 'def bool = 1 != 2', a: [['Def', 'bool', ['ExprApply', ['ExprApply', %w(ExprVar NE), ['ExprNumber', 1]], ['ExprNumber', 2]]]]
  it_behaves_like 'parsea', 'def bool = 2 == 2', a: [['Def', 'bool', ['ExprApply', ['ExprApply', %w(ExprVar EQ), ['ExprNumber', 2]], ['ExprNumber', 2]]]]
  it_behaves_like 'parsea', 'def bool = 1 <= 2', a: [['Def', 'bool', ['ExprApply', ['ExprApply', %w(ExprVar LE), ['ExprNumber', 1]], ['ExprNumber', 2]]]]
  it_behaves_like 'parsea', 'def bool = 1 >= 2', a: [['Def', 'bool', ['ExprApply', ['ExprApply', %w(ExprVar GE), ['ExprNumber', 1]], ['ExprNumber', 2]]]]
  it_behaves_like 'parsea', 'def bool = 3 > 2',  a: [['Def', 'bool', ['ExprApply', ['ExprApply', %w(ExprVar GT), ['ExprNumber', 3]], ['ExprNumber', 2]]]]
  it_behaves_like 'parsea', 'def bool = 3 < 2',  a: [['Def', 'bool', ['ExprApply', ['ExprApply', %w(ExprVar LT), ['ExprNumber', 3]], ['ExprNumber', 2]]]]

  # Asociatividad

  it_behaves_like 'parsea', 'def it10=a/(b%(c/(d%(e/f))))', a: [
    ['Def', 'it10',
      ['ExprApply',
        ['ExprApply',
          %w'ExprVar DIV',
          %w'ExprVar a'
        ],
        ['ExprApply',
          ['ExprApply',
            %w'ExprVar MOD',
            %w'ExprVar b'
          ],
          ['ExprApply',
            ['ExprApply',
              %w'ExprVar DIV',
              %w'ExprVar c'
            ],
            ['ExprApply',
              ['ExprApply',
                %w'ExprVar MOD',
                %w'ExprVar d'
              ],
              ['ExprApply',
                ['ExprApply',
                  %w'ExprVar DIV',
                  %w'ExprVar e'
                ],
                %w'ExprVar f'
              ]
            ]
          ]
        ]
      ]
    ]
  ]

  # Precedencia

  it_behaves_like 'parsea', 'def t10=-(a && b)', a: [
    ['Def', 't10',
      ['ExprApply',
        %w'ExprVar UMINUS',
        ['ExprApply',
          ['ExprApply',
            %w'ExprVar AND',
            %w'ExprVar a'
          ],
          %w'ExprVar b'
        ]
      ]
    ]
  ]

  it_behaves_like 'parsea', 'def null list =
                               case list
                               | Nil       -> True
                               | Cons x xs -> False', a: [
    ["Def", "null",
     ["ExprLambda", "list",
      ["ExprCase",
       ["ExprVar", "list"],
       [
         ["CaseBranch", "Nil", [],
          ["ExprConstructor", "True"]
         ],
         ["CaseBranch", "Cons", ["x", "xs"],
          ["ExprConstructor", "False"]
         ]
       ]
      ]
     ]
    ]
  ]
end