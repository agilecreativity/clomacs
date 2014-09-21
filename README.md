# clomacs

<img src="https://dl.dropboxusercontent.com/u/820526/clomacs.png"
 alt="Clomacs logo" align="right" />

> Emacs is a Lisp. Clojure is a Lisp. Can the two be put together to form the
> ultimate dev environment? "Clomacs" perhaps?
> * from Emacs isn't for everyone discussion by Anonymous Cow.

Clomacs simplifies call clojure code from Emacs lisp. The purpose is to provide
a tool for creating mixed elisp-clojure Emacs extensions. It provides a small
wrapper under [CIDER](https://github.com/clojure-emacs/cider) to reduce
repetitive code.

## Overview
There are some requirements to run mixed elisp-clojure code. All the elisp-side
code should be loaded, nREPL must run with all related clojure-side code and
it's dependencies.

So, the user of the mixed elisp-clojure Emacs extension wants to simple run
elisp code from the extension.

The purpose of the `clomacs-defun` is to wrap clojure function to elisp
function, that will start nREPL if necessary or use existing nREPL of certain
elisp-clojure Emacs extension, call this clojure function and return it's
result.

## Installation

Clomacs should be added to the MELPA after some testing. So, it will be simple
required by your lib.

For now, it may by installed by adding `clomacs` folder somewhere in your
`emacs.d`.
```lisp
(add-to-list 'load-path "~/.emacs.d/clomacs/src/elisp/")
(require 'clomacs)
```

## Usage

### Simple example

```lisp
;; emacs lisp:
(require 'clomacs)
(clomacs-defun get-property System/getProperty)
(message (get-property "java.version"))
```

Here `System/getProperty` is a clojure function and `get-property` is a wrapped
elisp function.

### Full-fledged example

The full source code for the following example is here:
[cm-test](https://github.com/kostafey/cm-test).

**1.** Create new clojure project in a common way:

```bash
lein new cm-test
```

**2.** Add markdown-clj dependency to the `project.clj` file, add `src/clj`
  folder to the classpath:

```clojure
(defproject cm-test "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :source-paths ["src/clj"]                ; add clj folder to the classpath
  :dependencies [[org.clojure/clojure "1.5.1"]
                 [markdown-clj "0.9.28"]]) ; markdown-clj dependency
```

**3.** Create `clj` folder in the `src/`.<br/>
**4.** Copy `cm_test` to `src/clj/` folder.<br/>
**5.** Add some code, using markdown lib in the `src/clj/cm_test/core.clj` file:

```clojure
(ns cm-test.core
  (:use markdown.core))
  
(defn my-md-to-html-string
  "Call some function from the dependency."
  [x]
  (md-to-html-string x))
```

**6.** Create `elisp` folder in the `src/`.<br/>
**7.** Create `cm-test.el` file in this foder.<br/>
**8.** Add to the `cm-test.el` the following content:

```lisp
(require 'clomacs)
(clomacs-defun cm-test-md-to-html-wrapper
               cm-test.core/my-md-to-html-string
               :lib-name "cm-test"
               :namespace cm-test.core
               :doc "Convert markdown to html via clojure lib.")
               
(defun cm-test-mdarkdown-to-html (beg end)
  "Add to the selected markdown text it's html representation."
  (interactive "r")
  (save-excursion
    (if (< (point) (mark))
        (exchange-point-and-mark))
    (insert
     (concat "\n" (cm-test-md-to-html-wrapper
                   (buffer-substring beg end))))))
                   
(provide 'cm-test)
```

Here is the `cm-test/src` path tree vizualization:
* `src`
   * `clj`
      * `cm_test`
         * `core.clj`
   * `elisp`
      * `cm-test.el`

**9.** So, it can be used in your `.emacs` via:

```lisp
(add-to-list 'load-path "~/.emacs.d/cm-test/src/elisp/")
(require 'cm-test)
```

**10.** Then mark (select) this text in one of your buffers: <br>
`# This is a test`<br>
and run `M-x cm-test-mdarkdown-to-html`.

`<h1>This is a test</h1>` should occurs in the buffer under the original text.
<br> Even if nrepl is not running or run with unknown CLASSPATH everything
should works.

## Projects uses clomacs:

* [cm-test](https://github.com/kostafey/cm-test)
* [ejc-sql](https://github.com/kostafey/ejc-sql)

## Requirements:

* [GNU Emacs](http://www.gnu.org/software/emacs/emacs.html) 24.
* [Leiningen](http://leiningen.org) 2.x
* [CIDER](https://github.com/clojure-emacs/cider)

## License

Copyright © 2013-2014 Kostafey <kostafey@gmail.com>

Distributed under the General Public License, version 3.
