; extends

; .class-name
(class_selector
  (class_name) @class.inner) @class.outer

; #id-name
(id_selector
  (id_name) @class.inner) @class.outer

; element (div, span, etc.)
(tag_name) @class.inner @class.outer

; :hover, :focus, etc.
(pseudo_class_selector
  (class_name) @class.inner) @class.outer
