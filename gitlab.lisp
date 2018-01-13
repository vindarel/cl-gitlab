;;; vindarel 2017

(in-package #:cl-user)
(defpackage #:gitlab
  (:use #:cl
        #:cl-json)
  (:export
   :request
   :project
   :project-issues
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
         (p (and params (str:concat "?" (quri:url-encode-params params))))
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

(defun project-issues (user/project &key params)
  "Return an alist of the project's issues, given filters of params. Needs authentication.

- params: an alist which can set state, labels, milestone, search, author_id, assignee and my_reaction_emoji as described in the api doc: https://docs.gitlab.com/ce/api/issues.html#list-project-issues

Example:

(project-issues \"vindarel/cl-torrents\" :params '((\"state\" . \"opened\")))

 "
  (request :GET
           (str:concat "/projects/" (quri:url-encode user/project) "/issues")
           :params params))
