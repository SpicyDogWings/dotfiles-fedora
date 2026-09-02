(jsx_element (jsx_opening_element (tag_name) @tag)))
(jsx_element (jsx_closing_element (tag_name) @tag)))
(jsx_self_closing_element (tag_name) @tag))

(jsx_attribute (property_identifier) @attribute))

(jsx_opening_element (jsx_attribute (property_identifier) @attribute)))

(jsx_text) @string

(jsx_expression) @embedded

(jsx_opening_element "<" @punctuation.bracket)
(jsx_opening_element ">" @punctuation.bracket)
(jsx_closing_element "<" @punctuation.bracket)
(jsx_closing_element ">" @punctuation.bracket)
(jsx_closing_element "/" @punctuation.bracket)
(jsx_self_closing_element "<" @punctuation.bracket)
(jsx_self_closing_element ">" @punctuation.bracket)
(jsx_self_closing_element "/" @punctuation.bracket)
