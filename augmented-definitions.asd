;;;; augmented-definitions.asd

(asdf:defsystem #:augmented-definitions
  :description "Set autodoc arglists and definitions for functions that don't exist"
  :author "Chris Bagley (Baggers <techsnuffle@gmail.com>"
  :license "BSD 2 Clause"
  :serial t
  :depends-on (:swank)
  :components ((:file "package")
               (:file "augmented-definitions")))
