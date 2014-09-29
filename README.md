Roslyn
======

Mono compatible copy of Roslyn Source Code

The build requires `master` Mono
`c5cf618a14711a2144b8a017ad0b61693253bd9c` or newer, but running
Roslyn requires at least `2a4230fe3bc7b1de30f2e2b8c49671b8ac128626`.

C# compiler
============

There are a few steps to getting the C# compiler to build on Mono:

## Manual changes needed

After succesfull package restore
`packages/Microsoft.Net.ToolsetCompilers.0.7.4090503-beta/build/Microsoft.Net.ToolsetCompilers.props`
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

## Install PCL

Download the
[PCL Reference Assemblies](http://www.microsoft.com/en-us/download/details.aspx?id=40727)
and copy the directory `v4.5/Profile/Profile7` into your Mono
installation as a subdirectory of
`$PREFIX/lib/mono/xbuild-frameworks/.NETPortable/v4.5/Profile/`.

## Run xbuild

The compiler can be build using xbuild with

    xbuild Src/Compilers/CSharp/csc/csc.csproj

The Roslyn compiler is called `csc.exe` and when built can be found in
the top level `Binaries/Debug` directory.

Workspaces
===========

Use `xbuild Src/Workspaces/CSharp/CSharpWorkspace.csproj` to build the C# workspace.
