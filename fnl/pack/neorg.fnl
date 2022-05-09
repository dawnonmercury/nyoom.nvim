(local {: setup} (require :neorg))
(setup {:load {:core.defaults {}
               :core.norg.concealer {}
               :core.norg.qol.toc {}
               :core.norg.completion {:config {:engine :nvim-cmp}}
               :core.norg.dirman {:config {:workspaces {:main "~/neorg/neorg"} ; change this to your workspace, this is just mine
                                           :autodetect true
                                           :autochdir true}}}})
