[
  (statement_block)
  (class_body)
  (object)
  (array)
  (arguments)
  (parameters)
  (parenthesized_expression)
  (switch_statement)
  (template_substitution)
  (jsx_element)
  (jsx_self_closing_element)
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
