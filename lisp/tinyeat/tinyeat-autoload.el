;; Created from tinyeat.el and its install-tinyeat-default-bindings

(autoload 'tinyeat-kill-line                   "tinyeat" "" t)
(autoload 'tinyeat-kill-line-backward          "tinyeat" "" t)
(autoload 'tinyeat-kill-buffer-lines-point-max "tinyeat" "" t)
(autoload 'tinyeat-kill-buffer-lines-point-min "tinyeat" "" t)
(autoload 'tinyeat-forward-preserve            "tinyeat" "" t)
(autoload 'tinyeat-backward-preserve           "tinyeat" "" t)
(autoload 'tinyeat-delete-paragraph            "tinyeat" "" t)
(autoload 'tinyeat-zap-line                    "tinyeat" "" t)
(autoload 'tinyeat-join-lines                  "tinyeat" "" t)

;; was `kill-sentence'
(global-set-key "\M-k"                'tinyeat-kill-line-backward)

;; C-M-k: Works both in Windowed and non-Windowed Emacs. Unfortunately in
;; windowed Linux/Gnome C-M-k runs "Lock Screen", we define C-S-k
;; as a backup.

(global-set-key "\C-\M-k"             'tinyeat-zap-line) ; kill-sexp
(global-set-key (kbd "C-S-k")         'tinyeat-zap-line)

(global-set-key (kbd "C-S-y")         'tinyeat-yank-overwrite)
(global-set-key (kbd "C-S-SPC")	'tinyeat-join-lines)

;;  Alt-backspace
(global-set-key (kbd "<M-backspace>") 'tinyeat-backward-preserve)

;;  was `kill-word'
(global-set-key "\M-d"                'tinyeat-forward-preserve)
(global-set-key (kbd "<C-backspace>") 'tinyeat-forward-preserve)
;; secondary backup
(global-set-key (kbd "<C-delete>")    'tinyeat-forward-preserve)
(global-set-key (kbd "<C-deletechar>")'tinyeat-forward-preserve)
(global-set-key (kbd "<M-delete>")    'tinyeat-forward-preserve)

(global-set-key (kbd "<S-backspace>") 'tinyeat-delete-whole-word)
(global-set-key (kbd "<S-delete>")    'tinyeat-delete-whole-word)
;; Was just-one-space
(global-set-key "\M-\ "               'tinyeat-delete-whole-word)

;;  Was `down-list'
(global-set-key "\C-\M-d"               'tinyeat-delete-paragraph)
(global-set-key (kbd "<C-S-backspace>") 'tinyeat-delete-paragraph)
(global-set-key (kbd "<C-S-delete>")    'tinyeat-delete-paragraph)
