;;; inactive.el -*- lexical-binding: t; -*-

;; Configuration of things that are no longer used, here in case they are ever needed again. That's
;; assuming that they still work, though...

;; Show all tabs, for editing Linux kernel code.
(use-package! whitespace
  :config
  (setq! whitespace-style '(face trailing tabs empty tab-mark)
         whitespace-global-modes '(not magit-mode magit-status-mode))
  (global-whitespace-mode 1))

;; ===== C =====

(use-package! cc-mode
  :hook
  (c-mode . (lambda () (setq tab-width 8)))
  (c-mode . (lambda () (setq indent-tabs-mode t)))
  (c-mode . (lambda () (c-set-style "linux"))))



;; ===== COQ =====

;; For some reason `use-package!` doesn't work here...
(after! company-coq
  (setq! company-coq-disabled-features
         '(company-defaults hello prettify-symbols))
  (map! :map coq-mode-map
        :localleader
        (:prefix "a"
         "p" #'coq-show-proof
         "s" #'coq-SearchIsos)))



;; ===== R =====

(use-package! ess
  :config
  (setf (alist-get "^\\*help\\[R" display-buffer-alist nil nil #'equal)
        '((display-buffer-reuse-window display-buffer-pop-up-window)))
  (map! (:map ess-r-mode-map
         :localleader
         "." #'ess-eval-region-or-line-and-step
         "l" #'ess-load-file
         "q" #'ess-quit
         "r" #'inferior-ess-reload
         "z" #'ess-switch-to-inferior-or-script-buffer
         (:prefix ("e" . "eval")
          "l" #'ess-eval-line
          "L" #'ess-eval-line-and-go
          "f" #'ess-eval-function
          "F" #'ess-eval-function-and-go
          "r" #'ess-eval-region
          "R" #'ess-eval-region-and-go
          "b" #'ess-eval-buffer
          "B" #'ess-eval-buffer-and-go)
         (:prefix ("g" . "goto")
          "r" #'ess-request-a-process))
        (:map inferior-ess-r-mode-map
         "C-y" nil
         "<C-return>" #'comint-copy-old-input
         (:localleader
          "." #'comint-goto-process-mark
          "c" #'comint-delete-output
          "l" #'ess-load-file
          "q" #'ess-quit
          "r" #'inferior-ess-reload
          "z" #'ess-switch-to-inferior-or-script-buffer))))

(use-package! poly-R
  :config
  (map! :map poly-markdown+r-mode-map
        :localleader
        "x" #'polymode-export
        "z" #'ess-switch-to-inferior-or-script-buffer))



;; ===== RACKET =====

(use-package! racket-mode
  :config
  (setq racket-show-functions '(racket-show-echo-area))
  (setq racket-xp-after-change-refresh-delay nil)
  (setq racket-submodules-to-run '((main)))
  (after! evil-snipe
    (add-to-list 'evil-snipe-disabled-modes 'racket-profile-mode))
  (map! (:map racket-describe-mode-map :n "q" #'+popup/quit-window)
        (:map racket-profile-mode-map
         :n "j" #'racket-profile-next
         :n "k" #'racket-profile-prev
         :n "p" #'racket-profile-show-non-project
         :n "q" #'+popup/quit-window
         :n "s" #'racket-profile-sort
         :n "z" #'racket-profile-show-zero)
        (:map racket-logger-mode-map
         :n "c" #'racket-logger-clear
         :n "j" #'racket-logger-next-item
         :n "k" #'racket-logger-previous-item
         :n "l" #'racket-logger-topic-level
         :n "q" #'+popup/quit-window
         :n "w" #'toggle-truncate-lines)
        (:map racket-stepper-mode-map
         :n "RET" #'racket-stepper-step
         :n "j" #'racket-stepper-next-item
         :n "k" #'racket-stepper-previous-item
         :n "q" #'+popup/quit-window)
        (:map racket-mode-map
         :localleader
         "f" nil "F" nil "h" nil "r" nil "t" nil
         "c" #'racket-xp-rename
         "R" #'racket-repl
         (:prefix ("e" . "error")
          "e" #'racket-xp-annotate
          "j" #'racket-xp-next-error
          "k" #'racket-xp-previous-error)
         (:prefix "g"
          "j" #'racket-xp-next-use
          "k" #'racket-xp-previous-use)
         (:prefix "h"
          "d" #'racket-xp-documentation
          "h" #'racket-xp-describe)
         (:prefix "m"
          "a" nil
          "f" #'racket-expand-file)
         (:prefix ("r" . "run")
          "a" #'racket-run
          "A" #'racket-run-and-switch-to-repl
          "d" #'racket-run-with-debugging
          "e" #'racket-run-with-errortrace
          "r" #'racket-run-module-at-point)
         (:prefix ("t" . "test")
          "f" #'racket-fold-all-tests
          "t" #'racket-test
          "u" #'racket-unfold-all-tests))))
