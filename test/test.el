(require 'justl)
(require 'ert)

(ert-deftest just--get-recipies-test ()
  (should (equal (list "default" "build-cmd" "plan" "push" "push2") (just--get-recipies))))

(ert-deftest just--list-to-recipe-test ()
  (should (equal (jrecipe-name (just--list-to-jrecipe (list "recipe" "arg"))) "recipe"))
  (should (equal (jrecipe-name (just--list-to-jrecipe (list "recipe"))) "recipe"))
  (should (equal (jrecipe-args (just--list-to-jrecipe (list "recipe"))) nil)))

(ert-deftest just--recipe-has-args-test ()
  (should (equal (just--jrecipe-has-args (make-jrecipe :name "default" :args nil)) nil))
  )

(ert-deftest just--extract-recipe-doc-test ()
  (should (equal (just--extract-recipe-doc (list "#hello" "hello:")) (list "hello:" "#hello")))
  (should (equal (just--extract-recipe-doc nil) nil))
  (should (equal (just--extract-recipe-doc (list "#hello" "#hi" "hello:")) (list "hello:" "#hi")))
  (should (equal (just--extract-recipe-doc (list "hi")) nil))
  (should (equal (just--extract-recipe-doc (list "#hello" "h" "hello:")) (list "hello:")))
  (should (equal (just--extract-recipe-doc (list "hello:")) (list "hello:")))
  (should (equal (just--extract-recipe-doc (list "hello:" "#hi")) (list "hello:")))
  (should (equal (just--extract-recipe-doc (list "hello:" "#hi" "he2:")) (list "hello:" "he2:" "#hi")))
  (should (equal (just--extract-recipe-doc (list "#hello" "h" "hello:" "#hi" "hello2:")) (list "hello:" "hello2:" "#hi")))
  (should (equal (just--extract-recipe-doc (list "#hello" "h" "hello:" "#hi1" "#hi2" "#hi3" "#hi" "hello2:")) (list "hello:" "hello2:" "#hi"))) ;; fails
  (should (equal (just--extract-recipe-doc (list "#hello" "h" "hello:" "#hi1" "#hi2" "#hi" "hello2:")) (list "hello:" "hello2:" "#hi")))
  )

(ert-deftest just--jrecipe-get-args-test ()
  (should (equal (just--jrecipe-get-args (make-jrecipe :name "default" :args nil)) (list)))
  (should (equal (just--jrecipe-get-args (make-jrecipe :name "default" :args (list (make-jarg :arg "version" :default "'0.4'")))) (list "version='0.4'")))
  (should (equal (just--jrecipe-get-args (make-jrecipe :name "default" :args (list (make-jarg :arg "version1" :default nil) (make-jarg :arg "version2" :default nil)))) (list "version1=" "version2=")))
  )

(ert-deftest just--is-recipe-line-test ()
  (should (equal (just--is-recipe-line "default:") t))
  (should (equal (just--is-recipe-line "build-cmd version='0.4':") t))
  (should (equal (just--is-recipe-line "# Terraform plan") nil))
  (should (equal (just--is-recipe-line "push version: (build-cmd version)") t))
  (should (equal (just--is-recipe-line "    just --list") nil)))

(ert-deftest just--find-justfiles-test ()
  (should (equal (length (just--find-justfiles ".")) 1)))

(ert-deftest just--get-recipe-from-file-test ()
  (should (equal (justl--get-recipe-from-file "./justfile" "default") (make-jrecipe :name "default" :args nil)))
  (should (equal (justl--get-recipe-from-file "./justfile" "plan") (make-jrecipe :name "plan" :args nil)))
  (should (equal (justl--get-recipe-from-file "./justfile" "push2") (make-jrecipe :name "push2" :args
                                                                                  (list (make-jarg :arg "version1" :default nil)
                                                                                        (make-jarg :arg "version2" :default nil)))))
  )

(ert-deftest just--get-recipe-name-test ()
  (should (equal (just--get-recipe-name "default") "default"))
  (should (equal (just--get-recipe-name "build-cmd version='0.4'") "build-cmd"))
  (should (equal (just--get-recipe-name "    push version") "push"))
  (should (equal (just--get-recipe-name "    build-cmd version='0.4' ") "build-cmd"))
  (should (equal (just--get-recipe-name "push version:") "push"))
  (should (equal (just--get-recipe-name "push version1 version2") "push")))

(ert-deftest just--str-to-jarg-test ()
  (should (equal (just--str-to-jarg "version=0.4") (list (make-jarg :arg "version" :default "0.4"))))
  (should (equal (just--str-to-jarg "version='0.4'") (list (make-jarg :arg "version" :default "'0.4'"))))
  (should (equal (just--str-to-jarg "version='0.4' version2") (list (make-jarg :arg "version" :default "'0.4'")
                                                                    (make-jarg :arg "version2" :default nil))))
  (should (equal (just--str-to-jarg "version version2") (list (make-jarg :arg "version" :default nil)
                                                              (make-jarg :arg "version2" :default nil))))
  (should (equal (just--str-to-jarg "") nil))
)

(ert-deftest just--parse-recipe-test ()
  (should (equal (just--parse-recipe "default:") (make-jrecipe :name "default" :args nil)))
  (should (equal (just--parse-recipe "build-cmd version='0.4':")
                 (make-jrecipe :name "build-cmd" :args (list (make-jarg :arg "version" :default "'0.4'")))))
  (should (equal (just--parse-recipe "push version version2:")
                 (make-jrecipe :name "push" :args (list (make-jarg :arg "version" :default nil)
                                                        (make-jarg :arg "version2" :default nil)))))
  (should (equal (just--parse-recipe "push version: (build-cmd version)")
                 (make-jrecipe :name "push" :args (list (make-jarg :arg "version" :default nil)))))
)

(ert "just--*")
