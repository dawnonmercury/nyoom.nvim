;; Icons/text for each mode 
(local modes {:n :RW
              :no :RO
              :v "**"
              :V "**"
              "\022" "**"
              :s :S
              :S :SL
              "\019" :SB
              :i "**"
              :ic "**"
              :R :RA
              :Rv :RV
              :c :VIEX
              :cv :VIEX
              :ce :EX
              :r :r
              :rm :r
              :r? :r
              :! "!"
              :t :t})

;; Make our statusline colourful
(fn color []
  (let [mode (. (vim.api.nvim_get_mode) :mode)]
    (var mode-color "%#StatusLine#")
    (if (= mode :n) (set mode-color "%#StatusNormal#")
        (or (= mode :i) (= mode :ic)) (set mode-color "%#StatusInsert#")
        (or (or (= mode :v) (= mode :V)) (= mode "\022"))
        (set mode-color "%#StatusVisual#") (= mode :R)
        (set mode-color "%#StatusReplace#") (= mode :c)
        (set mode-color "%#StatusCommand#") (= mode :t)
        (set mode-color "%#StatusTerminal#"))
    mode-color))

;; Normally we would have an inactive and a short section as well, but since we have a global statusline now I removed them
(global Statusline {})
(set Statusline.active (fn []
                         (table.concat [(color)
                                        (: (string.format " %s "
                                                          (. modes
                                                             (. (vim.api.nvim_get_mode)
                                                                :mode)))
                                           :upper)
                                        "%#StatusLine#"
                                        " %f %m "
                                        "%="
                                        " %Y "
                                        (color)
                                        " %l(%L):%c "])))

(fn nightly? []
   "Check if using Neovim nightly (0.8)"
   (let [nightly (vim.fn.has :nvim-0.8.0)]
     (= nightly 1)))

;; Use statusline as winbar if on nightly
;; (if (= true (nightly?))
;;    (set vim.opt.laststatus 0)
;;    (set vim.opt.laststatus 3))

;; (if (= true (nightly?))
;;    (set vim.opt.winbar "%!v:lua.Statusline.active()")
;;    (set vim.opt.statusline "%!v:lua.Statusline.active()"))

(set vim.opt.laststatus 3)
(set vim.opt.showmode false)
(set vim.opt.statusline "%!v:lua.Statusline.active()")





