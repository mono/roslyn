Roslyn
======

Mono compatible copy of Roslyn Source Code

The build requires `master` Mono
`f7765134889fe84ad97d92c9d6326a803a4f9f2b` or newer.

C# compiler
============

There are a few steps required to build Roslyn on Mono:

## Install PCL

Download the
[PCL Reference Assemblies Windows Installer](http://www.microsoft.com/en-us/download/details.aspx?id=40727) or [PCL Reference Assemblies zip file](http://storage.bos.xamarin.com/bot-provisioning/PortableReferenceAssemblies-2014-04-14.zip)
and copy the directory `v4.5/Profile/Profile7` into your Mono
installation as a subdirectory of
`$PREFIX/lib/mono/xbuild-frameworks/.NETPortable/v4.5/Profile/`.

## Restore packages

	`mono Src/.nuget/NuGet.exe restore Src/Roslyn.sln`

(Remember to run mozroots if you haven't already, e.g., if you're building on
a fresh VM.  Otherwise, NuGet `restore` may fail with a "SendFailure (Error
writing headers)" error.  `mozroots --import --sync` is one way to remedy
this.)

## Manual changes needed

After succesfull package restore
`packages/Microsoft.Net.ToolsetCompilers.1.0.0-beta2-20141216-04/build/Microsoft.Net.ToolsetCompilers.props`
has to be replaced with

```xml
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <DisableRoslyn>true</DisableRoslyn>
    <CscToolPath Condition=" '$(OS)' == 'Windows_NT'">$(MSBuildThisFileDirectory)..\tools</CscToolPath>
    <CscToolExe Condition=" '$(OS)' == 'Windows_NT'">csc2.exe</CscToolExe>
    <VbcToolPath>$(MSBuildThisFileDirectory)..\tools</VbcToolPath>
    <VbcToolExe>vbc2.exe</VbcToolExe>
  </PropertyGroup>
</Project>
```

## Build FakeSign tool

FakeSign tool is needed during build and needs to be build as first step

    xbuild Src/Tools/Source/FakeSign/FakeSign.csproj

## Build C# compiler

The compiler can be built using following xbuild command line 

    xbuild Src/Compilers/CSharp/csc/csc.csproj

The Roslyn compiler is called `csc.exe` and once built it can be found in
the top level `Binaries/Debug` directory.

## Build C# workspace (optional)

    xbuild Src/Workspaces/CSharp/Portable/CSharpWorkspace.csproj
