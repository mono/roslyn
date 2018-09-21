#!/usr/bin/env bash
# Copyright (c) .NET Foundation and contributors. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

set -e
set -u

build_configuration=${1:-Debug}
runtime=${2:-dotnet}

this_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${this_dir}"/build-utils.sh

root_path="$(get_repo_dir)"
binaries_path="${root_path}"/Binaries
unittest_dir="${binaries_path}"/"${build_configuration}"/UnitTests
log_dir="${binaries_path}"/"${build_configuration}"/xUnitResults
nuget_dir="${HOME}"/.nuget/packages
xunit_console_version="$(get_package_version dotnet-xunit)"

if [[ "${runtime}" == "dotnet" ]]; then
    target_framework=netcoreapp2.0
    xunit_console="${nuget_dir}"/xunit.runner.console/"${xunit_console_version}"/tools/${target_framework}/xunit.console.dll
elif [[ "${runtime}" == "mono" ]]; then
    target_framework=net461
    xunit_console="${nuget_dir}"/xunit.runner.console/"${xunit_console_version}"/tools/net452/xunit.console.exe
    mono_excluded_assemblies=(
        'Microsoft.CodeAnalysis.CSharp.Scripting.UnitTests.dll'
        'Roslyn.Compilers.CompilerServer.UnitTests.dll'
        # Missing mscoree.dll, other problems
        'Roslyn.Compilers.CSharp.Emit.UnitTests.dll'
        # Omitted because we appear to be missing things necessary to compile vb.net.
        # See https://github.com/mono/mono/issues/10679
        'Roslyn.Compilers.VisualBasic.CommandLine.UnitTests.dll'
        'Roslyn.Compilers.VisualBasic.Semantic.UnitTests.dll'
        # PortablePdb and lots of other problems
        'Microsoft.CodeAnalysis.VisualBasic.Scripting.UnitTests.dll'
        # GetSystemInfo is missing, and other problems
        # See https://github.com/mono/mono/issues/10678
        'Roslyn.Compilers.CSharp.WinRT.UnitTests.dll'
        # Many test failures
        'Roslyn.Compilers.UnitTests.dll'
        # Multiple test failures
        'Roslyn.Compilers.CSharp.CommandLine.UnitTests.dll'
        # Multiple test failures
        'Microsoft.Build.Tasks.CodeAnalysis.UnitTests.dll'
        # Various failures related to PDBs, along with a runtime crash
        'Roslyn.Compilers.CSharp.Emit.UnitTests.dll'
        # Deadlocks or hangs for some reason
        'Roslyn.Compilers.CompilerServer.UnitTests.dll'
        # Disabling on assumption
        'Roslyn.Compilers.VisualBasic.Emit.UnitTests.dll'
    )
else
    echo "Unknown runtime: ${runtime}"
    exit 1
fi

UNAME="$(uname)"
if [ "$UNAME" == "Darwin" ]; then
    runtime_id=osx-x64
elif [ "$UNAME" == "Linux" ]; then
    runtime_id=linux-x64
else
    echo "Unknown OS: $UNAME" 1>&2
    exit 1
fi

echo "Publishing ILAsm.csproj"
dotnet publish "${root_path}/src/Tools/ILAsm" --no-restore --runtime ${runtime_id} --self-contained -o "${binaries_path}/Tools/ILAsm"

echo "Using ${xunit_console}"

# Discover and run the tests
mkdir -p "${log_dir}"

was_argv_specified=0
single_test_name=${3:-}
[[ "${single_test_name}" != "" ]] && was_argv_specified=1

exit_code=0
for test_path in "${unittest_dir}"/*
do
    file_names=(${test_path}/${target_framework}/*.UnitTests.dll)
    fallback_file_names=(${test_path}/*.UnitTests.dll)

    if [ -f "${file_names[0]}" ]; then
        file_name=${file_names[0]}
    else
        if [ -f "${fallback_file_names[0]}" ]; then
            file_name=${fallback_file_names[0]}
        else
            continue
        fi
    fi

    file_base_name=$(basename "${file_name}")

    log_file="${log_dir}/${file_base_name}.xml"
    deps_json="${file_name%.*}".deps.json
    runtimeconfig_json="${file_name%.*}".runtimeconfig.json

    is_argv_match=0
    [[ "${file_name}" =~ "${single_test_name}" ]] && is_argv_match=1

    # If the user specifies a test on the command line, only run that one
    # "${3:-}" => take second arg, empty string if unset
    if (( was_argv_specified && ! is_argv_match ))
    then
        echo "Skipping ${file_base_name} to run single test"
        continue
    fi

    if [[ "${runtime}" == "dotnet" ]]; then
        runner="dotnet exec --depsfile ${deps_json} --runtimeconfig ${runtimeconfig_json}"
        if [[ "${file_name}" == *'Roslyn.Compilers.CSharp.Emit.UnitTests.dll' ]]
        then
            echo "Skipping ${file_base_name}"
            continue
        fi
    elif [[ "${runtime}" == "mono" ]]; then
        runner="mono --debug"
        is_blacklist_match=0
        [[ ("${mono_excluded_assemblies[*]}" =~ "${file_base_name}") ]] && is_blacklist_match=1
        if (( is_blacklist_match && ! ( is_argv_match && was_argv_specified ) ))
        then
            echo "Skipping blacklisted ${file_base_name}"
            continue
        fi
    fi
    
    echo Running "${runtime} ${file_base_name}"

    if ${runner} "${xunit_console}" "${file_name}" -xml "${log_file}"
    then
        echo "Assembly ${file_name} passed"
    else
        echo "Assembly ${file_name} failed"
        exit_code=1
    fi
done
exit ${exit_code}
