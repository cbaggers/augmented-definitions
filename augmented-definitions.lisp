(in-package #:augmented-definitions)

(defvar *initial-autodoc* #'swank::autodoc)
(defvar *initial-find-definitions* (get 'swank::find-definitions
					'swank/backend::implementation))

(defvar *definitions*)
(defvar *arg-lists* (make-hash-table))


(defun init ()
  (unless (and *definitions* *arg-lists*)
    (setf *definitions* (make-hash-table)
	  *arg-lists* (make-hash-table)))
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


(defun set-definition (name arg-list)
  (init)
  (setf (gethash name *arg-lists*) arg-list)
  ;; run (swank::find-definitions 'get-internal-real-time) for an example
  (setf (gethash name *definitions*)
	`(((defun ,name)
	   (:location
	    (:file "/home/baggers/Code/lisp/augmented-definitions/augmented-definitions.lisp")
	    (:offset 0 0)
	    (:snippet "nothing here"))))))
