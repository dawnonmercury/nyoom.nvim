;;; Sane defaults/maps
(require :conf.core)

;; Plugin configs
(require :conf.pack)

;; load packer when its ready
(when (= (vim.fn.filereadable (.. (vim.fn.stdpath :config)
                                  :/lua/packer_compiled.lua)) 1)
  (require :packer_compiled))
