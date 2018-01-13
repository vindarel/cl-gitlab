;;; vindarel 2017

(in-package #:cl-user)
(defpackage #:gitlab
  (:use #:cl
        #:cl-json)
  (:export
   :request
   :project
   ))
(in-package #:gitlab)

(defparameter *domain* ".gitlab.com")

(defparameter *root-endpoint* "https://gitlab.com/api/v4")

(defvar *private-token*)

(defun request (method resource &key params data)
  "Do the http request and return an alist.

- method: keyword :GET :POST,
- resource: api endpoint. ids must be either an integer or an url-encoded couple user/project: `/projects/user%2Frepo`
- params: alist of params: '((\"login\" . \"foo\")) will be url-encoded.

Example:

(gitlab:request :GET \"/projects/vindarel%2Fabelujo\")

"
  (let* ((params (and *private-token*
                      (acons "private_token" *private-token* params)))
         (p (and params (str:concat "?" (url-encode-params params))))
         (d (and data (encode-json data)))
         (url (str:concat *root-endpoint* resource p)))
    (with-input-from-string (s (dex:request url :method method :content d))
      (decode-json s))))


(defun project (user/project &key params data)
  "Get a single project.

- user/project: str
"
  (request :GET
           (str:concat "/projects/" (quri:url-encode user/project))
           :params params :data data))
