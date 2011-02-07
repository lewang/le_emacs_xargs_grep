;;; xargs-grep.el --- grep large sets of files by using xargs

;; this file is not part of Emacs

;; Copyright (C) 2011 Le Wang
;; Author: Le Wang
;; Maintainer: Le Wang
;; Description: grep large sets of files by using xargs
;; Author: Le Wang
;; Maintainer: Le Wang

;; Created: Mon Feb  7 13:47:33 2011 (+0800)
;; Version: 0.1
;; Last-Updated:
;;           By:
;;     Update #:
;; URL:
;; Keywords:
;; Compatibility:

;;; Installation:

;; (require 'xargs-grep)
;;
;;

;;; Commentary:

;;
;; This is probably most useful when called from a function.  I use it to grep
;; through a large set of config files, which don't fit on the command-line.
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Code:

(require 'compile)
(require 'grep)

(provide 'xargs-grep)

(defvar xargs-grep-regexp-history '()
  "The minibuffer history list for `\\[xargs-grep]'s REGEXP argument.")

(defvar xargs-grep-files-history '()
  "The minibuffer history list for `\\[xargs-grep]'s FILES argument.")

(define-derived-mode xargs-grep-mode grep-mode "xargs grep mode"
  (setq compilation-disable-input nil))

(defun xargs-grep-read-regexp ()
  (read-from-minibuffer "Regexp: "
                        nil nil nil
                        'xargs-grep-regexp-history
                        nil))
(defun xargs-grep-read-file-string ()
  (read-from-minibuffer
   (format "Files (\"%s\" path separator): "
           path-separator)
   nil nil nil
   'xargs-grep-files-history
   nil))

;;;###autoload
(defun xargs-grep (grep-regexp files)
  "GREP-REGEXP is the regular expression to be used.
FILES is a list of files to grep through."
  (interactive (list
                (xargs-grep-read-regexp)
                (split-string (xargs-grep-read-file-string) path-separator)))
  (let (out-buf
        xargs-proc
        )
    (setq out-buf (compilation-start (concat "xargs -0 grep -EnHe "
                                             grep-regexp) 'xargs-grep-mode))
    (setq xargs-proc (get-buffer-process out-buf))
    (dolist (f files)
      (process-send-string xargs-proc (concat f "\0")))
    (process-send-eof xargs-proc)
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; xargs-grep.el ends here