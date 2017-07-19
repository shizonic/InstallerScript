
<h1> Archlinux Installer Script </h1>
<body>

<p> This script aims to give unattended installing of archlinux and user defined packages. All things are configured from setup.sh and defs. There are not many user promt. defs have the list of packages to be installed and services to enable. This is not targetted for beginner arch users. </p>

<h1>Direct Links</h1>
<p>
https://github.com/MMR-Burhan/InstallerScript/raw/master/setup.sh [ Shotened: <b>tiny.cc/ArchInstall</b> ]
</p>
<p>
https://github.com/MMR-Burhan/InstallerScript/raw/master/defs [ Shotened: <b>tiny.cc/defs</b> ]
</p>

<h1>How to use</h1>
<p>Boot into archiso</p>
<p>wget tiny.cc/ArchInstall</p>
<p>chmod +x ArchInstall</p>
<p>wget tiny.cc/defs</p>
<p>vim ArchInstall ( change according to your will)</p>
<p>vim defs ( define packages to be installed and more)</p>
<p>./ArchInstall</p>
</p>

<h1> Testing in VirtualBox </h1>
<p>To try out in Virtualbox extra 2 options needed to be enabled</p>
<ol>
<li>System->Motherboard->Enable EFI (Special OSes only)</li>
<li>System->Processor->Enable PAE/NX</li>
</ol>

</body>
