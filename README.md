Roslyn
======

Mono compatible copy of Roslyn Source Code

The build requires `master` Mono
`73bb10fff3d7b828c3508c4ab34126baa8345bd9` or newer.

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

## Manual changes needed

After succesfull package restore
`packages/Microsoft.Net.ToolsetCompilers.0.7.4101501-beta/build/Microsoft.Net.ToolsetCompilers.props`
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
