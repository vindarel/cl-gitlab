(in-package #:cl-user)
(defpackage #:cl-gitlab-asd
  (:use #:cl #:asdf))
(in-package #:cl-gitlab-asd)

(defsystem #:cl-gitlab
  :version      "0.1.0"
  :description  "Interface to Gitlab's API"
  :author       "vindarel"
  :serial       t
  :license      "MIT"
  :depends-on   (#:quri
                 #:dexador
                 #:cl-json)
  :components   ((:file "gitlab")))
