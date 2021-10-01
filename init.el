;;; Temporarily reduce garbage collection during startup. (See https://ambrevar.xyz/emacs2/)
(setq gc-cons-threshold (* 64 1024 1024))
(add-hook 'after-init-hook (lambda ()
							 (setq gc-cons-threshold (car (get 'gc-cons-threshold 'standard-value)))))

;; The file local-conf contains variables local to the specific machine.
;; All variables defined there are prefixed with "local-conf"
(load "~/.emacs.d/local-conf.el")

(require 'package)
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))
;; (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)
(setq package-enable-at-startup nil)

;; === Setup customize ===
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)


;;==== Server settings ====
;; Start the server...
(defun start-server-if-not-running()
  (require 'server)
  ;; ...but only do so if it is not running
  (unless (server-running-p)
	(server-start))
  (remove-hook 'focus-out-hook 'start-server-if-not-running)
  )

;; Call the server start function either if Emacs loses focus or
;; it has been idle for 5 seconds.
(add-hook 'focus-out-hook 'start-server-if-not-running)
(run-with-idle-timer 5 nil 'start-server-if-not-running)

;;==== Basic settings ====
(setq inhibit-startup-screen t)			; Don't show the welcome screen
;;(tool-bar-mode -1)					; Hide the toolbar (done in ~/.Xresources instead)
(setq completions-format 'vertical)		; Sort completion by columns
(setq sentence-end-double-space nil)	; Disable double space after sentences
(setq compilation-window-height 12)		; Reduce compilation window height
(winner-mode t)							; Recreate window configuration with winner-undo
(electric-pair-mode)					; Parenthesis matching
(setq initial-major-mode 'text-mode)	; Use text-mode for scratch-buffer
(setq reb-re-syntax (quote string))		; Prevent escape-hell in re-builder
(setq set-mark-command-repeat-pop t)	; Enable jumping through marks with C-u C-SPC (C-SPC C-SPC...)
(setq recenter-positions '(middle 0.25 top bottom)) ; Add 25% position to recenter-top-bottom (C-l)


;; Force *shell* to open in the current buffer
(add-to-list 'display-buffer-alist
             '("^\\*shell\\*$" . (display-buffer-same-window)))

;; Auto-correct case in filenames
(setq read-file-name-completion-ignore-case t)
(setq read-buffer-completion-ignore-case t)

;; Customize where backup files are stored
(setq backup-directory-alist `(("." . ,local-conf-backup-dir)))
(setq backup-by-copying t)

;; Flash mode-line instead of `dinging' (see https://www.emacswiki.org/emacs/AlarmBell)
(setq bell-colour "#F2804F") ;; This is reset in the Jazz and Smooth-Jazz themes
(setq ring-bell-function
      (lambda ()
        (let ((orig-fg (face-foreground 'mode-line)))
          (set-face-foreground 'mode-line bell-colour)
          (run-with-idle-timer 0.1 nil
                               (lambda (fg) (set-face-foreground 'mode-line fg))
                               orig-fg))))

;; Set encodings
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-language-environment 'UTF-8)


;;==== Mouse & keyboard ====
;; Horizontal mouse scrolling
(global-set-key (kbd "<mouse-7>") '(lambda() (interactive) (scroll-left 5)))
(global-set-key (kbd "<mouse-6>") '(lambda() (interactive) (scroll-right 5)))

(setq mouse-wheel-progressive-speed nil) ; Turn off scroll-speed acceleration 
(setq mouse-wheel-follow-mouse t)		 ; Scroll window below OS-cursor

(global-set-key (kbd "C-x g") 'magit-status) ; Open Magit
(defun magitKeys()
  (local-set-key (kbd "C-n") 'forward-paragraph)
  (local-set-key (kbd "C-p") 'backward-paragraph))
(add-hook 'magit-status-mode-hook 'magitKeys)


;; Define a jump function for Avy that accepts C-u modifier
(defun my-avy-jump (twoChars)
  (interactive "P")
  (if twoChars
	  (call-interactively 'avy-goto-char-2) ; If C-u was prefixed
	(call-interactively 'avy-goto-word-or-subword-1)
	)
  )
(global-set-key (kbd "C-c j") 'my-avy-jump) ; Use Avy for navigation
(setq avy-flyspell-correct-function 'ispell-word)
;; Rebind goto-line to avy-goto-line.
;; (If given an integer, avy-goto-line reverts to the standard goto-line.)
(global-set-key (kbd "M-g g") 'avy-goto-line)
(global-set-key (kbd "M-g M-g") 'avy-goto-line)

(browse-kill-ring-default-keybindings)		; M-y for browse kill-ring

;; Setup Hyper-key navigation
(global-set-key (kbd "H-j") 'backward-char)
(global-set-key (kbd "H-l") 'forward-char)
(global-set-key (kbd "H-k") 'next-line)
(global-set-key (kbd "H-i") 'previous-line)
(global-set-key (kbd "H-u") 'backward-word)
(global-set-key (kbd "H-o") 'forward-word)
(global-set-key (kbd "H-M-j") 'backward-sentence)
(global-set-key (kbd "H-M-l") 'forward-sentence)
(global-set-key (kbd "H-M-o") 'forward-paragraph)
(global-set-key (kbd "H-M-u") 'backward-paragraph)

;; Use shell-style bindings to move through history
(defun rebindComint ()
  (local-set-key (kbd "<up>") 'comint-previous-input)
  (local-set-key (kbd "<down>") 'comint-next-input))
(add-hook 'shell-mode-hook 'rebindComint)


(add-to-list 'load-path "~/.emacs.d/lisp/tinyeat/")
(load "~/.emacs.d/lisp/tinyeat/tinyeat-autoload.elc") ; Autoload Tinyeat


;; ==== Appearance ====
;;Set default font as Source Code Pro Semi-bold (done in ~/.Xresources instead)
;;(set-face-attribute 'default nil :font "Source Code Pro Semibold" :height 120)
(load-theme 'jazz)						; Load colour theme
(show-paren-mode 1)						; Turn on parenthesis-highlighting
(setq-default tab-width 4)				; Default tab-size
(setq x-stretch-cursor t)				; Stretch cursor (for instance for TAB)


;; Use xterm-color instead of ansi-color for terminal colours (much faster)
;; See https://github.com/atomontage/xterm-color
(setq comint-output-filter-functions
      (remove 'ansi-color-process-output comint-output-filter-functions))

(defun myXtermColour ()
  ;; Disable font-locking in this buffer to improve performance
  (font-lock-mode -1)
  ;; Prevent font-locking from being re-enabled in this buffer
  (make-local-variable 'font-lock-function)
  (setq font-lock-function (lambda (_) nil))
  (add-hook 'comint-preoutput-filter-functions 'xterm-color-filter nil t))

(add-hook 'shell-mode-hook 'myXtermColour)
(add-hook 'inferior-ess-mode-hook 'myXtermColour)



;; === Spell checking ====
(setenv "DICTIONARY" "da_DK")			; Setup Hunspell spell-checking
(setq ispell-program-name "hunspell")
(setq ispell-extra-args '("-d en_GB,da_DK")) ; Auto-load personal word list for each dictionary
(require 'ispell)
(setq ispell-dictionary "en_GB")		; Load british dictionary as default
;; Auto-infer language if file name contains 'dan' or 'eng'
(defun infer-language()
  (if (string-match "\\<\\(?:dan\\|dk\\)\\>" (buffer-file-name))
	  (ispell-change-dictionary "da_DK")))
(add-hook 'find-file-hook 'infer-language)

;;Load flyspell automatically
(setq flyspell-issue-message-flag nil)
(add-hook 'text-mode-hook (lambda() (flyspell-mode 1)))
(add-hook 'web-mode-hook (lambda()
						   (flyspell-mode 1)
						   (setq ispell-skip-html t)))
(global-set-key (kbd "<f12>") (lambda() (interactive) (ispell-word))) ; Correct word for keyboard
(global-set-key (kbd "C-c i") 'flyspell-check-previous-highlighted-word)

;; Enable Powerthesaurus in modes derived from text-mode
(add-hook 'text-mode-hook
		  (lambda ()
			(local-set-key (kbd "C-x t") 'powerthesaurus-lookup-word-dwim) ; Setup Powerthesaurus
			))

;; === Autocompletion ===
(with-eval-after-load 'company
  (setq company-idle-delay 0.5
		company-dabbrev-downcase nil)
  )
(with-eval-after-load 'company-quickhelp
  (setq company-quickhelp-idle-delay 1))


;; === Re-enable commands ===
(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)	; Narrow with C-x n n, widen with C-x n w
(put 'set-goal-column 'disabled nil)	; Set a 'goal' column with C-x C-n. Unset by prepending C-u


;;=== Dired and IBuffer ===
;; Do not spam dired-buffers (open reuse buffer by pressing a)
(put 'dired-find-alternate-file 'disabled nil)
(setq dired-listing-switches "-alhv") ;; h=human readable file sizes, v=sort file10 after file9


(autoload 'ibuffer "ibuffer")
(global-set-key (kbd "C-x C-b") 'ibuffer)
(with-eval-after-load 'ibuffer
  ;; Add custom filter groups
  (setq ibuffer-saved-filter-groups
		(quote (("default"
				 ("TeX & Friends" (or
								   (mode . latex-mode)
								   (mode . TeX-output-mode)
								   (mode . reftex-select-bib-mode)
								   (mode . reftex-select-label-mode)
								   (mode . bibtex-mode)
								   (name . "^\\*TeX Help\\*$")
								   (name . ".*\.xmpdata$")))
				 ("Web" (or
						 (mode . web-mode)
						 (mode . css-mode)))
				 ("Gophers" (or
							 (mode . go-mode)
							 (mode . compilation-mode)))
				 ("Magit" (or
						   (mode . magit-status-mode)
						   (mode . magit-diff-mode)
						   (mode . magit-log-mode)
						   (mode . magit-process-mode)))
				 ("Dired" (mode . dired-mode))
				 ("SAGE" (or
						  (mode . sage-shell-mode)
						  (mode . sage-shell:sage-mode)))
				 ("ESS" (or
						 (name . "^\\*ESS\\*$")
						 (mode . inferior-ess-r-mode)
						 (mode . ess-r-mode)))
				 ("MATLAB" (or
							(mode . matlab-mode)
							(mode . matlab-shell-mode)))
				 ("Emacs" (or
						   (name . "^\\*scratch\\*$")
						   (name . "^\\*Messages\\*$")
						   (name . "^\\*Completions\\*$")
						   (mode . reb-mode)))
				 )
				)
			   )
		)
  ;; Use these groups by default...
  (add-hook 'ibuffer-mode-hook
			(lambda ()
			  (ibuffer-switch-to-saved-filter-groups "default")))
  ;; ...but don't show empty groups
  (setq ibuffer-show-empty-filter-groups nil)

  ;; Human readable size in IBuffer (see https://www.emacswiki.org/emacs/IbufferMode#toc11)
  (define-ibuffer-column size-h
	(:name "Size" :inline t)
	(cond
	 ((> (buffer-size) 1000000) (format "%7.1fM" (/ (buffer-size) 1000000.0)))
	 ((> (buffer-size) 100000) (format "%7.0fk" (/ (buffer-size) 1000.0)))
	 ((> (buffer-size) 1000) (format "%7.1fk" (/ (buffer-size) 1000.0)))
	 (t (format "%8d" (buffer-size)))))
  (setq ibuffer-formats
		'((mark modified read-only " "
				(name 18 18 :left :elide)
				" "
				(size-h 9 -1 :right)
				" "
				(mode 16 16 :left :elide)
				" " filename-and-process)
		  (mark modified read-only " "
				(name 35 -1)
				" " filename)
		  ))
  )

;; Easy opening in Thunar
(setq browse-url-generic-program "thunar")
(setq browse-url-browser-function 'browse-url-generic)
(global-set-key (kbd "C-x x") '(lambda() (interactive) (browse-url-of-file (expand-file-name default-directory))))

;; ==== Evolution Mail ====
(add-to-list 'auto-mode-alist '("/tmp/evo.*" . mail-mode))
(defun my-mail-setup()
  (save-excursion
	(goto-char (point-min))
	(if (re-search-forward "hej\\|kære\\|mvh\\|hilsen\\|hilse?ner" nil t)
		(ispell-change-dictionary "da_DK")))
  (setq buffer-save-without-query t))
(add-hook 'mail-mode-hook 'my-mail-setup)

;; ==== LaTeX-mode ====
(setq latex-run-command "pdflatex")
(defun my-latex-mode-setup ()
  (require 'reftex)
  (turn-on-reftex)
  (setq reftex-plug-into-AUCTeX t)
  (setq reftex-insert-label-flags '("s" t)) ; Derive label from sections, but always ask
  (setq LaTeX-babel-hyphen nil)
  (setq TeX-debug-warnings t)
  (setq TeX-auto-save t)				; Write automatic style information when saving files
  (setq TeX-source-correlate-start-server t) ; Start server for inverse search (if not running)
  (setq bibtex-align-at-equal-sign t)
  (setq bibtex-dialect 'biblatex)
  (define-key LaTeX-mode-map (kbd "$") 'self-insert-command)

  ;; Auto-completion via company
  (company-mode)
  (define-key company-active-map [tab] 'company-complete-selection)
  (define-key company-active-map (kbd "TAB") 'company-complete-selection)
  (setq company-idle-delay 0.5)
  (setq-local company-backends
              (append '((company-math-symbols-latex company-latex-commands))
                      company-backends))
  ;; Load custom commands
  ;;(load "C:/emacs/CustomCommands/beamerCopyHeader.el")
  ;;(load "C:/emacs/CustomCommands/addPdfXData.el")
  ;; Local keybindings
  (local-set-key (kbd "C-c C-o C-e") 'TeX-error-overview)
  (local-set-key (kbd "C-x C-i") 'find-file-at-point)			 ; Open files from \include,\input etc.
  
  (TeX-source-correlate-mode)			; Synchronize with Evince
  
  ;; Highlight frame title in Beamer
  (require 'font-latex)
  (font-lock-add-keywords 'latex-mode '(("begin{frame}\\(\\[[^]]*\\]\\)?{\\(.*\\)}$" 2 '(font-latex-slide-title-face))))
  ;; Customize indentation and highlighting
  (setq TeX-brace-indent-level 4)
  (setq preview-scale-function 1.6)
  (setq LaTeX-item-indent 0)
  (setq preview-transparent-border 5)

  ;; Customize the placement of labels
  (defun unskip-line (&optional gobble)
	(save-excursion
	  (previous-line 1)
	  (if (string-match-p "\\label" (thing-at-point 'line))
		  ;; If label was inserted, move it to previous line
		  (progn (back-to-indentation)
				 (let ((my-mark (point)))
				   (move-end-of-line 0)
				   (delete-region (point) my-mark)))
		)
	  ))
  (add-hook 'LaTeX-section-hook 'unskip-line t)
  (advice-add 'LaTeX-env-label :after #'unskip-line)
  )

(setq TeX-parse-self t)					; Parse TeX-files on load

(add-hook 'LaTeX-mode-hook 'my-latex-mode-setup)

(with-eval-after-load 'reftex
  ;; Add custom environments to RefTeX, including magic words
  (setq reftex-label-alist
		(quote
		 (("proposition" ?p "prop:" "~\\ref{%s}" nil ("Proposition" "Propositions"))
		  ("prop" ?p "prop:" "~\\ref{%s}" nil (regexp "Propositions?" "Props?."))
		  ("thm" ?h "thm:" "~\\ref{%s}" nil (regexp "Theorems?" "Thms?"))
		  ("theorem" ?h "thm:" "~\\ref{%s}" nil (regexp "Theorems?" "Thms?"))
		  ("lem" ?l "lem:" "~\\ref{%s}" nil (regexp "Lemma\\(s\\|ta\\)?"))
		  ("lemma" ?l "lem:" "~\\ref{%s}" nil (regexp "Lemma\\(s\\|ta\\)?"))
		  ("cor" ?c "cor:" "~\\ref{%s}" nil (regexp "Corollar\\(y\\|ies\\)"))
		  ("corollary" ?c "cor:" "~\\ref{%s}" nil (regexp "Corollar\\(y\\|ies\\)"))
		  ("ex" ?x "ex:" "~\\ref{%s}" nil (regexp "Examples?"))
		  ("example" ?x "ex:" "~\\ref{%s}" nil (regexp "Examples?"))
		  ("defi" ?d "defi:" "~\\ref{%s}" nil (regexp "Definitions?" "Defs?."))
		  ("definition" ?d "defi:" "~\\ref{%s}" nil (regexp "Definitions?" "Defs?."))
		  ("algorithm" ?a "alg:" "~\\ref{%s}" nil (regexp "Algorithms?")))))
  )

;; Add parencite to RefTeX if not done automatically
(with-eval-after-load 'reftex-vars
  (setq reftex-cite-format
		'((?\C-m . "\\parencite{%l}")
		  (?t . "\\textcite{%l}")
		  (?c . "\\cite{%l}")
		  (?a . "\\citeauthor{%l}"))))

;; Add make as a possible compilation command
(with-eval-after-load "tex"
  (add-to-list 'TeX-command-list
			   '("Make" "make"
				 TeX-run-command t t :help "Compile file using a makefile") t))

;; When AUCTeX's syntax highlighting is acting up, use C-C C-n (TeX-normal-mode)



;; ==== Go ====
(defun my-go-mode-hook ()
  ;;(go-eldoc-setup)

  (add-hook 'before-save-hook 'gofmt-before-save) ; Call Gofmt before saving
  ;; Customize compile command to run go build
  (if (not (string-match "go" compile-command))
      (set (make-local-variable 'compile-command)
           "go build -v && go test -cover -v && go vet"))
  ;; Local keybindings
  (local-set-key (kbd "M-.") 'lsp-find-definition)
  (local-set-key (kbd "M-*") 'pop-tag-mark)
  (local-set-key (kbd "C-c C-c") 'compile)
  ;; Mark column 80...
  (require 'fill-column-indicator)
  (fci-mode)
  (setq fci-rule-column 80)
  ;; ...and autofill comments at this column
  (set (make-local-variable 'comment-auto-fill-only-comments) t)
  (setq fill-column 80)
  (auto-fill-mode 1)
  (flyspell-prog-mode) 					; Use flyspell to check comments
  (add-to-list 'load-path (concat (getenv "GOPATH")  "/src/github.com/golang/lint/misc/emacs"))
  (require 'golint)
  ;;(require 'go-eldoc)
  ;; Setup autocompletion
  (require 'company)
  (lsp-deferred)
  (setq lsp-enable-snippet nil)
  (setq company-lsp-enable-snippet nil)
  (require 'company-lsp)
  ;;(require 'company-go)
  ;;(set (make-local-variable 'company-backends) '(company-go))
  (company-mode)
  ;;(company-quickhelp-local-mode)				; Include documentation in completions
  ;; Fix company and fci (See https://github.com/company-mode/company-mode/issues/180)
  (defvar-local company-fci-mode-on-p nil)

  (defun company-turn-off-fci (&rest ignore)
	(when (boundp 'fci-mode)
	  (setq company-fci-mode-on-p fci-mode)
	  (when fci-mode (fci-mode -1))))

  (defun company-maybe-turn-on-fci (&rest ignore)
	(when company-fci-mode-on-p (fci-mode 1)))

  (add-hook 'company-completion-started-hook 'company-turn-off-fci)
  (add-hook 'company-completion-finished-hook 'company-maybe-turn-on-fci)
  (add-hook 'company-completion-cancelled-hook 'company-maybe-turn-on-fci)
  )
(add-hook 'go-mode-hook 'my-go-mode-hook)

;; Customize lsp-mode behaviour
(with-eval-after-load 'lsp-mode
  ;; Disable the headerline
  (setq lsp-headerline-breadcrumb-enable nil)
  ;; Prevent lsp-mode from overriding tinyeat-join-lines
  (define-key lsp-mode-map (kbd "C-S-SPC") nil))

;; === Bash ===
(add-hook 'sh-mode-hook 'flycheck-mode)

;; === SAGE ===
(when local-conf-sage-installed
  (sage-shell:define-alias)
  (defun my-sage-hook ()
	(setq sage-shell:completion-ignore-case 't))
  (add-hook 'sage-shell-mode-hook 'my-sage-hook)
  
  ;; Start SAGE in split-screen mode
  (setq SAGE-not-running t)
  (defadvice run-sage (around run-sage-around activate)
	"Switch to split-screen mode when starting SAGE"
	(if SAGE-not-running
		(progn
		  (split-window-right)
		  (other-window 1)
		  ad-do-it
		  (other-window -1)
		  (setq SAGE-not-running nil))
	  ad-do-it))
  
  ;; Auto-jump to SAGE-shell when sending file
  (defun jumpToSageShell ()
	"Jump to the window containing the SAGE shell if it exists"
	(let ((destination (get-buffer-window (get-buffer "*Sage*") 'visible)))
	  (if destination						; Succeeds if destination is non-nil
		  (select-window destination))))
  (advice-add 'sage-shell-edit:send-buffer :after #'jumpToSageShell))


;; === MATLAB ===
(when local-conf-matlab-installed
	(with-eval-after-load 'matlab
	  (setq matlab-shell-command-switches '("-nodesktop -nosplash")))
  
  (defun my-matlab-shell-hook()
	(company-mode)
	(local-set-key (kbd "<up>") 'previous-line)
	(local-set-key (kbd "<down>") 'next-line))
  
  (add-hook 'matlab-shell-mode-hook 'my-matlab-shell-hook)
  
  ;; Execute a line of MATLAB code, and move point to (the vicinity of) the next
  ;; command.
  (defun matlab-execute-line()
	(interactive)
	(let (beg end)
	  (matlab-beginning-of-command)
	  (setq beg (point))
	  (matlab-end-of-command)
	  (setq end (point))
	  (matlab-forward-sexp)
	  (move-end-of-line nil)
	  (matlab-shell-run-region beg end)))
  )
  
;; Execute the current paragraph in MATLAB, and move to the next
(defun matlab-execute-par()
  (interactive)
  (let (beg end)
	(backward-paragraph)
	(setq beg (point))
	(forward-paragraph)
	(setq end (point))
	(matlab-forward-sexp)
	(move-beginning-of-line nil)
	(matlab-shell-run-region beg end)))

(defun my-matlab-mode-hook()
  (company-mode)
  (local-set-key (kbd "<C-return>") 'matlab-execute-line)
  (local-set-key (kbd "C-c C-c") 'matlab-execute-par)) ; Overwrite default prefix-binding
(add-hook 'matlab-mode-hook 'my-matlab-mode-hook)



;; ==== Web-mode ====
;;Load web-mode automatically for php- and html-files
(add-to-list 'auto-mode-alist '("\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
;; Setup company-mode
(add-hook 'web-mode-hook
		  (lambda()
			(set (make-local-variable 'company-backends) '(company-web-html))
			(company-mode)))
;; flyspell setup for web-mode (nicked from http://blog.binchen.org/posts/effective-spell-check-in-emacs.html)
(defun web-mode-flyspell-verify ()
  (let* ((f (get-text-property (- (point) 1) 'face))
         rlt)
    (cond
     ;; Check the words with these font faces, possibly.
     ;; this *blacklist* will be tweaked in next condition
     ((not (memq f '(web-mode-html-attr-value-face
                     web-mode-html-tag-face
                     web-mode-html-attr-name-face
                     web-mode-constant-face
                     web-mode-doctype-face
                     web-mode-keyword-face
                     web-mode-comment-face ;; focus on get html label right
                     web-mode-function-name-face
                     web-mode-variable-name-face
                     web-mode-css-property-name-face
                     web-mode-css-selector-face
                     web-mode-css-color-face
                     web-mode-type-face
                     web-mode-block-control-face)))
      (setq rlt t))
     ;; check attribute value under certain conditions
     ((memq f '(web-mode-html-attr-value-face))
      (save-excursion
        (search-backward-regexp "=['\"]" (line-beginning-position) t)
        (backward-char)
        (setq rlt (string-match "^\\(value\\|class\\|ng[A-Za-z0-9-]*\\)$"
                                (thing-at-point 'symbol)))))
     ;; finalize the blacklist
     (t
      (setq rlt nil)))
    rlt))
(put 'web-mode 'flyspell-mode-predicate 'web-mode-flyspell-verify)



;; ==== R & ESS ====
(when local-conf-r-installed
	(autoload 'R "ess-r-mode")
  (setq ess-directory local-conf-r-start-dir)
  (defun my-r-mode-hook ()
	(company-mode)
	(flyspell-prog-mode)
	(local-set-key (kbd "_") (lambda () (interactive) (ess-insert-assign "S"))))
  (add-hook 'ess-r-mode-hook 'my-r-mode-hook)
  (add-hook 'inferior-ess-r-mode-hook 'my-r-mode-hook)
  
  ;;Start R in split-screen mode
  (setq R-not-running t)
  (defadvice R (around R-around activate)
	"Switch to split-screen mode when starting R"
	(if R-not-running
		(progn
		  (split-window-right)
		  (other-window 1)
		  ad-do-it
		  (defvar chosen-R-wd (ess-get-working-directory))
		  (other-window 1)
		  (cd chosen-R-wd)
		  (makunbound 'chosen-R-wd)
		  (setq R-not-running nil))
	  ad-do-it))
  
  ;;Make .Rhtml-files open in Noweb-mode with html-colouring
  (add-to-list 'auto-mode-alist '("\\.Rhtml\\'" . ess-noweb-mode))
  )

;; ==== Emacs Lisp ====
(add-hook 'emacs-lisp-mode-hook 'company-mode)

;; ==== Markdown ====
(when local-conf-use-markdown
	(defun markdownSetup()
	  (defface markdown-header-face
		`((t (:inherit 'default)))
		"Base face for headers."
		:group 'markdown-faces)
	  (markdown-update-header-faces)
	  )
  (with-eval-after-load 'markdown-mode 'markdownSetup)
  )



;; Local Variables:
;; fill-column: 110
;; comment-column: 40
;; End:
