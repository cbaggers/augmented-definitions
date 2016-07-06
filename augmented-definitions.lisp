(in-package #:augmented-definitions)

(defvar *initial-autodoc* #'swank::autodoc)
(defvar *initial-find-definitions* (get 'swank::find-definitions
					'swank/backend::implementation))

(defvar *definitions* (make-hash-table))
(defvar *arg-lists* (make-hash-table))

(defun init ()
  (setf (get 'swank::find-definitions 'swank/backend::IMPLEMENTATION)
        #'our-find-definitions))

(defun reset ()
  (setf (get 'swank::find-definitions 'swank/backend::IMPLEMENTATION)
        *initial-find-definitions*))

(defun our-find-definitions (name)
  (or (gethash name *definitions*)
      (funcall *initial-find-definitions* name)))

(defun swank::autodoc (raw-form &key print-right-margin)
  (swank::with-buffer-syntax ()
    (let* ((parsed (swank::parse-raw-form raw-form))
	   (name (first parsed))
	   (sig (gethash name *arg-lists*)))
      (if sig
	  (let ((sig (cons name sig)))
	    (list (string-downcase (format nil "~s" sig)) nil))
	  (funcall *initial-autodoc* raw-form :print-right-margin print-right-margin)))))

(defun set-arg-list (name arglist)
  (setf (gethash name *arg-lists*) arglist))

(defun set-definition (name args)
  (set-arg-list name args)
  ;; run (swank::find-definitions 'get-internal-real-time) for an example
  (setf (gethash name *definitions*)
	`(((defun ,name)
	   (:location
	    (:file "/home/baggers/Code/lisp/augmented-definitions/augmented-definitions.lisp")
	    (:offset 0 0)
	    (:snippet "nothing here"))))))

(defvar valid-types
  '(defvar
    defconstant
    deftype
    define-symbol-macro
    defmacro
    define-compiler-macro
    defun
    defgeneric
    defmethod
    define-setf-expander
    defstruct
    define-condition
    defclass
    define-method-combination
    defpackage
    declaim))

;;----------------------------------------------------------------------
;; Example result
;;


(defvar example
  '(((DEFGENERIC BLAH
	 (STREAM-ARGS &KEY))
     (:LOCATION
      (:BUFFER-AND-FILE "methodyness.lisp"
			"/Users/Baggers/Code/lisp/methodyness.lisp")
      (:OFFSET 99 0) (:SNIPPET "(defgeneric blah (stream-args &key))")))
    ((DEFMETHOD BLAH FLOAT_FLOAT)
     (:LOCATION
      (:BUFFER-AND-FILE "methodyness.lisp"
			"/Users/Baggers/Code/lisp/methodyness.lisp")
      (:OFFSET 256 0)
      (:SNIPPET "(defmethod blah ((x float_float) &key y z)
  1)")))
    ((DEFMETHOD BLAH T)
     (:LOCATION
      (:BUFFER-AND-FILE "methodyness.lisp"
			"/Users/Baggers/Code/lisp/methodyness.lisp")
      (:OFFSET 138 0)
      (:SNIPPET "(defmethod blah (x &key y z)
  1)")))))

;; (defun swank::valid-operator-symbol-p (symbol)
;;   "Is SYMBOL the name of a function, a macro, or a special-operator?"
;;   (or (fboundp symbol)
;;       (macro-function symbol)
;;       (special-operator-p symbol)
;;       (member symbol '(declare declaim))
;;       ;;(and (gethash symbol *arg-lists*) symbol)
;;       ))
