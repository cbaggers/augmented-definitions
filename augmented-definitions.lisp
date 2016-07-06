(in-package #:augmented-definitions)

(defvar *initial-autodoc* #'swank::autodoc)
(defvar *initial-find-definitions* (get 'swank::find-definitions
					'swank/backend::implementation))

(defvar *definitions* nil)
(defvar *arg-lists* nil)


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
  (or (when *definitions* (gethash name *definitions*))
      (funcall *initial-find-definitions* name)))


(defun swank::autodoc (raw-form &key print-right-margin)
  (swank::with-buffer-syntax ()
    (let* ((parsed (swank::parse-raw-form raw-form))
	   (name (first parsed))
	   (sig (when *arg-lists* (gethash name *arg-lists*))))
      (if sig
	  (let ((sig (cons name sig)))
	    (list (string-downcase (format nil "~s" sig)) nil))
	  (funcall *initial-autodoc* raw-form :print-right-margin print-right-margin)))))


(defun set-definition (name arg-list file buffer line col snippet)
  (init)
  (assert (and (symbolp name)
	       (listp arg-list)
	       (numberp line) (numberp col)
	       (stringp snippet)
	       (or (stringp file) (pathnamep file))
	       (or (null buffer) (stringp buffer))))
  (setf (gethash name *arg-lists*) arg-list)
  ;; run (swank::find-definitions 'get-internal-real-time) for an example
  (setf (gethash name *definitions*)
	`(((defun ,name)
	   (:location
	    ,(if buffer
		 `(:buffer-and-file ,buffer ,file)
		 `(:file ,file))
	    (:offset ,col ,line)
	    (:snippet ,snippet))))))


(defun set-defun (form file)
  (destructuring-bind (def name args &rest body) form
    (declare (ignore def body))
    (set-definition name args file nil 0 0 (format nil "~a" form))))


;;----------------------------------------------------------------------
;; Example

;; (defmacro mydef (name args &body body)
;;   (set-defun `(mydef ,name ,args ,@body)
;; 	     (or (namestring *compile-file-pathname*)
;; 		 (error "Couldnt get source file")))
;;   nil)

;; (mydef noop (x)
;;   (* x 10))
