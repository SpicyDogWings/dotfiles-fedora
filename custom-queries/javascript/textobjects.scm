(function_declaration body: (_) @function.inside) @function.around
(function_expression body: (_) @function.inside) @function.around
(arrow_function body: (_) @function.inside) @function.around
(method_definition body: (_) @function.inside) @function.around

(class_declaration body: (_) @class.inside) @class.around
(class_expression body: (_) @class.inside) @class.around

(parameters ((_) @parameter.inside . ","? @parameter.around) @parameter.around)
(arguments ((_) @parameter.inside . ","? @parameter.around) @parameter.around)

(comment) @comment.around
(comment) @comment.inside
