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

  it_behaves_like 'parsea', 'def foo = 2 + 1', a: [['Def', 'foo', ["ExprApply", ["ExprApply", %w(ExprVar ADD), ["ExprNumber", 2]], ["ExprNumber", 1]]]]
  # it_behaves_like 'parsea', '3 - 1', a: ["ExprApply", ["ExprApply", %w(ExprVar SUB), ["ExprNumber", 3]], ["ExprNumber", 1]]
  # it_behaves_like 'parsea', '4 * 12', a: ["ExprApply", ["ExprApply", %w(ExprVar MUL), ["ExprNumber", 4]], ["ExprNumber", 12]]
  # it_behaves_like 'parsea', '12 / 4', a: ["ExprApply", ["ExprApply", %w(ExprVar DIV), ["ExprNumber", 12]], ["ExprNumber", 4]]
  # it_behaves_like 'parsea', '20 % 5', a: ["ExprApply", ["ExprApply", %w(ExprVar MOD), ["ExprNumber", 20]], ["ExprNumber", 5]]
  # it_behaves_like 'parsea', '-5',     a: ["ExprApply", %w(ExprVar UMINUS), ["ExprNumber", 5]]
  #
  # it_behaves_like 'parsea', 'True || False', a: ["ExprApply", ["ExprApply", %w(ExprVar OR), ["ExprConstructor", 'True']], ["ExprConstructor", 'False']]
  # it_behaves_like 'parsea', 'True && False', a: ["ExprApply", ["ExprApply", %w(ExprVar AND), ["ExprConstructor", 'True']], ["ExprConstructor", 'False']]
  # it_behaves_like 'parsea', '!True', a: ["ExprApply", %w(ExprVar NOT), ["ExprConstructor", 'True']]
  #
  # it_behaves_like 'parsea', '1 != 2', a: ["ExprApply", ["ExprApply", %w(ExprVar NE), ["ExprNumber", 1]], ["ExprNumber", 2]]
  # it_behaves_like 'parsea', '2 == 2', a: ["ExprApply", ["ExprApply", %w(ExprVar EQ), ["ExprNumber", 2]], ["ExprNumber", 2]]
  # it_behaves_like 'parsea', '1 <= 2', a: ["ExprApply", ["ExprApply", %w(ExprVar LE), ["ExprNumber", 1]], ["ExprNumber", 2]]
  # it_behaves_like 'parsea', '1 >= 2', a: ["ExprApply", ["ExprApply", %w(ExprVar GE), ["ExprNumber", 1]], ["ExprNumber", 2]]
  # it_behaves_like 'parsea', '3 > 2', a: ["ExprApply", ["ExprApply", %w(ExprVar GT), ["ExprNumber", 3]], ["ExprNumber", 2]]
  # it_behaves_like 'parsea', '3 < 2', a: ["ExprApply", ["ExprApply", %w(ExprVar LT), ["ExprNumber", 3]], ["ExprNumber", 2]]
  
  it_behaves_like 'parsea', '', a: []

  it_behaves_like 'parsea', 'def a=A', a: [["Def", "a",
                                                         ["ExprConstructor", "A"]
                                                        ]]

  it_behaves_like 'parsea', "def a = 'a' def z = 'z'", a: [["Def", "a",
                                                                         ["ExprChar", 97]
                                                                        ],
                                                                        ["Def", "z",
                                                                         ["ExprChar", 122]
                                                                        ]]

  it_behaves_like 'parsea', "def lista123 = Cons 1 (Cons 2 (Cons 3 Nil))", a: [["Def", "lista123",
                                                                                                ["ExprApply",
                                                                                                 ["ExprApply",
                                                                                                  ["ExprConstructor", "Cons"],
                                                                                                  ["ExprNumber", 1]
                                                                                                 ],
                                                                                                 ["ExprApply",
                                                                                                  ["ExprApply",
                                                                                                   ["ExprConstructor", "Cons"],
                                                                                                   ["ExprNumber", 2]
                                                                                                  ],
                                                                                                  ["ExprApply",
                                                                                                   ["ExprApply",
                                                                                                    ["ExprConstructor", "Cons"],
                                                                                                    ["ExprNumber", 3]
                                                                                                   ],
                                                                                                   ["ExprConstructor", "Nil"]
                                                                                                  ]
                                                                                                 ]
                                                                                                ]
                                                                                               ]]

  it_behaves_like 'parsea', 'def variable = 2', a: [["Def", "variable", ["ExprNumber", 2]]]

  it_behaves_like 'parsea', 'def suma x = x + 2', a: [["Def", "suma", ["ExprLambda", 'x', ["ExprApply", ["ExprApply", %w(ExprVar ADD), ["ExprVar", 'x']], ["ExprNumber", 2]]]]]

  it_behaves_like 'parsea', 'def t1 = a ; b', a: [
                                                                ["Def", "t1",
                                                                  ["ExprLet", "_",
                                                                    ["ExprVar", "a"],
                                                                    ["ExprVar", "b"]
                                                                  ]
                                                                ]
                                                              ]

  it_behaves_like 'parsea', 'def t5 = case x
         | X1 -> a
         | X2 -> b
         | X3 -> c', a: [["Def", "t5",
                          ["ExprCase",
                           ["ExprVar", "x"],
                           [
                             ["CaseBranch", "X1", [],
                              ["ExprVar", "a"]
                             ],
                             ["CaseBranch", "X2", [],
                              ["ExprVar", "b"]
                             ],
                             ["CaseBranch", "X3", [],
                              ["ExprVar", "c"]
                             ]
                           ]
                          ]
                                                     ]]

  it_behaves_like 'parsea', 'def t4 = \ x y -> y', a: [["Def", "t4",
                                                                    ["ExprLambda", "x",
                                                                     ["ExprLambda", "y",
                                                                      ["ExprVar", "y"]
                                                                     ]
                                                                    ]
                                                                    ]]

  it_behaves_like 'parsea', 'def t1 = let x = y in z', a: [["Def", "t1",
                                                                         ["ExprLet", "x",
                                                                          ["ExprVar", "y"],
                                                                          ["ExprVar", "z"]
                                                                         ]
                                                                        ]]

  it_behaves_like 'parsea', 'def t1 = if x then y else z', a: [["Def", "t1",
                                                                             ["ExprCase",
                                                                               ["ExprVar", "x"],
                                                                               [
                                                                                 ["CaseBranch", "True", [], ["ExprVar", "y"]],
                                                                                 ["CaseBranch", "False", [], ["ExprVar", "z"]]
                                                                               ]
                                                                              ]
                                                                            ]]

  it_behaves_like 'parsea', 'def t2 = if x1 then y1 elif x2 then y2 else z', a: [["Def", "t2",
                                                                                               ["ExprCase",
                                                                                                ["ExprVar", "x1"],
                                                                                                [
                                                                                                  ["CaseBranch", "True", [],
                                                                                                   ["ExprVar", "y1"]
                                                                                                  ],
                                                                                                  ["CaseBranch", "False", [],
                                                                                                   ["ExprCase",
                                                                                                    ["ExprVar", "x2"],
                                                                                                    [
                                                                                                      ["CaseBranch", "True", [],
                                                                                                       ["ExprVar", "y2"]
                                                                                                      ],
                                                                                                      ["CaseBranch", "False", [],
                                                                                                       ["ExprVar", "z"]
                                                                                                      ]
                                                                                                    ]
                                                                                                   ]
                                                                                                  ]
                                                                                                ]
                                                                                               ]
                                                                                              ]]

  it_behaves_like 'parsea', 'def abc = "abc"', a: [["Def", "abc",
                                                                 ["ExprApply",
                                                                  ["ExprApply",
                                                                   ["ExprConstructor", "Cons"],
                                                                   ["ExprChar", 97]
                                                                  ],
                                                                  ["ExprApply",
                                                                   ["ExprApply",
                                                                    ["ExprConstructor", "Cons"],
                                                                    ["ExprChar", 98]
                                                                   ],
                                                                   ["ExprApply",
                                                                    ["ExprApply",
                                                                     ["ExprConstructor", "Cons"],
                                                                     ["ExprChar", 99]
                                                                    ],
                                                                    ["ExprConstructor", "Nil"]
                                                                   ]
                                                                  ]
                                                                 ]
                                                                ]]
end