;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Bartosz Wojno"
      user-mail-address "bartoszwjn@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "SauceCodePro Nerd Font"
                           :size 13
                           :weight 'normal
                           :width 'normal))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-oceanic-next)
(load-theme 'doom-oceanic-next t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Nextcloud/org/current/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.



;; ===== GENERAL ===============================================================

(setq! doom-localleader-key ","
       doom-localleader-alt-key "M-,"
       doom-modeline-buffer-file-name-style 'relative-to-project)

(map! :leader :desc "M-x" "SPC" #'execute-extended-command)

(setq-default truncate-lines t)
(remove-hook 'text-mode-hook #'visual-line-mode)
(setq-default fill-column 100)
(global-display-fill-column-indicator-mode)



;; ===== EVIL ==================================================================

(use-package! evil
  :config
  (setq! evil-move-beyond-eol t
         evil-cross-lines t))

(use-package! evil-snipe
  :config
  (setq! evil-snipe-scope 'visible
         evil-snipe-repeat-scope 'visible)
  (map!
   (:map evil-snipe-override-mode-map :m "," nil)
   (:map evil-snipe-override-local-mode-map :m "," nil)))

(use-package! evil-escape
  :config
  (setq! evil-escape-key-sequence "fd"
         evil-escape-inhibit-functions nil))



;; ===== VISUALS ===============================================================

(use-package! olivetti
  :config
  (setq-default olivetti-body-width 120)
  (setq! olivetti-enable-visual-line-mode nil)
  (map! :leader :prefix "t" :desc "Center text" "z" #'olivetti-mode))



;; ===== ORG ===================================================================

;; List of org-agenda files.
(defun my/org-refresh-agenda-files ()
  "Regenerate the list of org-agenda files by searching `org-directory'."
  (interactive)
  (setq! org-agenda-files (directory-files-recursively org-directory "\.org$")))
(my/org-refresh-agenda-files)

(defun my/org-anniversary (year month day &optional reminders)
  (diary-remind `(org-anniversary ,year ,month ,day) reminders))

(use-package! calendar
  :config
  (setq! calendar-week-start-day 1))

(use-package! org
  :config
  (setq! org-agenda-skip-scheduled-if-done t
         org-agenda-skip-deadline-if-done t
         org-agenda-skip-deadline-prewarning-if-scheduled t
         org-agenda-start-day "+0"
         org-agenda-time-grid '((daily today)
                                (800 1000 1200 1400 1600 1800 2000)
                                "......"
                                "----------------")
         org-agenda-prefix-format '((agenda . "  %-12:c%-12t% s")
                                    (todo . " %i %-12:c")
                                    (tags . " %i %-12:c")
                                    (search . " %i %-12:c")))

  ;; My adjustments to the theme.
  (set-face-attribute 'org-block nil :background "#16262F")
  (set-face-attribute 'org-quote nil :background "#16262F")
  (set-face-attribute 'org-block-begin-line nil
                      :background "#16262F" :foreground "#65737E")
  (set-face-attribute 'org-block-end-line nil
                      :background "#16262F" :foreground "#65737E")

  (map!
   (:leader :prefix "o a" "R" #'my/org-refresh-agenda-files)
   (:map org-mode-map :localleader
         (:prefix "c" "s" #'org-clock-display)
         "P" #'org-latex-preview)
   (:map org-agenda-mode-map :localleader
         "s" #'org-save-all-org-buffers)))



;; ===== MISC ==================================================================

(use-package! epa-file
  :config
  (setq! epa-file-select-keys t))



;; ===== COMPLETION ============================================================

(use-package! company
  :config
  (map!
   (:map company-mode-map
    :i "S-SPC" #'company-complete)
   (:map company-active-map
         "RET" nil "<return>" nil))) ; disable completion with `RET'



;; ===== SYNTAX CHECKING =======================================================

(use-package! flycheck
  :config
  (map! :map flycheck-mode-map
        :leader :prefix ("e" . "error")
        "b" #'flycheck-buffer
        "c" #'flycheck-clear
        "j" #'flycheck-next-error
        "k" #'flycheck-previous-error
        "l" #'flycheck-list-errors
        "n" #'flycheck-next-error
        "p" #'flycheck-previous-error))



;; ===== MAGIT =================================================================

(use-package! magit
  :config
  (setq! magit-log-margin-show-committer-date t))



;; ===== LSP ===================================================================

(use-package! lsp-mode
  :config
  (setq!
   lsp-auto-execute-action nil
   lsp-headerline-breadcrumb-enable nil
   lsp-modeline-code-actions-enable t)
  (set-face-attribute 'lsp-face-highlight-read nil
                      :background 'unspecified
                      :foreground 'unspecified
                      :distant-foreground 'unspecified
                      :bold t
                      :italic t
                      :underline t)
  (set-face-attribute 'lsp-face-highlight-write nil
                      :background 'unspecified
                      :foreground 'unspecified
                      :distant-foreground 'unspecified
                      :bold t
                      :italic t
                      :underline t)
  (set-face-attribute 'lsp-face-highlight-textual nil
                      :background 'unspecified
                      :foreground 'unspecified
                      :distant-foreground 'unspecified
                      :bold t
                      :italic t
                      :underline t))

(use-package! lsp-ui
  :config
  (setq! lsp-ui-doc-enable nil)
  (map! :map lsp-ui-mode-map
        :leader :prefix "c"
        "m" #'lsp-ui-imenu))



;; ===== TREE SITTER ===========================================================

(setq! +tree-sitter-hl-enabled-modes nil)



;; ===== PROGRAMMING ===========================================================

;; ===== DOCKER =====

(use-package! docker
  :mode ("Dockerfile\\'" . dockerfile-mode))



;; ===== HASKELL =====

(use-package! haskell-mode
  :config
  (map! (:map haskell-error-mode-map :n "q" #'+popup/quit-window)
        (:map haskell-cabal-mode-map
              (:m "(" #'haskell-cabal-previous-subsection
               :m ")" #'haskell-cabal-next-subsection
               :m "{" #'haskell-cabal-previous-section
               :m "}" #'haskell-cabal-next-section)
              (:localleader
               "TAB" #'haskell-cabal-indent-line
               "s" #'haskell-cabal-subsection-arrange-lines
               "f" #'haskell-cabal-find-or-create-source-file
               (:prefix ("g" . "goto")
                        "b" #'haskell-cabal-goto-benchmark-section
                        "c" #'haskell-cabal-goto-common-section
                        "e" #'haskell-cabal-goto-executable-section
                        "l" #'haskell-cabal-goto-library-section
                        "t" #'haskell-cabal-goto-test-suite-section)))
        (:map haskell-mode-map
         :localleader
         (:prefix ("i" . "imports")
                  "a" #'haskell-add-import
                  "f" #'haskell-mode-format-imports
                  "g" #'haskell-navigate-imports-go
                  "r" #'haskell-navigate-imports-return))))

;; ===== JENKINS =====

(use-package! jenkinsfile-mode
  :after company-keywords
  :hook (jenkinsfile-mode . (lambda () (display-line-numbers-mode)))
  :config
  (setq! groovy-indent-offset 2)
  (setq! jenkinsfile-mode-indent-offset 2))

;; required for `:after` above to work
(use-package! company-keywords)



;; ===== LISP =====

(use-package! lispy
  :config
  (setq lispy-colon-p nil)
  (lispy-set-key-theme '(lispy c-digits))
  (map! :map lispy-mode-map :i
        "[" #'lispy-brackets
        "]" #'lispy-right-nostring
        "}" #'lispy-right-nostring))

(use-package! lispyville
  :config
  (lispyville-set-key-theme
   '(operators
     c-w
     c-u
     prettify
     ;; text-objects
     (atom-movement t)
     additional-motions
     commentary
     slurp/barf-cp
     additional
     additional-insert
     additional-wrap)))



;; ===== NASM =====

(use-package! nasm-mode
  :mode "\\.asm\\'")



;; ===== NIX =====

(use-package! nix-mode
  :hook (nix-mode . (lambda () (doom/set-indent-width 2)))
  :config
  (set-formatter! 'alejandra '("alejandra" "--quiet") :modes '(nix-mode)))


;; ===== NUSHELL =====

(use-package! prog-mode
  :mode "\\.nu\\'")



;; ===== PYTHON =====

(use-package! python
  :config
  (setq! lsp-file-watch-ignored-directories
         (append '(".*[/\\\\]__pycache__"
                   "[/\\\\].mypy_cache"
                   "[/\\\\].pytest_cache"
                   "[/\\\\]luigi_cache"
                   "[/\\\\]data"
                   "[/\\\\]out")
                 lsp-file-watch-ignored-directories)))

(use-package! pip-requirements
  :hook (pip-requirements-mode . (lambda () (remove-hook 'completion-at-point-functions
                                                         #'pip-requirements-complete-at-point
                                                         'local))))



;; ===== RUST =====

(use-package! rustic
  :config
  (setq! rustic-lsp-server 'rust-analyzer))

(use-package! lsp-mode
  :config
  (setq! lsp-rust-analyzer-proc-macro-enable t)
  (setq! lsp-rust-analyzer-cargo-load-out-dirs-from-check t))
