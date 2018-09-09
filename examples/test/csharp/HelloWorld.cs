using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;

namespace HelloWorld
{
    class Hello
    {
        [DllImport("HelloWorld")]
        private static extern IntPtr helloWorld();

        static void Main()
        {
            String str= Marshal.PtrToStringAnsi(helloWorld());
            Console.WriteLine(str + " Is64BitProcess=" + Environment.Is64BitProcess + " IsMono=" + IsMono());
        }

        public static bool IsMono()
        {
            return Type.GetType ("Mono.Runtime") != null;
        }
    }
}
