(in-package #:augmented-definitions)

(defvar *initial-find-definitions* nil)
(defvar *initial-arglist* nil)

(defun init (())
  (unless *initial-find-definitions*
    (setf *initial-find-definitions*
          (get 'swank::find-definitions 'swank/backend::implementation)))
  (setf (get 'swank::find-definitions 'swank/backend::IMPLEMENTATION)
        (lambda (name)
          (format t "~%hi ~a~%" name)
          (funcall *initial-find-definitions* name)))
  (setf (get 'swank::arglist 'swank/backend::IMPLEMENTATION)
        (lambda (name)
          (if (string-equal name 'blah)
              `(oh yes)
              (funcall *initial-arglist* name)))))



;;----------------------------------------------------------------------
;; Example result
;;
;; CL-USER> (swank::find-definitions 'blah)

;; hi BLAH
;; (((DEFGENERIC BLAH
;;       (STREAM-ARGS &KEY))
;;   (:LOCATION
;;    (:BUFFER-AND-FILE "methodyness.lisp"
;;     "/Users/Baggers/Code/lisp/methodyness.lisp")
;;    (:OFFSET 99 0) (:SNIPPET "(defgeneric blah (stream-args &key))")))
;;  ((DEFMETHOD BLAH |(X FLOAT) (Y FLOAT)|)
;;   (:LOCATION
;;    (:BUFFER-AND-FILE "methodyness.lisp"
;;     "/Users/Baggers/Code/lisp/methodyness.lisp")
;;    (:OFFSET 266 0)
;;    (:SNIPPET "(defmethod blah ((x |(X FLOAT) (Y FLOAT)|) &key y z)
;;   1)")))
;;  ((DEFMETHOD BLAH FLOAT_FLOAT)
;;   (:LOCATION
;;    (:BUFFER-AND-FILE "methodyness.lisp"
;;     "/Users/Baggers/Code/lisp/methodyness.lisp")
;;    (:OFFSET 256 0)
;;    (:SNIPPET "(defmethod blah ((x float_float) &key y z)
;;   1)")))
;;  ((DEFMETHOD BLAH T)
;;   (:LOCATION
;;    (:BUFFER-AND-FILE "methodyness.lisp"
;;     "/Users/Baggers/Code/lisp/methodyness.lisp")
;;    (:OFFSET 138 0)
;;    (:SNIPPET "(defmethod blah (x &key y z)
;;   1)"))))
