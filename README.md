# My Emacs configuration
This repository contains 'the constant' part of my Emacs configuration used on both my machines. The full configuration also contains two local files `local-conf.el` and `custom.el`, which are not part of this repository. The former primarily contains various flags for the init-file (those prefixed by `local-conf-`), and the latter contains changes via customize.

## Code from other authors
This repository contains GPL-licensed files from other authors.
* __TinyEat:__ A useful library from [Jari Aalto's Tiny Tools project](https://github.com/jaalto/project--emacs-tiny-tools). It is licensed under GPL2, and the files in this repository are unmodified copies of the original files. Only the `tinyeat-autoload.el` file is new, and it simply collects the autoload-statements. In practice, I byte-compile all these files except `tinyeat.el`, `tinylib.el`, and `tinyliba.el` to speed up loading times.

* __Jazz themes:__ A version of [Roman Parykin's Jazz theme](https://github.com/donderom/jazz-theme) with minor additions to fit my own init-hacks. Two additional themes `smooth-jazz` and `jazz-print` provide a light variant and a printer-friendly variant, respectively. They are all licensed under GPL3.
