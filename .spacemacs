
;; -*- mode: emacs-lisp -*-
;; This file is loaded by Spacemacs at startup.
;; It must be stored in your home directory.

(defun dotspacemacs/layers ()
  "Configuration Layers declaration.
You should not put any user code in this function besides modifying the variable
values."
  (setq-default
   ;; Base distribution to use. This is a layer contained in the directory
   ;; `+distribution'. For now available distributions are `spacemacs-base'
   ;; or `spacemacs'. (default 'spacemacs)
   dotspacemacs-distribution 'spacemacs
   ;; Lazy installation of layers (i.e. layers are installed only when a file
   ;; with a supported type is opened). Possible values are `all', `unused'
   ;; and `nil'. `unused' will lazy install only unused layers (i.e. layers
   ;; not listed in variable `dotspacemacs-configuration-layers'), `all' will
   ;; lazy install any layer that support lazy installation even the layers
   ;; listed in `dotspacemacs-configuration-layers'. `nil' disable the lazy
   ;; installation feature and you have to explicitly list a layer in the
   ;; variable `dotspacemacs-configuration-layers' to install it.
   ;; (default 'unused)
   dotspacemacs-enable-lazy-installation 'unused
   ;; If non-nil then Spacemacs will ask for confirmation before installing
   ;; a layer lazily. (default t)
   dotspacemacs-ask-for-lazy-installation t
   ;; If non-nil layers with lazy install support are lazy installed.
   ;; List of additional paths where to look for configuration layers.
   ;; Paths must have a trailing slash (i.e. `~/.mycontribs/')
   dotspacemacs-configuration-layer-path '()
   ;; List of configuration layers to load.
   dotspacemacs-configuration-layers
   '(
     themes-megapack
     typescript
     clojure
     emoji
     yaml
     (colors :variables colors-enable-nyan-cat-progress-bar t)
     javascript
     osx
     html
     react
     ;; ----------------------------------------------------------------
     ;; Example of useful layers you may want to use right away.
     ;; Uncomment some layer names and press <SPC f e R> (Vim style) or
     ;; <M-m f e R> (Emacs style) to install them.
     ;; ----------------------------------------------------------------
     helm
     (auto-completion :variables auto-completion-enable-help-tooltip t)
     better-defaults
     emacs-lisp
     git
     markdown
     ;; org
     (shell :variables
            shell-default-height 30
            shell-default-position 'bottom)
     spell-checking
     syntax-checking
     version-control
     )
   ;; PASTING INTO MINI BUFFER- use CMD-y

   ;; List of additional packages that will be installed without being
   ;; wrapped in a layer. If you need some configuration for these
   ;; packages, then consider creating a layer. You can also put the
   ;; configuration in `dotspacemacs/user-config'.
   dotspacemacs-additional-packages
   '(prettier-js writeroom-mode kaolin-themes)
   ;; A list of packages that cannot be updated.

   dotspacemacs-frozen-packages '()
   ;; A list of packages that will not be installed and loaded.
   dotspacemacs-excluded-packages '(
  tronesque-theme, firebelly-theme,
  niflheim-theme, pastels-on-dark-theme, zonokai-theme)
   ;; Defines the behaviour of Spacemacs when installing packages.
   ;; Possible values are `used-only', `used-but-keep-unused' and `all'.
   ;; `used-only' installs only explicitly used packages and uninstall any
   ;; unused packages as well as their unused dependencies.
   ;; `used-but-keep-unused' installs only the used packages but won't uninstall
   ;; them if they become unused. `all' installs *all* packages supported by
   ;; Spacemacs and never uninstall them. (default is `used-only')
   dotspacemacs-install-packages 'used-only))

(defun dotspacemacs/init ()
  "Initialization function.
This function is called at the very startup of Spacemacs initialization
before layers configuration.
You should not put any user code in there besides modifying the variable
values."
  ;; This setq-default sexp is an exhaustive list of all the supported
  ;; spacemacs settings.
  (setq-default
   ;; If non nil ELPA repositories are contacted via HTTPS whenever it's
   ;; possible. Set it to nil if you have no way to use HTTPS in your
   ;; environment, otherwise it is strongly recommended to let it set to t.
   ;; This variable has no effect if Emacs is launched with the parameter
   ;; `--insecure' which forces the value of this variable to nil.
   ;; (default t)
   dotspacemacs-elpa-https t
   ;; Maximum allowed time in seconds to contact an ELPA repository.
   dotspacemacs-elpa-timeout 5
   ;; If non nil then spacemacs will check for updates at startup
   ;; when the current branch is not `develop'. Note that checking for
   ;; new versions works via git commands, thus it calls GitHub services
   ;; whenever you start Emacs. (default nil)
   dotspacemacs-check-for-update nil
   ;; If non-nil, a form that evaluates to a package directory. For example, to
   ;; use different package directories for different Emacs versions, set this
   ;; to `emacs-version'.
   dotspacemacs-elpa-subdirectory nil
   ;; One of `vim', `emacs' or `hybrid'.
   ;; `hybrid' is like `vim' except that `insert state' is replaced by the
   ;; `hybrid state' with `emacs' key bindings. The value can also be a list
   ;; with `:variables' keyword (similar to layers). Check the editing styles
   ;; section of the documentation for details on available variables.
   ;; (default 'vim)
   dotspacemacs-editing-style 'vim
   ;; If non nil output loading progress in `*Messages*' buffer. (default nil)
   dotspacemacs-verbose-loading nil
   ;; Specify the startup banner. Default value is `official', it displays
   ;; the official spacemacs logo. An integer value is the index of text
   ;; banner, `random' chooses a random text banner in `core/banners'
   ;; directory. A string value must be a path to an image format supported
   ;; by your Emacs build.
   ;; If the value is nil then no banner is displayed. (default 'official)
   dotspacemacs-startup-banner 'official
   ;; List of items to show in startup buffer or an association list of
   ;; the form `(list-type . list-size)`. If nil then it is disabled.
   ;; Possible values for list-type are:
   ;; `recents' `bookmarks' `projects' `agenda' `todos'."
   ;; List sizes may be nil, in which case
   ;; `spacemacs-buffer-startup-lists-length' takes effect.
   dotspacemacs-startup-lists '((recents . 5)
                                (projects . 7))
   ;; True if the home buffer should respond to resize events.
   dotspacemacs-startup-buffer-responsive t
   ;; Default major mode of the scratch buffer (default `text-mode')
   dotspacemacs-scratch-mode 'text-mode
   ;; List of themes, the first of the list is loaded when spacemacs starts.
   ;; Press <SPC> T n to cycle to the next theme in the list (works great
   ;; with 2 themes variants, one dark and one light)
   dotspacemacs-themes '(
                         kaolin-fusion
                         twilight-bright
                         grandshell
                         spacemacs-dark
                         apropospriate-dark
                         zenburn
                         toxi
                         alect-dark
                         alect-dark-alt
                         spacemacs-light)
   ;; If non nil the cursor color matches the state color in GUI Emacs.
   dotspacemacs-colorize-cursor-according-to-state t
   ;; Default font, or prioritized list of fonts. `powerline-scale' allows to
   ;; quickly tweak the mode-line size to make separators look not too crappy.
   dotspacemacs-default-font '("Source Code Pro"
                               :size 12
                               :weight normal
                               :width normal
                               :powerline-scale 1.1)
   ;; The leader key
   dotspacemacs-leader-key "SPC"
   ;; The key used for Emacs commands (M-x) (after pressing on the leader key).
   ;; (default "SPC")
   dotspacemacs-emacs-command-key "SPC"
   ;; The key used for Vim Ex commands (default ":")
   dotspacemacs-ex-command-key ":"
   ;; The leader key accessible in `emacs state' and `insert state'
   ;; (default "M-m")
   dotspacemacs-emacs-leader-key "M-m"
   ;; Major mode leader key is a shortcut key which is the equivalent of
   ;; pressing `<leader> m`. Set it to `nil` to disable it. (default ",")
   dotspacemacs-major-mode-leader-key ","
   ;; Major mode leader key accessible in `emacs state' and `insert state'.
   ;; (default "C-M-m")
   dotspacemacs-major-mode-emacs-leader-key "C-M-m"
   ;; These variables control whether separate commands are bound in the GUI to
   ;; the key pairs C-i, TAB and C-m, RET.
   ;; Setting it to a non-nil value, allows for separate commands under <C-i>
   ;; and TAB or <C-m> and RET.
   ;; In the terminal, these pairs are generally indistinguishable, so this only
   ;; works in the GUI. (default nil)
   dotspacemacs-distinguish-gui-tab nil
   ;; If non nil `Y' is remapped to `y$' in Evil states. (default nil)
   dotspacemacs-remap-Y-to-y$ nil
   ;; If non-nil, the shift mappings `<' and `>' retain visual state if used
   ;; there. (default t)
   dotspacemacs-retain-visual-state-on-shift t
   ;; If non-nil, J and K move lines up and down when in visual mode.
   ;; (default nil)
   dotspacemacs-visual-line-move-text nil
   ;; If non nil, inverse the meaning of `g' in `:substitute' Evil ex-command.
   ;; (default nil)
   dotspacemacs-ex-substitute-global nil
   ;; Name of the default layout (default "Default")
   dotspacemacs-default-layout-name "Default"
   ;; If non nil the default layout name is displayed in the mode-line.
   ;; (default nil)
   dotspacemacs-display-default-layout nil
   ;; If non nil then the last auto saved layouts are resume automatically upon
   ;; start. (default nil)
   dotspacemacs-auto-resume-layouts nil
   ;; Size (in MB) above which spacemacs will prompt to open the large file
   ;; literally to avoid performance issues. Opening a file literally means that
   ;; no major mode or minor modes are active. (default is 1)
   dotspacemacs-large-file-size 1
   ;; Location where to auto-save files. Possible values are `original' to
   ;; auto-save the file in-place, `cache' to auto-save the file to another
   ;; file stored in the cache directory and `nil' to disable auto-saving.
   ;; (default 'cache)
   dotspacemacs-auto-save-file-location 'cache
   ;; Maximum number of rollback slots to keep in the cache. (default 5)
   dotspacemacs-max-rollback-slots 5
   ;; If non nil, `helm' will try to minimize the space it uses. (default nil)
   dotspacemacs-helm-resize nil
   ;; if non nil, the helm header is hidden when there is only one source.
   ;; (default nil)
   dotspacemacs-helm-no-header nil
   ;; define the position to display `helm', options are `bottom', `top',
   ;; `left', or `right'. (default 'bottom)
   dotspacemacs-helm-position 'bottom
   ;; Controls fuzzy matching in helm. If set to `always', force fuzzy matching
   ;; in all non-asynchronous sources. If set to `source', preserve individual
   ;; source settings. Else, disable fuzzy matching in all sources.
   ;; (default 'always)
   dotspacemacs-helm-use-fuzzy 'always
   ;; If non nil the paste micro-state is enabled. When enabled pressing `p`
   ;; several times cycle between the kill ring content. (default nil)
   dotspacemacs-enable-paste-transient-state nil
   ;; Which-key delay in seconds. The which-key buffer is the popup listing
   ;; the commands bound to the current keystroke sequence. (default 0.4)
   dotspacemacs-which-key-delay 0.2
   ;; Which-key frame position. Possible values are `right', `bottom' and
   ;; `right-then-bottom'. right-then-bottom tries to display the frame to the
   ;; right; if there is insufficient space it displays it at the bottom.
   ;; (default 'bottom)
   dotspacemacs-which-key-position 'bottom
   ;; If non nil a progress bar is displayed when spacemacs is loading. This
   ;; may increase the boot time on some systems and emacs builds, set it to
   ;; nil to boost the loading time. (default t)
   dotspacemacs-loading-progress-bar t
   ;; If non nil the frame is fullscreen when Emacs starts up. (default nil)
   ;; (Emacs 24.4+ only)
   dotspacemacs-fullscreen-at-startup nil
   ;; If non nil `spacemacs/toggle-fullscreen' will not use native fullscreen.
   ;; Use to disable fullscreen animations in OSX. (default nil)
   dotspacemacs-fullscreen-use-non-native nil
   ;; If non nil the frame is maximized when Emacs starts up.
   ;; Takes effect only if `dotspacemacs-fullscreen-at-startup' is nil.
   ;; (default nil) (Emacs 24.4+ only)
   dotspacemacs-maximized-at-startup nil
   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's active or selected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-active-transparency 90
   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's inactive or deselected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-inactive-transparency 90
   ;; If non nil show the titles of transient states. (default t)
   dotspacemacs-show-transient-state-title t
   ;; If non nil show the color guide hint for transient state keys. (default t)
   dotspacemacs-show-transient-state-color-guide t
   ;; If non nil unicode symbols are displayed in the mode line. (default t)
   dotspacemacs-mode-line-unicode-symbols t
   ;; If non nil smooth scrolling (native-scrolling) is enabled. Smooth
   ;; scrolling overrides the default behavior of Emacs which recenters point
   ;; when it reaches the top or bottom of the screen. (default t)
   dotspacemacs-smooth-scrolling t
   ;; If non nil line numbers are turned on in all `prog-mode' and `text-mode'
   ;; derivatives. If set to `relative', also turns on relative line numbers.
   ;; (default nil)
   dotspacemacs-line-numbers nil
   ;; Code folding method. Possible values are `evil' and `origami'.
   ;; (default 'evil)
   dotspacemacs-folding-method 'evil
   ;; If non-nil smartparens-strict-mode will be enabled in programming modes.
   ;; (default nil)
   dotspacemacs-smartparens-strict-mode nil
   ;; If non-nil pressing the closing parenthesis `)' key in insert mode passes
   ;; over any automatically added closing parenthesis, bracket, quote, etc…
   ;; This can be temporary disabled by pressing `C-q' before `)'. (default nil)
   dotspacemacs-smart-closing-parenthesis nil
   ;; Select a scope to highlight delimiters. Possible values are `any',
   ;; `current', `all' or `nil'. Default is `all' (highlight any scope and
   ;; emphasis the current one). (default 'all)
   dotspacemacs-highlight-delimiters 'all
   ;; If non nil, advise quit functions to keep server open when quitting.
   ;; (default nil)
   dotspacemacs-persistent-server nil
   ;; List of search tool executable names. Spacemacs uses the first installed
   ;; tool of the list. Supported tools are `ag', `pt', `ack' and `grep'.
   ;; (default '("ag" "pt" "ack" "grep"))
   dotspacemacs-search-tools '("ag" "pt" "ack" "grep")
   ;; The default package repository used if no explicit repository has been
   ;; specified with an installed package.
   ;; Not used for now. (default nil)
   dotspacemacs-default-package-repository nil
   ;; Delete whitespace while saving buffer. Possible values are `all'
   ;; to aggressively delete empty line and long sequences of whitespace,
   ;; `trailing' to delete only the whitespace at end of lines, `changed'to

   ))

(defun dotspacemacs/user-init ()
  "Initialization function for user code.
It is called immediately after `dotspacemacs/init', before layer configuration
executes.
 This function is mostly useful for variables that need to be set
before packages are loaded. If you are unsure, you should try in setting them in
`dotspacemacs/user-config' first."
  )

(defun dotspacemacs/user-config ()
                                        ;  "Configuration function for user code.
                                        ;This function is called at the very end of Spacemacs initialization after
                                        ;layers configuration.
                                        ;This is the place where most of your configurations should be done. Unless it is
                                        ;explicitly specified that a variable should be set before a package is loaded,
                                        ;you should place your code here."

  ;; (spaceline-define-segment buffer-id
  ;;   (if (buffer-file-name)
  ;;       (abbreviate-file-name (buffer-file-name))
  ;;     (powerline-buffer-id)))
  (setq prettier-js-args '(
                           "--trailing-comma" "all"
                           "--single-quote" "true"
                           ))
  (defun kill-other-buffers ()
    "Kill all buffers but the current one.
Don't mess with special buffers."
    (interactive)
    (dolist (buffer (buffer-list))
      (unless (or (eql buffer (current-buffer)) (not (buffer-file-name buffer)))
        (kill-buffer buffer))))
  ;; To fix the autocomplete when using react layer go to /.emacs.d/layers/+lang/html/funcs.el
  ;; and change company-minimum-prefix-length to 2

  ;; (setq spaceline-highlight-face-func 'spaceline-highlight-face-evil-state)
  ;; (set-background-color "grey16")
  ;; (set-face-attribute 'spaceline-evil-normal nil :foreground "black")
  (setq-default js2-basic-offset 2)
  (setq-default js-indent-level 2)
  (defun my-web-mode-hook ()
    (setq web-mode-markup-indent-offset 2)
    (setq web-mode-css-indent-offset 1)
    (setq css-indent-offset 2)
    (setq web-mode-code-indent-offset 2)
    (setq web-mode-indent-style 2)
    )
  (add-hook 'web-mode-hook  'my-web-mode-hook)

  (setq browse-url-browser-function 'browse-url-default-macosx-browser)
  (add-hook 'js2-mode-hook 'prettier-js-mode)
  (add-hook 'web-mode-hook 'prettier-js-mode)
  (add-hook 'tide-mode-hook 'prettier-js-mode)

  (defun enable-minor-mode (my-pair)
    "Enable minor mode if filename match the regexp.  MY-PAIR is a cons cell (regexp . minor-mode)."
    (if (buffer-file-name)
        (if (string-match (car my-pair) buffer-file-name)
            (funcall (cdr my-pair)))))

  (add-hook 'web-mode-hook #'(lambda ()
                               (enable-minor-mode
                                '("\\.jsx?\\'" . prettier-js-mode))))

  ;; KEY BINDINGS

  (spacemacs/set-leader-keys "ab" 'browse-url-default-macosx-browser)
  (spacemacs/set-leader-keys "sr" 'find-render-function)
  (spacemacs/set-leader-keys "wg" 'golden-ratio)
  (spacemacs/set-leader-keys "asM" 'multi-term)
  (spacemacs/set-leader-keys "wa" 'delete-other-windows)
  (spacemacs/set-leader-keys "wz" 'minimize-window)
  (define-key evil-normal-state-map (kbd "<escape>") 'evil-search-highlight-persist-remove-all)
  ;; (define-key evil-normal-state-map (kbd "<tab>")) 'sp-up-sexp)
  (spacemacs/set-leader-keys "ww" 'writeroom-mode)
  (spacemacs/set-leader-keys "tmi" 'spaceline-toggle-buffer-id)

  ;; ********************* EDIFF use BOTH *********************

  (defun ediff-copy-both-to-C ()
    (interactive)
    (ediff-copy-diff ediff-current-difference nil 'C nil
                     (concat
                      (ediff-get-region-contents ediff-current-difference 'A ediff-control-buffer)
                      (ediff-get-region-contents ediff-current-difference 'B ediff-control-buffer))))
  (defun add-d-to-ediff-mode-map () (define-key ediff-mode-map "d" 'ediff-copy-both-to-C))
  (add-hook 'ediff-keymap-setup-hook 'add-d-to-ediff-mode-map)

  ;; ************************************************************************************



  (setq mac-right-option-modifier nil)
  (setq mac-command-modifier 'control)
  (setq-default dotspacemacs-themes '(list-themes-here))

  ;;Appearance
  ;; (custom-set-faces
  ;;  ;; ((((((()))))))
  ;;  ;; custom-set-faces was added by Custom.
  ;;  ;; If you edit it by hand, you could mess it up, so be careful.
  ;;  ;; Your init file should contain only one such instance.
  ;;  ;; If there is more than one, they won't work right.
  ;;  '(rainbow-delimiters-depth-1-face ((t (:foreground "cyan"))))
  ;;  '(rainbow-delimiters-depth-2-face ((t (:foreground "deep sky blue"))))
  ;;  '(rainbow-delimiters-depth-3-face ((t (:foreground "aquamarine"))))
  ;;  '(rainbow-delimiters-depth-4-face ((t (:foreground "green"))))
  ;;  '(rainbow-delimiters-depth-5-face ((t (:foreground "yellow"))))
  ;;  '(rainbow-delimiters-depth-6-face ((t (:foreground "orange"))))
  ;;  '(rainbow-delimiters-depth-7-face ((t (:foreground "red")))))
  (rainbow-delimiters-mode 0)
  (set-fontset-font t 'unicode "Apple Color Emoji" nil 'prepend)
  (set-cursor-color "pink")
  ;;                                         ;spaceline customisations
  (setq powerline-default-separator 'utf-8)
  (spaceline-toggle-buffer-size-off)
  (spaceline-toggle-buffer-position-off)
  (spaceline-toggle-minor-modes-off)
  (spaceline-toggle-major-mode-on)
  (spaceline-toggle-version-control-off)
  (spaceline-toggle-buffer-encoding-abbrev-off)
  (spaceline-toggle-point-position-off)
  (spaceline-toggle-buffer-encoding-off)
  ;; (spaceline-toggle-buffer-id-off)
  (spaceline-toggle-major-mode-off)
  (spaceline-toggle-nyan-cat-off)
  (setq truncate-lines 't)
  ;; (setq rainbow-mode 't)
  (setq truncate-lines 't)

  (global-aggressive-indent-mode 0)
  ;; (add-to-list 'aggressive-indent-excluded-modes 'html-mode)
  (setq neo-theme 'ascii)

  (push '("\\.js\\'" . react-mode) auto-mode-alist)
  ;; (setq powerline-default-separator 'alternate)
  ;; (nyan-minimum-window-width 800);;
  (setq default js2-mode)
  (add-hook 'dired-mode-hook
            (lambda () (dired-hide-details-mode 1)))
                                        ;Hide some files
  (setq dired-omit-files "^\\..*$\\|^\\.\\.$");;
  (setq dired-omit-files "^\\.git$\\|\\.DS_Store$")
  (add-hook 'dired-mode-hook (lambda () (dired-omit-mode 1)))
  ;; (setq glob)

  ;; (setq-default mode-line-format nil)
  (setq dired-hide-details-mode t)
  ;; (define-key window-numbering-keymap "\M-0" nil)
  ;; (define-key window-numbering-keymap "\M-1" nil)
  ;; (define-key window-numbering-keymap "\M-2" nil)
                                        ;Allow Alt-3 to be a #

  )
;; Do not write anything past this comment. This is where Emacs will
;; auto-generate custom variable definitions.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default bold shadow italic underline bold bold-italic bold])
 '(avy-all-windows nil t)
 '(avy-background nil t)
 '(beacon-color "#ec4780")
 '(custom-safe-themes
   (quote
    ("a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e" default)))
 '(diary-entry-marker (quote font-lock-variable-name-face))
 '(emms-mode-line-icon-image-cache
   (quote
    (image :type xpm :ascent center :data "/* XPM */
static char *note[] = {
/* width height num_colors chars_per_pixel */
\"    10   11        2            1\",
/* colors */
\". c #1fb3b3\",
\"# c None s None\",
/* pixels */
\"###...####\",
\"###.#...##\",
\"###.###...\",
\"###.#####.\",
\"###.#####.\",
\"#...#####.\",
\"....#####.\",
\"#..######.\",
\"#######...\",
\"######....\",
\"#######..#\" };")))
 '(evil-emacs-state-cursor (quote ("#E57373" hbar)) t)
 '(evil-insert-state-cursor (quote ("#E57373" bar)) t)
 '(evil-normal-state-cursor (quote ("#FFEE58" box)) t)
 '(evil-visual-state-cursor (quote ("#C5E1A5" box)) t)
 '(evil-want-Y-yank-to-eol nil)
 '(fci-rule-color "#383838" t)
 '(gnus-logo-colors (quote ("#2fdbde" "#c0c0c0")) t)
 '(gnus-mode-line-image-cache
   (quote
    (image :type xpm :ascent center :data "/* XPM */
static char *gnus-pointer[] = {
/* width height num_colors chars_per_pixel */
\"    18    13        2            1\",
/* colors */
\". c #1fb3b3\",
\"# c None s None\",
/* pixels */
\"##################\",
\"######..##..######\",
\"#####........#####\",
\"#.##.##..##...####\",
\"#...####.###...##.\",
\"#..###.######.....\",
\"#####.########...#\",
\"###########.######\",
\"####.###.#..######\",
\"######..###.######\",
\"###....####.######\",
\"###..######.######\",
\"###########.######\" };")) t)
 '(highlight-indent-guides-auto-enabled nil)
 '(highlight-symbol-colors
   (quote
    ("#FFEE58" "#C5E1A5" "#80DEEA" "#64B5F6" "#E1BEE7" "#FFCC80")))
 '(highlight-symbol-foreground-color "#E0E0E0")
 '(highlight-tail-colors (quote (("#ec4780" . 0) ("#424242" . 100))))
 '(ispell-highlight-face (quote flyspell-incorrect))
 '(nrepl-message-colors
   (quote
    ("#CC9393" "#DFAF8F" "#F0DFAF" "#7F9F7F" "#BFEBBF" "#93E0E3" "#94BFF3" "#DC8CC3")))
 '(ns-command-modifier (quote control))
 '(package-selected-packages
   (quote
    (kaolin-fusion-theme-theme kaolin-fusion-theme ali-14-theme smart-tabs-mode graphql smart-mode-line smart-mode-line-powerline-theme kaolin-themes elfeed-goodies ace-jump-mode elfeed-org elfeed-web elfeed geeknote engine-mode spotify helm-spotify-plus multi twittering-mode wakatime-mode evil-cleverparens evil-commentary evil-snipe ranger ansible ansible-doc company-ansible jinja2-mode edit-server gmail-message-mode ham-mode html-to-markdown flymd command-log-mode dash-at-point counsel-dash deft docker docker-tramp dockerfile-mode fasd flycheck-ledger ledger-mode osx-location rase sunshine theme-changer imenu-list nginx-mode pandoc-mode ox-pandoc prodigy puppet-mode rebox2 company-restclient know-your-http-well ob-http ob-restclient restclient-helm restclient salt-mode mmm-jinja2 spray systemd terraform-mode hcl-mode vagrant vagrant-tramp company-ycmd flycheck-ycmd ycmd helm-cscope xcscope ggtags helm-gtags bracketed-paste origami hl-anything gist github-browse-file github-clone github-search magit-gh-pulls gh marshal logito pcache treepy p4 floobits company-nixos-options helm-nixos-options nix-mode nixos-options nlinum-relative nlinum adoc-mode markup-faces nasm-mode x86-lookup ahk-mode org-ref pdf-tools key-chord tablist helm-bibtex parsebib biblio biblio-core disaster clang-format cmake-mode company-c-headers srefactor stickyfunc-enhance common-lisp-snippets slime-company slime omnisharp shut-up csharp-mode csv-mode company-dcd d-mode flycheck-dmd-dub alchemist flycheck-mix elixir-mode flycheck-credo ob-elixir elm-mode flycheck-elm erlang ess-R-data-view ess-smart-equals ess arduino-mode julia-mode matlab-mode qml-mode scad-mode stan-mode thrift faust-mode fsharp-mode company-go flycheck-gometalinter go-eldoc go-guru go-mode graphviz-dot-mode cmm-mode company-cabal company-ghci company-ghc flycheck-haskell ghc haskell-snippets helm-hoogle hindent hlint-refactor intero haskell-mode idris-mode prop-menu ein request-deferred company-emacs-eclim eclim auctex-latexmk company-auctex auctex typo lua-mode flycheck-nim nim-mode flycheck-nimsuggest commenter epc ctable concurrent deferred merlin ocp-indent tuareg caml utop drupal-mode php-auto-yasnippets php-extras php-mode phpcbf phpunit plantuml-mode psci purescript-mode psc-ide company-anaconda anaconda-mode cython-mode helm-pydoc hy-mode live-py-mode pip-requirements py-isort pyenv-mode pythonic pytest pyvenv yapfify racket-mode faceup bundler chruby enh-ruby-mode minitest rbenv robe rspec-mode rubocop ruby-test-mode ruby-tools rvm cargo racer flycheck-rust rust-mode toml-mode ensime noflet scala-mode sbt-mode geiser glsl-mode company-glsl company-shell fish-mode insert-shebang ob-sml sml-mode sql-indent swift-mode vimrc-mode dactyl-mode powershell pyim pyim-basedict chinese-wbim fcitx find-by-pinyin-dired ace-pinyin pinyinlib pangu-spacing youdao-dictionary names chinese-word-at-point 2048-game pacmacs sudoku typit mmt selectric-mode xkcd pony-mode feature-mode projectile-rails rake inf-ruby mu4e-alert mu4e-maildirs-extension ibuffer-projectile gnuplot htmlize org-download org-mime org-pomodoro org-present org-projectile org-category-capture ox-twbs ox-gfm ox-reveal smex counsel-projectile counsel swiper ivy-hydra wgrep flyspell-correct-ivy ivy flyspell-correct-popup flyspell-popup erc-terminal-notifier erc-gitter erc-hl-nicks erc-image erc-social-graph erc-view-log erc-yt jabber fsm rcirc-color rcirc-notify slack emojify alert circe oauth2 websocket log4e gntp ht sesman white-sand-theme rebecca-theme exotica-theme ghub let-alist visual-fill-column writeroom-mode prettier-js zonokai-theme zenburn-theme zen-and-art-theme underwater-theme ujelly-theme twilight-theme twilight-bright-theme twilight-anti-bright-theme tao-theme tangotango-theme tango-plus-theme tango-2-theme sunny-day-theme sublime-themes subatomic256-theme subatomic-theme spacegray-theme soothe-theme solarized-theme soft-stone-theme soft-morning-theme soft-charcoal-theme smyx-theme seti-theme reverse-theme railscasts-theme purple-haze-theme professional-theme planet-theme phoenix-dark-pink-theme phoenix-dark-mono-theme pastels-on-dark-theme organic-green-theme omtose-phellack-theme oldlace-theme occidental-theme obsidian-theme noctilux-theme niflheim-theme naquadah-theme mustang-theme monokai-theme monochrome-theme molokai-theme moe-theme minimal-theme material-theme majapahit-theme madhat2r-theme lush-theme light-soap-theme jbeans-theme jazz-theme ir-black-theme inkpot-theme heroku-theme hemisu-theme hc-zenburn-theme gruvbox-theme gruber-darker-theme grandshell-theme gotham-theme gandalf-theme flatui-theme flatland-theme firebelly-theme farmhouse-theme espresso-theme dracula-theme django-theme darktooth-theme autothemer darkokai-theme darkmine-theme darkburn-theme dakrone-theme cyberpunk-theme color-theme-sanityinc-tomorrow color-theme-sanityinc-solarized clues-theme cherry-blossom-theme busybee-theme bubbleberry-theme birds-of-paradise-plus-theme badwolf-theme anti-zenburn-theme ample-zen-theme ample-theme afternoon-theme tide typescript-mode emoji-cheat-sheet-plus company-emoji winum unfill fuzzy clojure-snippets clj-refactor inflections edn paredit peg cider-eval-sexp-fu cider seq queue clojure-mode helm-dash apropospriate-theme toxi-theme tronesque-theme alect-themes react-snippets yatemplate yaml-mode rainbow-mode rainbow-identifiers color-identifiers-mode company-quickhelp reveal-in-osx-finder pbcopy osx-trash osx-dictionary launchctl vmd-mode xterm-color web-mode tagedit smeargle slim-mode shell-pop scss-mode sass-mode pug-mode orgit org mwim multi-term mmm-mode markdown-toc markdown-mode magit-gitflow less-css-mode helm-gitignore helm-css-scss helm-company helm-c-yasnippet haml-mode gitignore-mode gitconfig-mode gitattributes-mode git-timemachine git-messenger git-link git-gutter-fringe+ git-gutter-fringe fringe-helper git-gutter+ git-gutter gh-md flyspell-correct-helm flyspell-correct flycheck-pos-tip pos-tip flycheck evil-magit magit magit-popup git-commit with-editor eshell-z eshell-prompt-extras esh-help emmet-mode diff-hl company-web web-completion-data company-tern dash-functional company-statistics company auto-yasnippet auto-dictionary ac-ispell auto-complete web-beautify tern livid-mode skewer-mode simple-httpd json-mode json-snatcher json-reformat js2-refactor yasnippet multiple-cursors js2-mode js-doc coffee-mode ws-butler window-numbering which-key volatile-highlights vi-tilde-fringe uuidgen use-package toc-org spaceline powerline restart-emacs request rainbow-delimiters popwin persp-mode pcre2el paradox spinner org-plus-contrib org-bullets open-junk-file neotree move-text macrostep lorem-ipsum linum-relative link-hint info+ indent-guide ido-vertical-mode hydra hungry-delete hl-todo highlight-parentheses highlight-numbers parent-mode highlight-indentation hide-comnt help-fns+ helm-themes helm-swoop helm-projectile helm-mode-manager helm-make projectile pkg-info epl helm-flx helm-descbinds helm-ag google-translate golden-ratio flx-ido flx fill-column-indicator fancy-battery eyebrowse expand-region exec-path-from-shell evil-visualstar evil-visual-mark-mode evil-unimpaired evil-tutor evil-surround evil-search-highlight-persist evil-numbers evil-nerd-commenter evil-mc evil-matchit evil-lisp-state smartparens evil-indent-plus evil-iedit-state iedit evil-exchange evil-escape evil-ediff evil-args evil-anzu anzu evil goto-chg undo-tree eval-sexp-fu highlight elisp-slime-nav dumb-jump f s diminish define-word column-enforce-mode clean-aindent-mode bind-map bind-key auto-highlight-symbol auto-compile packed dash aggressive-indent adaptive-wrap ace-window ace-link ace-jump-helm-line helm avy helm-core popup async quelpa package-build spacemacs-theme)))
 '(pdf-view-midnight-colors (quote ("#DCDCCC" . "#383838")))
 '(pos-tip-background-color nil)
 '(pos-tip-foreground-color "#9E9E9E")
 '(spaceline-helm-mode t)
 '(spaceline-info-mode t)
 '(standard-indent 2)
 '(tabbar-background-color "#353535")
 '(truncate-lines t)
 '(vc-annotate-background "#2B2B2B")
 '(vc-annotate-color-map
   (quote
    ((20 . "#BC8383")
     (40 . "#CC9393")
     (60 . "#DFAF8F")
     (80 . "#D0BF8F")
     (100 . "#E0CF9F")
     (120 . "#F0DFAF")
     (140 . "#5F7F5F")
     (160 . "#7F9F7F")
     (180 . "#8FB28F")
     (200 . "#9FC59F")
     (220 . "#AFD8AF")
     (240 . "#BFEBBF")
     (260 . "#93E0E3")
     (280 . "#6CA0A3")
     (300 . "#7CB8BB")
     (320 . "#8CD0D3")
     (340 . "#94BFF3")
     (360 . "#DC8CC3"))))
 '(vc-annotate-very-old-color "#DC8CC3"))
;; (custom-set-faces
;; custom-set-faces was added by Custom.
;; If you edit it by hand, you could mess it up, so be careful.
;; Your init file should contain only one such instance.
;; If there is more than one, they won't work right.
;; '(rainbow-delimiters-depth-1-face ((t (:foreground "magenta"))))
;; '(rainbow-delimiters-depth-2-face ((t (:foreground "deep sky blue"))))
;; '(rainbow-delimiters-depth-3-face ((t (:foreground "aquamarine"))))
;; '(rainbow-delimiters-depth-4-face ((t (:foreground "green"))))
;; '(rainbow-delimiters-depth-5-face ((t (:foreground "yellow"))))
;; '(rainbow-delimiters-depth-6-face ((t (:foreground "orange"))))
;; '(rainbow-delimiters-depth-7-face ((t (:foreground "red")))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(spaceline-evil-normal ((t (:background "seashell" :foreground "black"))))
 '(spaceline-highlight-face ((t (:background: "cyan" :foreground "red" :inherit (quote mode-line))))))
