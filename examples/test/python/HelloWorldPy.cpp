#include <Python.h>

extern "C" {
    static PyObject* helloworld(PyObject* self) {
       return Py_BuildValue("s", "Hello World from Python Extensions!");
    }

    static char helloworld_docs[] =
       "helloworld( ): Any message you want to put here!!\n";

    static PyMethodDef helloworld_funcs[] = {
       {"helloworld", (PyCFunction)helloworld, 
          METH_NOARGS, helloworld_docs},
          {NULL}
    };

    PyMODINIT_FUNC
    inithelloworld(void) {
       Py_InitModule3("helloworld", helloworld_funcs,
                      "Extension module example!");
    }
}
