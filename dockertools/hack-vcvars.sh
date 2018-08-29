#!/usr/bin/env bash
set -e

batfile="$1"

echo "$batfile"

# preserve a copy of the file pre-modifications
cp "$batfile" "$batfile.orig"

# workaround parentheses bug in wine's cmd
# see https://bugs.winehq.org/show_bug.cgi?id=43337
sed -i.bak 's/\(.*%ProgramFiles(x86)%.*\)//g' "$batfile"
sed -i.bak 's/\(\s*\)if exist .* set /\1set /g' "$batfile"
sed -i.bak 's/\(\s\)*if .*"" \(.*set\) /\1\2 /g' "$batfile"

# workaround for-loop bug in wine's cmd
# see https://bugs.winehq.org/show_bug.cgi?id=45722
sed -i.bak 's/^call :parse_loop/call :parse_argument %__VCVARSALL_ARGS_LIST%/g' "$batfile"

# workaround for-loop whitespace bug
# see https://bugs.winehq.org/show_bug.cgi?id=45731
sed -i.bak 's/\(for.*\)( '\''/\1('\''/g' "$batfile"
sed -i.bak 's/\(for.*\)'\'' )/\1'\'')/g' "$batfile"

# workaround trailing-slash bug in wine's cmd
# see https://bugs.winehq.org/show_bug.cgi?id=45725
sed -i.bak 's/\(.*if .*\)\\" /\1" /g' "$batfile"

# workaround REM bug in wine's cmd
# see https://bugs.winehq.org/show_bug.cgi?id=45729
sed -i.bak 's/\(.*\)@REM \(.*[|].*\)/\1REM \2/g' "$batfile"

# msvc bat file debugging
#sed -i.bak 's/echo off/echo on/g' "$batfile" && \
#sed -i.bak 's/@//g' "$batfile"

# cleanup
rm -f "$batfile.bak"
