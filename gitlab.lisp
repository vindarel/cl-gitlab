;;; vindarel 2017

(in-package #:cl-user)
(defpackage #:gitlab
  (:use #:cl
        #:quri
        #:cl-json)
  (:export
   #:request
   #:get-access-token
   ))
(in-package #:gitlab)

(defparameter *domain* ".gitlab.com")

(defparameter *root-endpoint* "https://gitlab.com/api/v3")

(defvar *private-token*)

(defun request (method resource &key params data)
  "Do the http request and return the json.
method: keyword :GET :POST,
resource: api endpoint
params: alist of params: '((\"login\" . \"foo\")) will be url-encoded."
  (let* ((params (and *private-token*
                      (acons "private_token" *private-token* params)))
         (p (and params (concatenate 'string "?" (url-encode-params params))))
         (d (and data (encode-json data)))
         (url (concatenate 'string *root-endpoint* resource p)))
    (with-input-from-string (s (dex:request url :method method :content d))
      (decode-json s))))

(defun get-access-token (&key login password)
  (let* ((url (concatenate 'string *root-endpoint*
                           "/session"
                           "?" "login=" login
                           "&" "password=" password))
         (ret (dex:post url))
         (json (with-input-from-string (s ret)
                 (decode-json s)))
         (token (cdr (assoc :PRIVATE--TOKEN json))))
    (setq *private-token* token)))
