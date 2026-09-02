[
  (statement_block)
  (class_body)
  (object)
  (array)
  (arguments)
  (parameters)
  (parenthesized_expression)
  (jsx_element)
  (jsx_self_closing_element)
  (jsx_expression)
] @indent.begin

"}" @indent.end
"]" @indent.end
")" @indent.end
">" @indent.end

[
  "{"
  "["
  "("
] @indent.branch

(comment) @indent.ignore
