;; Packages - straight.el, use-package ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Setup straight.el stuff
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (straight-repository-branch "develop")
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package
  '(use-package :type git :host github :repo "jwiegley/use-package"))
(require 'bind-key)

;; Environment ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package exec-path-from-shell ;; Required for macOS to build org-mode
  :if (memq window-system '(mac ns))
  :straight (:host github :repo "purcell/exec-path-from-shell")
  :init (exec-path-from-shell-initialize))

(use-package no-littering ;; Keep .emacs.d clean
  :straight (:host github :repo "emacscollective/no-littering")
  :config
  (require 'recentf)
  (add-to-list 'recentf-exclude no-littering-var-directory)
  (add-to-list 'recentf-exclude no-littering-etc-directory))

;; Auth-source
(setq auth-sources '("~/.authinfo.gpg"))

;; Basics ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(prefer-coding-system 'utf-8-unix)
(defalias 'yes-or-no-p 'y-or-n-p)

;; Keybinds
(global-set-key (kbd "C-x k") 'kill-this-buffer)
(global-set-key (kbd "M-=") 'count-words)

;; Shortcut for editing init.el
(defun edot () "Open init.el file" (interactive) (find-file user-init-file))

;; Modern text-editor defaults
(blink-cursor-mode 0)
(delete-selection-mode 1)
(global-auto-revert-mode 1)
(global-hl-line-mode 1)
(setq-default indent-tabs-mode nil
              fill-column 79
              tab-width 4)
(setq line-number-mode t
      column-number-mode t
      inhibit-startup-screen t
      standard-indent 4)
(setq tramp-default-method "ssh"
      python-shell-interpreter "python3"
      dired-use-ls-dired nil)
(setq vc-ignore-dir-regexp (format "\\(%s\\)\\|\\(%s\\)" vc-ignore-dir-regexp tramp-file-name-regexp)
      vc-handled-backends '(Git))

;; UI ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package doom-themes
  :if (display-graphic-p)
  :straight (:host github :repo "hlissner/emacs-doom-themes"
             :fork (:host github :repo "jdek/emacs-doom-themes"))
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t
        doom-one-brighter-comments t
        doom-one-comment-bg nil
        doom-one-padded-modeline 2)
  (load-theme 'doom-one t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config)
  (let ((font "DejaVu Sans Mono 12"))
    (set-face-attribute 'default nil :font font)
    (set-frame-font font nil t)))

;; Show current line with dim background (TUI)
(unless (display-graphic-p) (face-spec-set 'hl-line '((t :background "black" :inherit nil))))

;; Maybe custom mode-line sometime? http://emacs-fu.blogspot.com/2011/08/customizing-mode-line.html

(use-package auto-complete ;; Setup auto completion
  :straight (:host github :repo "auto-complete/auto-complete")
  :config
  (global-auto-complete-mode 1)
  (ac-config-default)
  (setf (alist-get 'auto-complete-mode minor-mode-alist) '("")))

(use-package selectrum
  :straight (:host github :repo "raxod502/selectrum")
  :config
  (selectrum-mode 1)
  (setq-default enable-recursive-minibuffers t)) ;; important

(use-package selectrum-prescient
  :requires selectrum
  :straight (:host github :repo "raxod502/prescient.el"
             :files ("prescient.el" "selectrum-prescient.el"))
  :config
  (selectrum-prescient-mode 1)
  (prescient-persist-mode 1)
  (setq prescient-filter-method '(literal regexp fuzzy)))

;; Syntax ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package csv-mode
  :straight (:host github :repo "emacsmirror/csv-mode" :files ("csv-mode.el")))

(add-hook 'emacs-lisp-mode-hook 'show-paren-mode)
;; For some reason ElDoc is on globally by default, we can turn it off
;; and enable only when it is needed
(global-eldoc-mode -1)
(add-hook 'emacs-lisp-mode-hook 'eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'eldoc-mode)
(add-hook 'ielm-mode-hook 'eldoc-mode)
;; (add-hook 'eval-expression-minibuffer-setup-hook #'eldoc-mode)

(use-package arm64-mode :straight (:host github :repo "jdek/arm64-mode"))

;; C indentation style
(c-add-style "libav"
             '("k&r"
               (c-basic-offset . 4)
               (indent-tabs-mode . nil)
               (show-trailing-whitespace . t)
               (c-offsets-alist
                (statement-cont . (c-lineup-assignments +)))))
(setq c-default-style "libav")

(use-package ledger-mode
  :straight (:host github :repo "ledger/ledger-mode")
  :mode ("\\.ledger$" . ledger-mode))

;; Org-mode ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package org
  :straight (org-plus-contrib
             :repo "https://code.orgmode.org/bzg/org-mode.git"
             :local-repo "org"
             :files (:defaults "contrib/lisp/*.el"))
  :bind (("C-c l" . org-store-link)
         ("C-c a" . org-agenda)
         ("C-c c" . org-capture))
  :init
  (setq org-directory (file-name-as-directory "~/Desktop/org"))
  (setq org-default-notes-file (concat org-directory "capture.org"))
  (setq org-log-done t)
  (setq org-refile-targets
        '((nil :maxlevel . 3)
          (org-agenda-files :maxlevel . 3))
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil)
  (with-no-warnings
    (custom-declare-face '+org-todo-active
                         '((t (:underline t :inherit (bold font-lock-constant-face org-todo)))) "")
    (custom-declare-face '+org-todo-project
                         '((t (:underline t :inherit (bold font-lock-doc-face org-todo)))) "")
    (custom-declare-face '+org-todo-onhold
                         '((t (:underline t :inherit (bold warning org-todo)))) ""))
  (setq org-todo-keywords '((sequence "TODO(t)" "|" "DONE(d)")
                            (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)")))
  (setq org-todo-keyword-faces '(("TODO" . +org-todo-active)
                            ("DONE" . +org-todo-project)
                            ("WAITING" . +org-todo-onhold)
                            ("HOLD" . +org-todo-onhold)
                            ("CANCELLED" . +org-todo-onhold)))
  (setq org-priority-faces '((?A . error) (?B . warning) (?C . success)))
  (setq org-tags-exclude-from-inheritance '("WAITING"))
  (setq org-todo-state-tags-triggers '(("CANCELLED" ("CANCELLED" . t))
                                  ("WAITING" ("WAITING" . t))
                                  ("HOLD" ("WAITING") ("HOLD" . t))
                                  (done ("WAITING") ("HOLD"))
                                  ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
                                  ("DONE" ("WAITING") ("CANCELLED") ("HOLD"))))
  ;; Org Column initial format
  (setq org-columns-default-format "%25ITEM %CLOCKSUM %TAGS %PRIORITY %TODO")
  ;; Show Habits in Agenda for future days
  (setq org-habit-show-habits-only-for-today nil)
  ;; Only show the next upcoming repeat in the agenda
  (setq org-agenda-show-future-repeats nil)
  :config
  (add-to-list 'org-modules 'org-habit t)
  (add-to-list 'org-modules 'org-timer t)
  ;; Org-mode + Ledger-mode
  (org-babel-do-load-languages
    'org-babel-load-languages '((ledger . t))))

(use-package org-journal
  :straight (:host github :repo "bastibe/org-journal")
  :bind ("C-c j" . org-journal-new-entry)
  :init
  (setq org-journal-dir (concat org-directory "/journal"))
  (setq org-journal-file-format "%Y%m%d.org")
  (setq org-journal-date-format "%A, %d/%m/%Y"))

;; Programs ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package time ;; World Time
  :bind ("C-c ," . display-time-world)
  :init
  (setq display-time-world-time-format "%a %b %e %H:%M %Z %Y")
  (setq display-time-world-list
   '(("America/Los_Angeles" "Los Angeles, United States")
     ("America/New_York"    "New York, United States")
     ("Europe/London"       "London, United Kingdom")
     ("Europe/Berlin"       "Berlin, Germany")
     ("Africa/Johannesburg" "Johannesburg, South Africa")
     ("Asia/Manila"         "Manila, Philippines")
     ("Asia/Tokyo"          "Tokyo, Japan")
     ("Australia/Sydney"    "Sydney, Australia")))
  (setq display-time-format "%H:%M")
  (setq display-time-default-load-average nil)
  :config
  (display-time-mode 1))

(use-package ibuffer
  :bind ("C-x C-b" . ibuffer)
  :init
  (setq ibuffer-use-other-window t)
  (setq ibuffer-display-summary nil)
  (setq ibuffer-show-empty-filter-groups nil)
  :config
  (setq ibuffer-saved-filter-groups
        `(("default"
           ("Config" (or (filename . ,user-emacs-directory)
                         (filename . ,user-init-file)))
           ("Planner" (or
                       (name . "^\\*Calendar\\*$")
                       (name . "^\\*Org")
                       (mode . org-mode)
                       (filename . ,org-directory)))
           ("Journal" (mode . org-journal-mode))
           ("Emacs" (name . "^\\*"))
           )))
  (add-hook 'ibuffer-mode-hook 'ibuffer-auto-mode))

(use-package ibuffer-vc
  :after ibuffer
  :straight (:host github :repo "purcell/ibuffer-vc")
  :init
  (defun ibuffer-vc-add-vc-filter-groups () (interactive)
    (dolist (group (ibuffer-vc-generate-filter-groups-by-vc-root))
      (add-to-list 'ibuffer-filter-groups group t)))
  (defun ibuffer-vc-update ()
    (interactive)
    (ibuffer-switch-to-saved-filter-groups "default")
    (ibuffer-vc-add-vc-filter-groups)
    (revert-buffer nil))
  ;; Needs to be in :init so that hook is loaded before first load is completed
  (add-hook 'ibuffer-mode-hook 'ibuffer-vc-update)
  :bind (:map ibuffer-mode-map ([remap ibuffer-update] . ibuffer-vc-update)))
