; extends

; .class-name
(class_selector
  (class_name) @selector.inner) @selector.outer

; #id-name
(id_selector
  (id_name) @selector.inner) @selector.outer

; element (div, span, etc.)
(tag_name) @selector.inner @selector.outer

; :hover, :focus, etc.
(pseudo_class_selector
  (class_name) @selector.inner) @selector.outer
