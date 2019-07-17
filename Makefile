# LTL3BA - Version 1.1.3 - September 2016

# Written by Denis Oddoux, LIAFA, France                                 
# Copyright (c) 2001  Denis Oddoux                                       
# Modified by Paul Gastin, LSV, France                                   
# Copyright (c) 2007  Paul Gastin                                        
# Modified by Tomas Babiak, FI MU, Brno, Czech Republic                  
# Copyright (c) 2012  Tomas Babiak                                       
#                                                                        
# This program is free software; you can redistribute it and/or modify   
# it under the terms of the GNU General Public License as published by   
# the Free Software Foundation; either version 2 of the License, or      
# (at your option) any later version.                                    
#                                                                        
# This program is distributed in the hope that it will be useful,        
# but WITHOUT ANY WARRANTY; without even the implied warranty of         
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          
# GNU General Public License for more details.                           
#                                                                        
# You should have received a copy of the GNU General Public License      
# along with this program; if not, write to the Free Software            
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#                                                                        
# Based on the translation algorithm by Gastin and Oddoux,               
# presented at the 13th International Conference on Computer Aided       
# Verification, CAV 2001, Paris, France.                                 
# Proceedings - LNCS 2102, pp. 53-65                                     
#                                                                        
# Modifications based on paper by                                        
# T. Babiak, M. Kretinsky, V. Rehak, and J. Strejcek,                    
# LTL to Buchi Automata Translation: Fast and More Deterministic         
# presented at the 18th International Conference on Tools and            
# Algorithms for the Construction and Analysis of Systems (TACAS 2012)   

# Set PATH to "bdd.h" BuDDy file.
BUDDY_SRC := BuDDy/src
BUDDY_SOURCES=  $(BUDDY_SRC)/bddio.c \
				$(BUDDY_SRC)/bddop.c \
				$(BUDDY_SRC)/bvec.c \
				$(BUDDY_SRC)/cache.c \
				$(BUDDY_SRC)/fdd.c \
				$(BUDDY_SRC)/imatrix.c \
				$(BUDDY_SRC)/kernel.c \
				$(BUDDY_SRC)/pairs.c \
				$(BUDDY_SRC)/prime.c \
				$(BUDDY_SRC)/reorder.c \
				$(BUDDY_SRC)/tree.c \

# BUDDY_SOURCES := $(wildcard $(BUDDY_SRC)/*.c)
BUDDY_OBJECTS := $(patsubst $(BUDDY_SRC)/%.c, $(BUDDY_SRC)/%.o, $(BUDDY_SOURCES))
# Set PATH to "libbdd.a" BuDDy file.
# BUDDY_LIB=/usr/local/lib/

# to obtain BuDDy run:
# $ cd some_directory
# $ wget https://downloads.sourceforge.net/project/buddy/buddy/BuDDy%202.4/buddy-2.4.tar.gz
# $ tar xzf buddy-2.4.tar.gz
# $ cd buddy-2.4
# $ ./configure
# $ make
# then set  
# BUDDY_INCLUDE=some_directory/buddy-2.4/src/
# BUDDY_LIB=some_directory/buddy-2.4/src/.libs/
# and add BUDDY_LIB path into the library path (LD_LIBRARY_PATH)
# or run 
# $ make install 
# and use the default values of BUDDY_INCLUDE and BUDDY_LIB.

CPPFLAGS= -I$(BUDDY_SRC) -static-libgcc -static-libstdc++

LTL3BA=	parse.o lex.o trans.o buchi.o cset.o set.o \
	mem.o rewrt.o cache.o alternating.o generalized.o optim.o

LTL3BA_SOURCES= lex.cpp parse.cpp trans.cpp buchi.cpp cset.cpp set.cpp \
				mem.cpp rewrt.cpp cache.cpp alternating.cpp generalized.cpp optim.cpp

OBJECTS := $(BUDDY_OBJECTS) $(LTL3BA)


MEX_TOOLCHAIN_DIR = mex_toolchain/

.PHONY: _setup_matlab_windows

native: CC=gcc 
native: CXX=g++
native: ltl3ba 

windows: CC=x86_64-w64-mingw32-gcc-win32 
windows: CXX=x86_64-w64-mingw32-g++-win32
windows: ext=.exe
windows: ltl3ba

ltl3ba: $(BUDDY_OBJECTS)
		$(CXX) $(CPPFLAGS) $(BUDDY_SRC)/cppext.cxx main.cpp $(LTL3BA_SOURCES) $(BUDDY_OBJECTS) -o ltl3ba$(ext) 

_setup_matlab_windows: 
		mex -f mex_toolchain/x86_64_w64_mingw32_g++.xml -setup:$(shell pwd)/mex_toolchain/x86_64_w64_mingw32_g++.xml C++
		mex -f mex_toolchain/x86_64_w64_mingw32_gcc.xml -setup:$(shell pwd)/mex_toolchain/x86_64_w64_mingw32_gcc.xml C

matlab_windows: CC=x86_64-w64-mingw32-gcc
matlab_windows: CXX=x86_64-w64-mingw32-g++
matlab_windows: 
		mex -v -f $(MEX_TOOLCHAIN_DIR)/$(CC).xml -I$(BUDDY_SRC) -c $(BUDDY_SOURCES) -outdir $(BUDDY_SRC) 
		mex -v -f $(MEX_TOOLCHAIN_DIR)/$(CXX).xml -I$(BUDDY_SRC) $(BUDDY_OBJECTS) $(LTL3BA_SOURCES) $(BUDDY_SRC)/cppext.cxx main.cpp -output ltl3ba_cpp

matlab: 
		mex -I$(BUDDY_SRC) -c $(BUDDY_SOURCES) -outdir $(BUDDY_SRC) 
		mex -I$(BUDDY_SRC) $(BUDDY_OBJECTS) $(LTL3BA_SOURCES) $(BUDDY_SRC)/cppext.cxx main.cpp -output ltl3ba_cpp

clean:
	rm -f ltl3ba *.o core $(BUDDY_SRC)/*.o
