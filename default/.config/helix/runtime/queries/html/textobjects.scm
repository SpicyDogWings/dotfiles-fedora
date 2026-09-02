(element) @class.around
(element
  (start_tag) @class.inside)

(start_tag) @entry.around
(start_tag
  (attribute) @parameter.inside) @parameter.around

(end_tag) @entry.inside

(attribute
  (quoted_attribute_value) @string.inside) @string.around

(comment) @comment.around
(comment) @comment.inside
