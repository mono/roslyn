#!/bin/sh

./build/scripts/obtain_dotnet.sh

export PATH=Binaries/dotnet-cli:$PATH

./build/scripts/restore.sh

dotnet restore Compilers.sln
# How to build  -f net461 only?
dotnet build Compilers.sln

mkdir -p mono-tests

# TODO: Need to copy from roslyn-binaries
cp Binaries/Debug/Dlls/CSharpCodeAnalysis/Microsoft.CodeAnalysis.CSharp.dll mono-tests/
cp Binaries/Debug/Dlls/CodeAnalysis/Microsoft.CodeAnalysis.dll mono-tests/
cp Binaries/Debug/Dlls/Scripting/Microsoft.CodeAnalysis.Scripting.dll mono-tests/
cp Binaries/Debug/Dlls/CSharpScripting/Microsoft.CodeAnalysis.CSharp.Scripting.dll mono-tests/
cp Binaries/Debug/Exes/csc/net46/System.Collections.Immutable.dll mono-tests/
cp Binaries/Debug/Exes/csc/net46/System.Reflection.Metadata.dll mono-tests/
cp Binaries/Debug/Exes/VBCSCompiler/net46/VBCSCompiler.exe mono-tests/

#TODO: Some tests still depend on it
cp Binaries/Debug/Exes/vbc/net46/Microsoft.CodeAnalysis.VisualBasic.dll  mono-tests/

cp Binaries/Debug/Dlls/CSharpCompilerTestUtilities/Roslyn.Compilers.CSharp.Test.Utilities.??? mono-tests/
cp Binaries/Debug/Dlls/TestUtilities/net461/Roslyn.Test.Utilities.??? mono-tests/
cp Binaries/Debug/Dlls/TestUtilities/net461/Microsoft.CodeAnalysis.Test.Resources.Proprietary.??? mono-tests/
cp Binaries/Debug/Dlls/CompilerTestResources/Roslyn.Compilers.Test.Resources.??? mono-tests/
cp Binaries/Debug/Dlls/TestUtilities.Desktop/Microsoft.Metadata.Visualizer.??? mono-tests/
cp Binaries/Debug/Dlls/ScriptingTestUtilities/Microsoft.CodeAnalysis.Scripting.TestUtilities.??? mono-tests/
cp Binaries/Debug/Dlls/TestUtilities/net461/Microsoft.CodeAnalysis.Test.Resources.Proprietary.??? mono-tests/
cp Binaries/Debug/Dlls/CSharpCompilerTestUtilities/Roslyn.Compilers.CSharp.Test.Utilities.??? mono-tests/
cp Binaries/Debug/Dlls/PdbUtilities/Roslyn.Test.PdbUtilities.??? mono-tests/
cp Binaries/Debug/Dlls/TestUtilities/net461/Microsoft.DiaSymReader.??? mono-tests/
cp Binaries/Debug/UnitTests/CSharpScriptingTest/net461/Microsoft.DiaSymReader.Converter.??? mono-tests/
cp Binaries/Debug/Dlls/TestUtilities.Desktop/Roslyn.Test.Utilities.Desktop.??? mono-tests/
cp Binaries/Debug/Dlls/CSharpCompilerTestUtilities.Desktop/Roslyn.Compilers.CSharp.Test.Utilities.Desktop.??? mono-tests/
cp Binaries/Debug/Dlls/TestUtilities/net461/Microsoft.DiaSymReader.PortablePdb.??? mono-tests/

cp Binaries/Debug/Dlls/TestUtilities/net461/Microsoft.DiaSymReader.Converter.Xml.??? mono-tests/

cp Binaries/Debug/UnitTests/CSharpCompilerEmitTest/Roslyn.Compilers.CSharp.Emit.UnitTests.??? mono-tests/
cp Binaries/Debug/UnitTests/CSharpCodeStyleTests/net461/Microsoft.CodeAnalysis.CSharp.CodeStyle.UnitTests.??? mono-tests/
cp Binaries/Debug/UnitTests/CSharpCompilerSymbolTest/net461/ref/Roslyn.Compilers.CSharp.Symbol.UnitTests.??? mono-tests/
cp Binaries/Debug/UnitTests/CodeStyleTests/net461/Microsoft.CodeAnalysis.CodeStyle.UnitTests.??? mono-tests/
cp Binaries/Debug/UnitTests/ScriptingTest/net461/Microsoft.CodeAnalysis.Scripting.UnitTests.??? mono-tests/
cp Binaries/Debug/UnitTests/CSharpCompilerSyntaxTest/net461/Roslyn.Compilers.CSharp.Syntax.UnitTests.??? mono-tests/
cp Binaries/Debug/UnitTests/VBCSCompilerTests/net461/Roslyn.Compilers.CompilerServer.UnitTests.??? mono-tests/
cp Binaries/Debug/UnitTests/CSharpScriptingTest/net461/Microsoft.CodeAnalysis.CSharp.Scripting.UnitTests.??? mono-tests/
cp Binaries/Debug/UnitTests/CSharpCompilerSemanticTest/Roslyn.Compilers.CSharp.Semantic.UnitTests.??? mono-tests/

cp Binaries/Debug/Dlls/TestUtilities.Desktop/xunit.*.dll mono-tests/

cd mono-tests/

## We run everything under src/Compilers/CSharp/Test

XUNIT=$1
if [ -z "$1" ] ; then
XUNIT="mono --debug ~/git/mono/mono/external/xunit-binaries/xunit.console.exe"
fi

eval "$XUNIT" Roslyn.Compilers.CSharp.Syntax.UnitTests.dll

# Failed: 59
#eval "$XUNIT" Roslyn.Compilers.CSharp.Semantic.UnitTests.dll

#eval "$XUNIT" Roslyn.Compilers.CSharp.Symbol.UnitTests.dll
#eval "$XUNIT" Roslyn.Compilers.CSharp.Emit.UnitTests.dll  -parallel none

#eval "$XUNIT" Microsoft.CodeAnalysis.CSharp.Scripting.UnitTests.dll

## Pipes are not yet working on Mono
# eval "$XUNIT" Roslyn.Compilers.CompilerServer.UnitTests.dll
