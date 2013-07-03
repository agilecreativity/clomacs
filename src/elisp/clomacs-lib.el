(defun force-symbol-name (some-symbol)
  "Return lisp symbol `some-symbol' as a string at all costs!"
  (mapconcat 'char-to-string
             (string-to-list (symbol-name some-symbol)) ""))

(defun find-file-in-load-path (search-file-name &optional fail-on-error)
  "Return the full path to `search-file-name'.
`search-file-name' is searching in the emacs `load-path'.
When `fail-on-error' is t, raise error if nothing found, return nil otherwise."
  (let ((result nil))
    (if search-file-name
        (dolist (path load-path)
          (let ((search-file-path (expand-file-name search-file-name path)))
            (if (file-exists-p search-file-path)
                (setq result search-file-path)))))
    (if (and fail-on-error (not result))
        (error (concat "Can't find file " search-file-name))
      result)))

(defun find-file-recursively (search-file-name
                              &optional start-path fail-on-error)
  "Return the full path to `search-file-name'.
Recursive searching starts from `start-path'.
When `fail-on-error' is t, raise error if nothing found, return nil otherwise."
  (let ((start-path (if start-path start-path "/"))
        (result nil))
    (if search-file-name
        (dolist (path-entity (directory-files-and-attributes start-path t))
          (if (not result)
              (let ((entity-name (car path-entity)))
                (if (and
                     (cadr path-entity) ; is a directory sign
                     (not (or (equal (file-name-nondirectory entity-name) ".")
                              (equal (file-name-nondirectory entity-name) "..")
                              (equal (substring
                                      (file-name-nondirectory entity-name)
                                      0 2) ".#"))))
                    ;; is a directory
                    (setq result (find-file-recursively search-file-name
                                                        entity-name nil))
                  ;; is a file
                  (if (equal (downcase search-file-name)
                             (downcase (file-name-nondirectory entity-name)))
                      (setq result entity-name)))))))
    (if (and fail-on-error (not result))
        (error (concat "Can't find file " search-file-name)))
    result))

(defun find-file-upwards (search-file-name start-path
                          &optional ascent-depth fail-on-error)
  "Return the full path to `search-file-name' by moving upwards
on the directory tree.
`start-path' is path where searching starts.
`ascent-depth' is a maximim number of '..' acts on the directory tree.
When `fail-on-error' is t, raise error if nothing found,return nil otherwise."
  (let ((ascent-depth (if ascent-depth ascent-depth 0))
        (result nil))
    (if (and start-path search-file-name)
        (dolist (path-entity (directory-files-and-attributes start-path t))
          (if (not result)
              (let ((entity-name (car path-entity)))
                (if (not
                     (and
                      (cadr path-entity) ; is a directory sign
                      (not (or (equal (file-name-nondirectory entity-name) ".")
                               (equal (file-name-nondirectory entity-name) "..")
                               (equal (substring
                                       (file-name-nondirectory entity-name)
                                       0 2) ".#")))))
                  ;; is a file
                  (if (equal (downcase search-file-name)
                             (downcase (file-name-nondirectory entity-name)))
                      (setq result entity-name)))))))
    (if (and (not result) (> ascent-depth 0))
        (setq result (find-file-upwards search-file-name
                                        (concat-path start-path "..")
                                        (1- ascent-depth)
                                        fail-on-error)))
    (if (and fail-on-error (not result))
        (error (concat "Can't find file " search-file-name)))
    result))

(defun concat-path (&rest folders)
  "Concatenate list of folders to the path.
E.g.
 (concat-path (getenv \"HOME\") \".m2\" \"repository\")"
  (let ((path))
    (dolist (folder folders)
      (setq path (if (equal ".." folder)
                     (file-name-as-directory (expand-file-name ".." path))
                   (file-name-as-directory (concat path folder)))))
    path))

(defun add-quotes (str)
  (concat "\"" str "\""))

(defun add-squotes (str)
  (concat "'" str "'"))

(provide 'clomacs-lib)
