Roslyn
======
 
Mono compatible copy of Roslyn Source Code

The build requires master mono cd95b8238f25cc1de0e6c7844596cbfdcc10023d or newer
 
C# compiler
============

The compiler can be build using xbuild as `xbuild Src/Compilers/CSharp/csc/csc.csproj'
 
Roslyn compiler is called rcsc.exe and when built with make it can be found in top level Binaries folder

Workspaces
===========

Use `xbuild Src/Workspaces/CSharp/CSharpWorkspace.csproj' to build C# workspace


Manual changes needed
======================

After succesfull package restore `Src/packages/Microsoft.Net.ToolsetCompilers.0.7.4032713-beta/build/Microsoft.Net.ToolsetCompilers.props' has to be replaced with
```xml
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <DisableRoslyn>true</DisableRoslyn>
    <CscToolPath Condition=" '$(OS)' == 'Windows_NT'">$(MSBuildThisFileDirectory)..\tools</CscToolPath>
    <CscToolExe Condition=" '$(OS)' == 'Windows_NT'">rcsc2.exe</CscToolExe>
    <VbcToolPath>$(MSBuildThisFileDirectory)..\tools</VbcToolPath>
    <VbcToolExe>rvbc2.exe</VbcToolExe>
  </PropertyGroup>
</Project>
