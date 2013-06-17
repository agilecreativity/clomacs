
(ert-deftest clomacs-defun-test ()
       "Tests for `clomacs-defun'."
       (clomacs-defun summ-1 +)
       (should (equal (summ-1 2 3) "5"))

       (clomacs-defun summ-2 + :number)
       (should (equal (summ-2 2 3) 5))

       (clomacs-defun summ-3 + string-to-int)
       (should (equal (summ-3 2 3) 5))

       (clomacs-defun str str)
       (should (equal (str 2 "str") "2str"))       

       (clomacs-defun get-property System/getProperty)
       (should (stringp (get-property "java.version")))
       )

