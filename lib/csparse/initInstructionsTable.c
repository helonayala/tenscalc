/* Created by script createGateway.m on 25-May-2018 11:01:10 */

/* START OF #included "GPL.c" */
/*
  Copyright 2012-2017 Joao Hespanha

  This file is part of Tencalc.

  TensCalc is free software: you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  TensCalc is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with TensCalc.  If not, see <http://www.gnu.org/licenses/>.
*/

    
    
/* END OF #included "GPL.c" */
/* mex -largeArrayDims COPTIMFLAGS="-Ofast /arch:AVX2 -DNDEBUG" CFLAGS="\$CFLAGS -Wall -Werror -Wno-unused-variable -Wno-unused-result -std=gnu99" "initInstructionsTable.c" -outdir  */

#ifdef __linux__
#include <dlfcn.h>
#include <unistd.h>
#endif
#ifdef __APPLE__
#include <dlfcn.h>
#include <unistd.h>
#endif
#ifdef _WIN32
#include <windows.h>
#include <stdint.h>
#endif
#include <fcntl.h>
#include <inttypes.h>
#include <mex.h>

#ifdef __linux__
void *libHandle=NULL;
#endif
#ifdef __APPLE__
void *libHandle=NULL;
#endif
#ifdef _WIN32
HMODULE libHandle=NULL;
#endif
void (*PinitInstructionsTable)(
)=NULL;

#include "instructionsTableFunctions.h"

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{

   /* Process inputs */

   /* Check # inputs */
   if(nrhs!=0) {
      mexErrMsgIdAndTxt("initInstructionsTable:nrhs", "0 inputs required, %d found.",nrhs);
      return; }


   /* Process outputs */

   /* Check # outputs */
   if(nlhs!=0) {
      mexErrMsgIdAndTxt("initInstructionsTable:nrhs", "0 outputs required, %d found.",nlhs);
      return; }


   /* Call function */
   if (!PinitInstructionsTable) {
#ifdef __linux__
     libHandle = dlopen("C:/Users/hespanha/Documents/MATLAB/tenscalc/lib/csparse/instructionsTable.so", RTLD_NOW);
     if (!libHandle) { printf("[%s] Unable to open library: %s\n",__FILE__, dlerror());return; }
     PinitInstructionsTable = dlsym(libHandle, "initInstructionsTable");
     if (!PinitInstructionsTable) { printf("[%s] Unable to get symbol: %s\n",__FILE__, dlerror());return; }// else { printf("[%s] Got symbol: initInstructionsTable = 0x%" PRIXPTR"\n",__FILE__, PinitInstructionsTable);}
#elif __APPLE__
     libHandle = dlopen("C:/Users/hespanha/Documents/MATLAB/tenscalc/lib/csparse/instructionsTable.dylib", RTLD_NOW);
     if (!libHandle) { printf("[%s] Unable to open library: %s\n",__FILE__, dlerror());return; }
     PinitInstructionsTable = dlsym(libHandle, "initInstructionsTable");
     if (!PinitInstructionsTable) { printf("[%s] Unable to get symbol: %s\n",__FILE__, dlerror());return; }// else { printf("[%s] Got symbol: initInstructionsTable = 0x%" PRIXPTR"\n",__FILE__, PinitInstructionsTable);}
#elif _WIN32
     libHandle = LoadLibrary("C:/Users/hespanha/Documents/MATLAB/tenscalc/lib/csparse/instructionsTable.dll");
     if (!libHandle) { printf("[%s] Unable to open library\n",__FILE__);return; }
     PinitInstructionsTable = GetProcAddress(libHandle, "initInstructionsTable");
     if (!PinitInstructionsTable) { printf("[%s] Unable to get symbol\n",__FILE__);return; }
#endif // _WIN32
   }
   PinitInstructionsTable();
}
