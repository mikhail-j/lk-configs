#!/bin/sh
# Checks if your C compiler in PATH is retpoline capable.
#
# Copyright (C) 2018 Qijia (Michael) Jin
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

check_compiler_flags() {
	$CC -Werror -mindirect-branch=thunk-extern -mindirect-branch-register -E -x c /dev/null -o /dev/null >/dev/null 2>&1
	RETPOLINE_GCC_FLAGS_EXIT_CODE=$?

	$CC -Werror -mretpoline-external-thunk -E -x c /dev/null -o /dev/null >/dev/null 2>&1
	RETPOLINE_CLANG_FLAGS_EXIT_CODE=$?
	
	CC_VERSION_STRING=$($CC --version | head -n 1)

	if test $RETPOLINE_GCC_FLAGS_EXIT_CODE -eq 0; then
		echo $CC_VERSION_STRING" supports retpoline!"
		exit $RETPOLINE_GCC_FLAGS_EXIT_CODE
	else
		if test $RETPOLINE_CLANG_FLAGS_EXIT_CODE -eq 0; then
			echo $CC_VERSION_STRING" supports retpoline!"
			exit $RETPOLINE_CLANG_FLAGS_EXIT_CODE=$?
		else
			echo $CC_VERSION_STRING" does not support retpoline!"
			exit $RETPOLINE_GCC_FLAGS_EXIT_CODE
		fi
	fi
}

if test -z $CC; then
	echo "The environmental variable 'CC' is not set!"
	echo "Attempting to find C compiler in PATH..."

	FIND_GCC=$(command -v gcc >/dev/null 2>&1)
	FIND_GCC_EXIT_CODE=$?
	if test $FIND_GCC_EXIT_CODE -ne 0; then
		FIND_CLANG=$(command -v clang >/dev/null 2>&1)
		FIND_CLANG_EXIT_CODE=$?
		if test $FIND_CLANG_EXIT_CODE -ne 0; then
			echo "Error: C compiler not found in PATH!"
		else
			CC="clang"
		fi
	else
		CC="gcc"
	fi
fi

check_compiler_flags
