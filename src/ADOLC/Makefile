#-------------------------------------------------------------------------------
# ADOLC Makefile
#-------------------------------------------------------------------------------

.PHONY : default all get library purge clean distclean ccode

default: all

# Compile the C-callable libraries and the Demo programs.

get:
	echo 'download.file(url="https://gitlab.com/adol-c/adol-c/repository/swig/archive.tar.gz", destfile="archive.tar.gz", method="auto", quiet = FALSE, mode = "w", cacheOK = TRUE, extra = getOption("download.file.extra"))'|$(R_HOME)/bin/R --vanilla 
	tar zxvf archive.tar.gz
	mv adol-c-swig* adol-c-swig
 
all: get
	( cd ${PWD}/adol-c-swig ; libtoolize; autoreconf -fi ; ./configure --enable-sparse --with-colpack=${PWD}/../Colpack/Colpack-master-inst/ --prefix=${PWD}/adol-c-swig-inst; $(MAKE); $(MAKE) install )
 
# Compile the C-callable libraries only.
library: all

# Remove all files not in the original distribution
purge:
	( rm -Rf adol-c-swig* archive* )
	( rm -Rf  *.tar *.zip *.tar.gz *inst )

# Remove all files not in the original distribution 
clean: purge

distclean: purge

