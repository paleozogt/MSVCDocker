#include <tcl.h>

#if defined(_WIN32)
#   define EXPORT __declspec(dllexport)
#else
#   define EXPORT
#endif

extern "C" {
    static int helloworldCmd(ClientData d, Tcl_Interp *interp,
                             int objc, const char **objv)
    {
        Tcl_SetResult(interp, "Hello World from TCL!", NULL);
        return TCL_OK;
    }

    EXPORT int Helloworld_Init(Tcl_Interp *interp) {
        Tcl_CreateCommand(interp, "helloWorld", helloworldCmd, NULL, NULL);

        return TCL_OK;
    }

    EXPORT int Helloworld_SafeInit(Tcl_Interp *interp) {
      return Helloworld_Init(interp);
    }    
}
