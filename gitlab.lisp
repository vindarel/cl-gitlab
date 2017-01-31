;;; vindarel 2017
;;; wtf public licence

(in-package :cl-user)
(defpackage gitlab
  (:use :cl
        :quri
        :dexador
        :cl-json)
  (:export
   :gitlab--request
   ))
(in-package :gitlab)

(defparameter *gitlab--domain* ".gitlab.com")

(defparameter *gitlab--root-endpoint* "https://gitlab.com/api/v3")

(defun gitlab--request (method resource &key params data noerror)
  "Do the http request and return the json.
method: keyword :GET :POST,
resource: api endpoint
params: alist of params: '((\"login\" . \"foo\")) will be url-encoded."
  (let* ((params (and gitlab--private-token
                      (acons "private_token" gitlab--private-token params)))
         (p (and params (concatenate 'string "?" (url-encode-params params))))
         (d (and data (encode-json data)))
         (url (concatenate 'string *gitlab--root-endpoint* resource p)))
    (with-input-from-string (s (dex:request url :method method :content d))
      (decode-json s))
    ))

(defun gitlab--get-access-token (&key login password)
  (let* ((url (concatenate 'string *gitlab--root-endpoint*
                           "/session"
                           "?" "login=" login
                           "&" "password=" password))
         (ret (dex:post url))
         (json (with-input-from-string (s ret)
                 (decode-json s)))
         (token (cdr (assoc :PRIVATE--TOKEN json))))
    (setq gitlab--private-token token)))
