;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((powershell-mode
  (projectile-project-test-cmd . "powershell.exe -NoProfile -NoLogo Invoke-Pester")
  (projectile-test-suffix-function lambda
                                   (project-type)
                                   "Tests")))

