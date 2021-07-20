$source=@'

using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public class Timer
    {
        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern bool GetProcessTimes(IntPtr handle, out long creation, out long exit, out long kernel,
                                                  out long user);

        public static void Time(string file,string args)
        {
            long user,kernel,exit,creation;
            Process proc = null;
            proc = Process.Start(file,args);
            proc.WaitForExit();
            GetProcessTimes(proc.Handle, out creation, out exit, out kernel, out user);
            long real = exit - creation;
            Console.WriteLine("real {0}\nuser {1}\nsys {2}", real / 10000000.0, user/10000000.0,kernel/10000000.0);
        }
    }
'@

Add-Type -TypeDefinition $source -Language CSharp

function time ($scriptblock) {

    $file = "powershell";
    $args = $scriptblock;

    $startInfo = new-object Diagnostics.ProcessStartInfo;
    $startInfo.FileName = $file;
    $startInfo.Arguments = $args;
    $startInfo.CreateNoWindow = $true;
    $startInfo.UseShellExecute = $false;
    $startInfo.RedirectStandardOutput = $true;
    $process = [Diagnostics.Process]::Start($startInfo);
    $process.WaitForExit();
    write-host $process.StandardOutput.ReadToEnd();
    write-host real: ($process.ExitTime - $process.StartTime)
    write-host user: $process.UserProcessorTime;
    write-host sys:  $process.PrivilegedProcessorTime;
    write-host using GetProcessTimes
    #[Timer]::Time($file,$args)
}
