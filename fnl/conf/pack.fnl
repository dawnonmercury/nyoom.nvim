(import-macros {: pack : use-package! : rock : rock! : unpack! : cmd} :conf.macros)
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
(use-package! :nvim-lua/plenary.nvim)
(use-package! :wbthomason/packer.nvim)
(use-package! :lewis6991/impatient.nvim)

;; There are some plugins we only want to load for lisps. Heres a list of lispy filetypes I use
(local lisp-ft [:fennel :clojure :lisp :racket :scheme])

;; lispy configs
(use-package! :Olical/conjure
              {:branch :develop
               :ft lisp-ft
               :requires [(pack :gpanders/nvim-parinfer {:ft lisp-ft})
                          (match fennel_compiler
                            :aniseed (pack :Olical/aniseed {:branch :develop})
                            :hotpot (pack :rktjmp/hotpot.nvim {:branch :master})
                            :tangerine (pack :udayvir-singh/tangerine.nvim
                                             {:branch :teacher}))]})

;; rusty stuff
(use-package! :simrat39/rust-tools.nvim {:ft :rust 
                                         :init :rust-tools})

;; bindings
(use-package! :folke/which-key.nvim {:init :which-key})
(use-package! :ggandor/leap.nvim
              {:config (fn []
                         ((. (require :leap) :set_default_keymaps)))})

;; File navigation
;; the loading order for this one is a bit weird, but it works. Extensions are loaded on their command, fzf native is loaded first, then telescope.nvim after fzf.
;; the loading order for this one is a bit weird, but it works. Extensions are loaded on their command, fzf native is loaded first, then telescope.nvim after fzf.
(use-package! :nvim-telescope/telescope.nvim {:cmd :Telescope :config! :telescope})
(use-package! :kyazdani42/nvim-tree.lua {:cmd :NvimTreeToggle :config! :nvimtree})

;; tree-sitter
(use-package! :nvim-treesitter/nvim-treesitter
              {:config! :treesitter
               :run ":TSUpdate"
               :event {1 :BufRead 2 :BufNewFile}
               :requires [(pack :p00f/nvim-ts-rainbow {:event {1 :BufRead 2 :BufNewFile}})
                          (pack :nvim-treesitter/playground
                                {:cmd :TSPlayground})]})

;; lsp
(use-package! :neovim/nvim-lspconfig
              {:module :lspconfig
               :config! :lsp
               :requires [(pack :j-hui/fidget.nvim {:after :nvim-lspconfig :init :fidget})
                          (pack :williamboman/nvim-lsp-installer {:setup (fn [])}
                                                                ((. (require :lazytimer)
                                                                    :packer_lazy_load) :nvim-lsp-installer.nvim))
                          (pack :hrsh7th/cmp-nvim-lsp {:setup (fn []
                                                                ((. (require :lazytimer)
                                                                    :packer_lazy_load) :cmp-nvim-lsp))})]
               :setup (fn []
                        ((. (require :lazytimer)
                            :packer_lazy_load) :nvim-lspconfig)
                        (vim.defer_fn (fn []
                                        (cmd "if &ft == \"packer\" | echo \"\" | else | silent! e %"))
                                      0))})

;; git
(use-package! :lewis6991/gitsigns.nvim
              {:config! :gitsigns
               :setup (fn []
                        ((. (require :lazytimer)
                            :packer_lazy_load) :gitsigns.nvim))})

(use-package! :TimUntersberger/neogit
              {:init :neogit
               :cmd :Neogit})

;; completion/copilot
(use-package! :zbirenbaum/copilot.lua
              {:event :InsertEnter
               :config (fn []
                         (vim.schedule (fn []
                                         ((. (require :copilot)
                                             :setup)))))})

(use-package! :hrsh7th/nvim-cmp
              {:config! :cmp
               :module :cmp
               :after :cmp-under-comparator
               :requires [(pack :lukas-reineke/cmp-under-comparator
                                {:event :InsertEnter})
                          (pack :hrsh7th/cmp-path {:after :nvim-cmp})
                          (pack :PaterJason/cmp-conjure {:ft lisp-ft})
                          (pack :hrsh7th/cmp-buffer {:after :nvim-cmp})
                          (pack :ray-x/cmp-treesitter {:after :nvim-cmp})
                          (pack :zbirenbaum/copilot-cmp {:after :copilot.lua})
                          (pack :hrsh7th/cmp-nvim-lua {:after :nvim-cmp})]})

(use-package! :folke/trouble.nvim
              {:cmd :Trouble
               :config (fn []
                         (local {: setup} (require :trouble))
                         (setup {:icons false}))})

;; aesthetics
(use-package! :mcchrish/zenbones.nvim
              {:requires [:rktjmp/lush.nvim]})
(use-package! :Pocco81/TrueZen.nvim {:cmd :TZAtaraxis :config! :truezen})
(use-package! :folke/twilight.nvim {:init :twilight})
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

;; Notes: orgmode was previously supported, but its quite buggy and not up to part with emacs. I think neorg is the way to go. Firenvim is mostly for when I need to use the web but I want to keep neovim around with me  
(use-package! :nvim-neorg/neorg
              {:config! :neorg :ft :norg :after :nvim-treesitter})

;;Vimtex: for tex file compilation and management.
(local ft-tex [:tex :bib])
(use-package! :lervag/Vimtex {:ft ft-tex})

;; At the end of the file, the unpack! macro is called to initialize packer and pass each package to the packer.nvim plugin.
(unpack!)
