(require 'test/common)


(ert-deftest eldev-test-upgrade-other-archive-1 ()
  (let ((eldev--test-project "missing-dependency-a"))
    (eldev--test-delete-cache)
    (eldev--test-run nil ("version" "dependency-a")
      (should (string-match-p "dependency-a" stderr))
      (should (string= stdout ""))
      (should (= exit-code 1)))
    (eldev--test-run nil ("--setup" "(eldev-use-package-archive `(\"archive-a\" . ,(expand-file-name \"../package-archive-a\")))"
                          "version" "dependency-a")
      (should (string= stdout "dependency-a 1.0\n"))
      (should (= exit-code 0)))
    ;; Package archives A and B have different versions of `dependency-a'.
    (eldev--test-run nil ("--setup" "(eldev-use-package-archive `(\"archive-b\" . ,(expand-file-name \"../package-archive-b\")))"
                          "upgrade")
      (should (string= stdout "Upgraded or installed 1 dependency package\n"))
      (should (= exit-code 0)))
    ;; Package archive in setup form shouldn't be needed at this
    ;; point: dependency is already installed.
    (eldev--test-run nil ("version" "dependency-a")
      (should (string= stdout "dependency-a 1.1\n"))
      (should (= exit-code 0)))))

;; Exactly like the previous test, only we keep archive name to make
;; sure that 'upgrade' command knows to refetch its contents.
(ert-deftest eldev-test-upgrade-same-archive-1 ()
  (let ((eldev--test-project "missing-dependency-a"))
    (eldev--test-delete-cache)
    (eldev--test-run nil ("version" "dependency-a")
      (should (string-match-p "dependency-a" stderr))
      (should (string= stdout ""))
      (should (= exit-code 1)))
    (eldev--test-run nil ("--setup" "(eldev-use-package-archive `(\"archive-a\" . ,(expand-file-name \"../package-archive-a\")))"
                          "version" "dependency-a")
      (should (string= stdout "dependency-a 1.0\n"))
      (should (= exit-code 0)))
    ;; Package archives A and B have different versions of `dependency-a'.
    (eldev--test-run nil ("--setup" "(eldev-use-package-archive `(\"archive-a\" . ,(expand-file-name \"../package-archive-b\")))"
                          "upgrade")
      (should (string= stdout "Upgraded or installed 1 dependency package\n"))
      (should (= exit-code 0)))
    ;; Package archive in setup form shouldn't be needed at this point:
    ;; dependency is already installed.
    (eldev--test-run nil ("version" "dependency-a")
      (should (string= stdout "dependency-a 1.1\n"))
      (should (= exit-code 0)))))


(ert-deftest eldev-test-upgrade-wrong-dependency-1 ()
  (eldev--test-run "trivial-project" ("upgrade" "doesnt-depend-on-this")
    (should (= exit-code 1))))


(ert-deftest eldev-test-upgrade-other-archive-2 ()
  (let ((eldev--test-project "missing-dependency-b"))
    (eldev--test-delete-cache)
    (eldev--test-run nil ("version" "dependency-b")
      (should (string-match-p "dependency-b" stderr))
      (should (string= stdout ""))
      (should (= exit-code 1)))
    (eldev--test-run nil ("--setup" "(eldev-use-package-archive `(\"archive-a\" . ,(expand-file-name \"../package-archive-a\")))"
                          "version" "dependency-a" "dependency-b")
      (should (string= stdout "dependency-a 1.0\ndependency-b 1.0\n"))
      (should (= exit-code 0)))
    (eldev--test-run nil ("--setup" "(eldev-use-package-archive `(\"archive-b\" . ,(expand-file-name \"../package-archive-b\")))"
                          "upgrade")
      (should (string= stdout "Upgraded or installed 2 dependency packages\n"))
      (should (= exit-code 0)))
    (eldev--test-run nil ("version" "dependency-a" "dependency-b")
      (should (string= stdout "dependency-a 1.1\ndependency-b 1.1\n"))
      (should (= exit-code 0)))))

