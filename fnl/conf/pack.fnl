(import-macros {: pack : use-package! : rock : rock! : unpack!} :conf.macros)

;;; Emacs' use-package is not a package manager! Although use-package does have the useful capability to interface with package managers, its mainly for configuring and loading packages.
;;; Still, as packer.nvim is use-package inspired, lets just think of it as a vim-y version of straight-use-package for now :)

;;; The syntax is simple:
;;; (use-package! <repo-name> {:keyword :arg ...} ...)
;;; Please refer to :h packer.nvim for more information. I trust the examples below are enough to get you started.

;;; One catch to the use-package! macro: It doesn't obey whats around it, whatever package declaration you create gets directly added to the global conf/pack list. To work around this, we can add aniseed/hotpot as requirements for the conjure package, then use the pack macro to load them instead.
;;; You can use the pack macro to create package declarations within a use-package! block.
;;; e.g. (use-package! :nvim-telescope/telescope.nvim {:requires [(pack :nvim-telescope/telescope-frecency.nvim {:requires [:tami5/sqlite.lua]})]}) will create a package declaration for telescope-frecency.nvim, which requires sqlite.

;;; This config also introduces the init! keyword
;;; :init! is used to initialize any package which as the form require("<name>").setup
;;; e.g. (use-package! :folke/which-key.nvim {:init :which-key}) expands to use({config = "require('which-key').setup()", "folke/which-key.nvim"})

;;; Some other notes about the package macros
;;; Packages can be added with use-package! anywhere you please, as they are added to a global list. However, make sure to call packitup! after you have declared all the packages you need to install, as the configuration will ignore everything *after* packitup! is called.
;;; Similar to use-package and pack, there are also the rock and rock! macros for declaring, you guessed it, luarock dependencies. As I don't like external dependencies (and because luarocks is *extremely* finicky on macOS), you don't see it used in this config by default. Feel free to use it yourself though.
;;; rock vs rock!: rock is to rock! as pack is to use-package!

;;; for lazy loading, here is a quick reference of the events you should use.
;;; 1. BufRead (read the contexts of demo.txt into the new buffer)
;;; 2. InsertEnter (swap into Insert mode)
;;; 3. InsertCharPre (swap into Insert mode, right when you press the first input)
;;; you can also lazy load packages on commands (:cmd), filetypes (:ft), and after other plugins (:after).

;; Bootstrap essential plugins
(use-package! :wbthomason/packer.nvim)
(use-package! :lewis6991/impatient.nvim)

;; There are some plugins we only want to load for lisps. Heres a list of lispy filetypes I use
(local lisp-ft [:fennel :clojure :lisp :racket :scheme])

;; lispy configs
(use-package! :Olical/conjure
              {:branch :develop
               :ft lisp-ft
               :requires [(pack :gpanders/nvim-parinfer {:ft lisp-ft})
                          (if (= fennel_compiler :aniseed)
                              (do
                                (pack :Olical/aniseed {:branch :develop}))
                              (= fennel_compiler :hotpot)
                              (do
                                (pack :rktjmp/hotpot.nvim)))]})

;; bindings
(use-package! :folke/which-key.nvim {:init :which-key})

;; completion (note: I don't really like completion, so I just have some paren and comment help for now)
(use-package! :numToStr/Comment.nvim {:init :Comment})
(use-package! :hrsh7th/nvim-cmp
              {:config! :cmp
               :requires [(pack :PaterJason/cmp-conjure {:after :conjure})
                          (pack :hrsh7th/cmp-path {:after :nvim-cmp})
                          (pack :hrsh7th/cmp-copilot {:after :nvim-cmp})
                          :github/copilot.vim
                          :lukas-reineke/cmp-under-comparator]})

;; Fuzzy navigation
;; the loading order for this one is a bit weird, but it works. Extensions are loaded on their command, fzf native is loaded first, then telescope.nvim after fzf.
(use-package! :nvim-telescope/telescope.nvim
              {:after :telescope-fzf-native.nvim
               :config! :telescope
               :requires [(pack :nvim-lua/popup.nvim
                                {:cmd :Telescope})
                          (pack :nvim-lua/plenary.nvim
                                {:after :popup.nvim})
                          (pack :nvim-telescope/telescope-frecency.nvim
                                {:requires [:tami5/sqlite.lua]
                                 :after :plenary.nvim})
                          (pack :nvim-telescope/telescope-fzf-native.nvim
                                {:run :make :after :plenary.nvim})]})

;; tree-sitter
(use-package! :nvim-treesitter/nvim-treesitter
              {:config! :treesitter
               :requires [(pack :p00f/nvim-ts-rainbow {:after :nvim-treesitter})
                          (pack :nvim-treesitter/playground
                                {:cmd :TSPlayground})]})

;; lsp
(use-package! :neovim/nvim-lspconfig
              {:config! :lsp
               :requires [:williamboman/nvim-lsp-installer
                          :hrsh7th/cmp-nvim-lsp
                          (pack :j-hui/fidget.nvim {:after :nvim-lspconfig :init :fidget})]})

(use-package! :folke/trouble.nvim
              {:cmd :Trouble
               :config (fn []
                         (local {: setup} (require :trouble))
                         (setup {:icons false}))})

;; aesthetics
(use-package! :mcchrish/zenbones.nvim
              {:requires [:rktjmp/lush.nvim]})
(use-package! :Pocco81/TrueZen.nvim {:cmd :TZAtaraxis :config! :truezen})
(use-package! :rcarriga/nvim-notify
              {:config (fn []
                         (set vim.notify (require :notify))
                         (local {: setup} (require :notify))
                         (setup {:stages :slide
                                 :timeout 2500
                                 :minimum_width 50
                                 :icons {:ERROR ""
                                         :WARN ""
                                         :INFO ""
                                         :DEBUG ""
                                         :TRACE "✎"}}))})

;; Notes: orgmode was previously supported, but its quite buggy and not up to part with emacs. I think neorg is the way to go
(use-package! :nvim-neorg/neorg
              {:config! :neorg 
               :ft :norg 
               :after :nvim-treesitter})

;;Vimtex: for tex file compilation and management.
(local ft-tex [:tex :bib])
(use-package! :lervag/Vimtex {:ft ft-tex})

;; At the end of the file, the unpack! macro is called to initialize packer and pass each package to the packer.nvim plugin.
(unpack!)
