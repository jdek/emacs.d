(setq initial-frame-alist
      '((menu-bar-lines . 0)
        (tool-bar-lines . 0)
        (horizontal-scroll-bars . nil)
        (vertical-scroll-bars . nil)
        (ns-transparent-titlebar . t)
        (ns-appearance . dark)))
(setq default-frame-alist initial-frame-alist)

;; Load custom
(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file 'noerror 'nomessage)
