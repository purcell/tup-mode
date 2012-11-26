;;; tup-mode.el --- Major mode for editing files for Tup
;;;
;;; Copyright 2012 Eric James Michael Ritz
;;;     <lobbyjones@gmail.com>
;;;     <https://github.com/ejmr/tup-mode>
;;;
;;;
;;;
;;; License:
;;;
;;; This file is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published
;;; by the Free Software Foundation; either version 3 of the License,
;;; or (at your option) any later version.
;;;
;;; This file is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this file; if not, write to the Free Software
;;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
;;; 02110-1301, USA.
;;;
;;;
;;;
;;; Usage:
;;;
;;; Place this file somewhere in your Emacs Lisp path, i.e. `site-lisp',
;;; and add this to your `.emacs' file:
;;;
;;;     (require 'tup-mode)
;;;
;;; Files ending with the `*.tup' extension, or files named `Tupfile'
;;; automatically enable tup-mode.

(require 'custom)
(require 'font-lock)
(require 'regexp-opt)

(defconst tup-mode-version-number "1.0"
  "Tup mode version number.")

(defgroup tup nil
  "Major mode for editing files for the Tup build system."
  :prefix "tup-"
  :group 'languages)

(defcustom tup-executable "/usr/local/bin/tup"
  "The location of the `tup' program."
  :type 'string
  :group 'tup)

(defconst tup/keywords-regexp
  (regexp-opt
   (list "foreach"
         "ifeq"
         "ifneq"
         "ifdef"
         "ifndef"
         "else"
         "endif"
         "include"
         "include_rules"
         "run"
         "export"
         ".gitignore")
   'words)
  "A regular expression matching all of the keywords that can
appear in Tupfiles.")

(defconst tup/font-lock-definitions
  (list
   (cons "#.*" font-lock-comment-face)
   (cons tup/keywords-regexp font-lock-keyword-face)
   (cons "^\\(!\\sw+\\)[[:space:]]*=" '(1 font-lock-preprocessor-face))
   ;; Matches: 'FOO=bar' and 'FOO+=bar' with optional spaces.
   (cons "^\\(\\sw+\\)[[:space:]]*\\+?=[[:space:]]*.+" '(1 font-lock-variable-name-face))
   (cons "\\$(\\(\\sw+\\))" '(1 font-lock-variable-name-face))
   (cons "\\@(\\(\\sw+\\))" '(1 font-lock-variable-name-face))
   (cons "^:" font-lock-constant-face)
   (cons "|>" font-lock-constant-face)
   (cons "\\<%[[:alpha:]]\\{1\\}" font-lock-preprocessor-face))
  "A map of regular expressions to font-lock faces that are used
for syntax highlighting.")

(define-derived-mode tup-mode prog-mode "Tup"
  "Major mode for editing tupfiles for the Tup build system.

\\{tup-mode-map}"
  (make-local-variable 'font-lock-defaults)
  (setq font-lock-defaults
        '(tup/font-lock-definitions nil t))
  (modify-syntax-entry ?_ "w" tup-mode-syntax-table)
  (set (make-local-variable 'require-final-newline) t)
  (font-lock-mode 1))

(defun tup/run-command (command)
  "Execute a Tup `command' in the current directory.
If the `command' is 'upd' then the output appears in the special
buffer `*Tup*'.  Other commands do not show any output."
  (if (string= command "upd")
      (progn
        (call-process-shell-command "tup" nil "*Tup*" t command)
        (switch-to-buffer "*Tup*"))
      (call-process-shell-command "tup" nil nil nil command)))

(defmacro tup/make-command-key-binding (key command)
  "Binds the `key' sequence to execute the Tup `command'.
The `key' must be a valid argument to the `kbd' macro."
  `(define-key tup-mode-map (kbd ,key)
     '(lambda ()
        (interactive)
        (tup/run-command ,command))))

;;; Bind keys to frequently used Tup commands.
(tup/make-command-key-binding "C-c C-i" "init")
(tup/make-command-key-binding "C-c C-u" "upd")
(tup/make-command-key-binding "C-c C-m" "monitor")
(tup/make-command-key-binding "C-c C-s" "stop")

;;; Automatically enable tup-mode for any file with the `*.tup'
;;; extension and for the specific file `Tupfile'.
(add-to-list 'auto-mode-alist '("\\.tup$" . tup-mode))
(add-to-list 'auto-mode-alist '("Tupfile" . tup-mode))

(provide 'tup-mode)
