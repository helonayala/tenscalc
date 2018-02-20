/* Created by script createGateway.m on 17-Feb-2018 21:50:12 */

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
/* mex -largeArrayDims -I"/Users/hespanha/matlab_projects/tenscalc/TimDavis/SuiteSparse/include" -L"/Users/hespanha/matlab_projects/tenscalc/TimDavis/SuiteSparse/lib" COPTIMFLAGS="-Ofast -msse -msse2 -msse3 -msse4 -msse4.1 -DNDEBUG" CFLAGS="\$CFLAGS -Wall -Werror -Wno-unused-variable -Wno-unused-result -std=gnu99" "getDependencies.c" -l"umfpack" -outdir  */

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
void (*PgetDependencies4MEX)(
   /* outputs */
   mxArray **children,
   mxArray **parents)=NULL;

#include "instructionsTableFunctions.h"

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
   /* outputs */
   mxArray **children;
   mxArray **parents;

   /* Process inputs */

   /* Check # inputs */
   if(nrhs!=0) {
      mexErrMsgIdAndTxt("getDependencies:nrhs", "0 inputs required, %d found.",nrhs);
      return; }


   /* Process outputs */

   /* Check # outputs */
   if(nlhs!=2) {
      mexErrMsgIdAndTxt("getDependencies:nrhs", "2 outputs required, %d found.",nlhs);
      return; }

   /* output children */
   children=plhs+0;
   /* output parents */
   parents=plhs+1;

   /* Call function */
   if (!PgetDependencies4MEX) {
#ifdef __linux__
     libHandle = dlopen("/Users/hespanha/GitHub/tenscalc/lib/csparse/instructionsTable.so", RTLD_NOW);
     if (!libHandle) { printf("[%s] Unable to open library: %s\n",__FILE__, dlerror());return; }
     PgetDependencies4MEX = dlsym(libHandle, "getDependencies4MEX");
     if (!PgetDependencies4MEX) { printf("[%s] Unable to get symbol: %s\n",__FILE__, dlerror());return; }
#elif __APPLE__
     libHandle = dlopen("/Users/hespanha/GitHub/tenscalc/lib/csparse/instructionsTable.dylib", RTLD_NOW);
     if (!libHandle) { printf("[%s] Unable to open library: %s\n",__FILE__, dlerror());return; }
     PgetDependencies4MEX = dlsym(libHandle, "getDependencies4MEX");
     if (!PgetDependencies4MEX) { printf("[%s] Unable to get symbol: %s\n",__FILE__, dlerror());return; }
#elif _WIN32
     libHandle = LoadLibrary("/Users/hespanha/GitHub/tenscalc/lib/csparse/instructionsTable.dll");
     if (!libHandle) { printf("[%s] Unable to open library\n",__FILE__);return; }
     PgetDependencies4MEX = GetProcAddress(libHandle, "getDependencies4MEX");
     if (!PgetDependencies4MEX) { printf("[%s] Unable to get symbol\n",__FILE__);return; }
#endif // _WIN32
   }
   PgetDependencies4MEX(children,parents);
}