;; Like above, but explicitly list what to upgrade.
(ert-deftest eldev-test-upgrade-other-archive-3 ()
  (let ((eldev--test-project "missing-dependency-b"))
    (eldev--test-delete-cache)
    (eldev--test-run nil ("version" "dependency-b")
      (should (string-match-p "dependency-b" stderr))
      (should (string= stdout ""))
      (should (= exit-code 1)))
    (eldev--test-run nil ("--setup" "(eldev-use-package-archive `(\"archive-a\" . ,(expand-file-name \"../package-archive-a\")))"
                          "version" "dependency-a" "dependency-b")
      (should (string= stdout "dependency-a 1.0\ndependency-b 1.0\n"))
      (should (= exit-code 0)))
    (eldev--test-run nil ("--setup" "(eldev-use-package-archive `(\"archive-b\" . ,(expand-file-name \"../package-archive-b\")))"
                          "upgrade" "dependency-a" "dependency-b")
      (should (string= stdout "Upgraded or installed 2 dependency packages\n"))
      (should (= exit-code 0)))
    (eldev--test-run nil ("version" "dependency-a" "dependency-b")
      (should (string= stdout "dependency-a 1.1\ndependency-b 1.1\n"))
      (should (= exit-code 0)))))

;; Like above, but explicitly upgrade only `dependency-a'.
(ert-deftest eldev-test-upgrade-other-archive-4 ()
  (let ((eldev--test-project "missing-dependency-b"))
    (eldev--test-delete-cache)
    (eldev--test-run nil ("version" "dependency-b")
      (should (string-match-p "dependency-b" stderr))
      (should (string= stdout ""))
      (should (= exit-code 1)))
    (eldev--test-run nil ("--setup" "(eldev-use-package-archive `(\"archive-a\" . ,(expand-file-name \"../package-archive-a\")))"
                          "version" "dependency-a" "dependency-b")
      (should (string= stdout "dependency-a 1.0\ndependency-b 1.0\n"))
      (should (= exit-code 0)))
    (eldev--test-run nil ("--setup" "(eldev-use-package-archive `(\"archive-b\" . ,(expand-file-name \"../package-archive-b\")))"
                          "upgrade" "dependency-a")
      (should (string= stdout "Upgraded or installed 1 dependency package\n"))
      (should (= exit-code 0)))
    (eldev--test-run nil ("version" "dependency-a" "dependency-b")
      (should (string= stdout "dependency-a 1.1\ndependency-b 1.0\n"))
      (should (= exit-code 0)))))

;; Like above, but explicitly upgrade only `dependency-b'; however
;; `dependency-a' must get upgraded too, since new `dependency-b'
;; version requires it.
(ert-deftest eldev-test-upgrade-other-archive-5 ()
  (let ((eldev--test-project "missing-dependency-b"))
    (eldev--test-delete-cache)
    (eldev--test-run nil ("version" "dependency-b")
      (should (string-match-p "dependency-b" stderr))
      (should (string= stdout ""))
      (should (= exit-code 1)))
    (eldev--test-run nil ("--setup" "(eldev-use-package-archive `(\"archive-a\" . ,(expand-file-name \"../package-archive-a\")))"
                          "version" "dependency-a" "dependency-b")
      (should (string= stdout "dependency-a 1.0\ndependency-b 1.0\n"))
      (should (= exit-code 0)))
    (eldev--test-run nil ("--setup" "(eldev-use-package-archive `(\"archive-b\" . ,(expand-file-name \"../package-archive-b\")))"
                          "upgrade" "dependency-b")
      (should (string= stdout "Upgraded or installed 2 dependency packages\n"))
      (should (= exit-code 0)))
    (eldev--test-run nil ("version" "dependency-a" "dependency-b")
      (should (string= stdout "dependency-a 1.1\ndependency-b 1.1\n"))
      (should (= exit-code 0)))))


(ert-deftest eldev-test-upgrade-dry-run-1 ()
  (let ((eldev--test-project "missing-dependency-a"))
    (eldev--test-delete-cache)
    (eldev--test-run nil ("--setup" "(eldev-use-package-archive `(\"archive-a\" . ,(expand-file-name \"../package-archive-a\")))"
                          "version" "dependency-a")
      (should (string= stdout "dependency-a 1.0\n"))
      (should (= exit-code 0)))
    (eldev--test-run nil ("--setup" "(eldev-use-package-archive `(\"archive-b\" . ,(expand-file-name \"../package-archive-b\")))"
                          "upgrade" "--dry-run")
      ;; `--dry-run' intentionally produces exactly the same output.
      (should (string= stdout "Upgraded or installed 1 dependency package\n"))
      (should (= exit-code 0)))
    (eldev--test-run nil ("version" "dependency-a")
      ;; But it doesn't actually upgrade anything.
      (should (string= stdout "dependency-a 1.0\n"))
      (should (= exit-code 0)))))


(provide 'test/upgrade)
