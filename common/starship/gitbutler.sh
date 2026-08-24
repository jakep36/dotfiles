#!/bin/sh
# Starship custom module: describe a GitButler workspace.
#
# When HEAD is gitbutler/workspace, starship's git_branch would print the
# literal "gitbutler/workspace", which says nothing about the work in flight.
# This prints "<target> ← <stack>, <stack>" instead, naming the target branch
# the workspace is based on and the tip branch of every applied stack.
#
# Exits non-zero outside a GitButler workspace, so starship's `when` can gate
# the module and let git_branch render normally. Pass --check to do only that
# test and print nothing.
#
# Reads .git directly rather than shelling out to `but`, which kicks off
# background fetches and is far too slow to run on every prompt.

# Walk up for the git dir, without forking.
dir=$PWD
gitdir=
while :; do
	if [ -d "$dir/.git" ]; then
		gitdir=$dir/.git
		break
	elif [ -f "$dir/.git" ]; then
		# Linked worktree: ".git" holds "gitdir: <path>".
		read -r line <"$dir/.git" || break
		gitdir=${line#gitdir: }
		case $gitdir in /*) ;; *) gitdir=$dir/$gitdir ;; esac
		if [ -f "$gitdir/commondir" ]; then
			read -r common <"$gitdir/commondir" || break
			case $common in /*) gitdir=$common ;; *) gitdir=$gitdir/$common ;; esac
		fi
		break
	fi
	case $dir in "" | /) break ;; esac
	dir=${dir%/*}
done

[ -n "$gitdir" ] || exit 1
[ -f "$gitdir/gitbutler/virtual_branches.toml" ] || exit 1

read -r head <"$gitdir/HEAD" 2>/dev/null || exit 1
[ "$head" = "ref: refs/heads/gitbutler/workspace" ] || exit 1

[ "$1" = "--check" ] && exit 0

awk '
	# --- .git/config: pull the target branch out of [gitbutler "project"] ---
	FNR == NR {
		if ($0 ~ /^\[/) { section = $0 }
		if (section ~ /^\[gitbutler "project"\]/ && $0 ~ /^[ \t]*targetRef[ \t]*=/) {
			sub(/^[^=]*=[ \t]*/, "")
			target = $0
		}
		next
	}

	# --- virtual_branches.toml: applied stacks and their heads ---
	# Tables are [branches.<uuid>], [[branches.<uuid>.heads]] (ordered bottom
	# to top, so the last live one is the stack tip) and
	# [branches.<uuid>.heads.head].
	/^\[branches\.[^.]*\]$/ { ctx = "stack"; stack = $0; next }
	/^\[\[branches\..*\.heads\]\]$/ { ctx = "head"; name = ""; next }
	/^\[/ { ctx = ""; next }

	ctx == "stack" && $1 == "order" { order[stack] = $3 + 0; next }
	ctx == "stack" && $1 == "in_workspace" { applied[stack] = ($3 == "true"); next }

	ctx == "head" && $1 == "name" { name = value(); next }
	ctx == "head" && $1 == "archived" {
		# An archived head has landed upstream; it is not the tip any more.
		if ($3 != "true" && name != "") tip[stack] = name
		ctx = ""
		next
	}

	function value(  v) { v = $0; sub(/^[^=]*=[ \t]*"/, "", v); sub(/"[ \t]*$/, "", v); return v }

	END {
		sub(/^refs\/remotes\/[^\/]*\//, "", target)
		sub(/^refs\/heads\//, "", target)
		if (target == "") target = "?"

		n = 0
		for (s in tip) if (applied[s]) { n++; keys[n] = s }
		# Insertion sort on the stack order recorded in the TOML.
		for (i = 2; i <= n; i++) {
			k = keys[i]
			for (j = i - 1; j >= 1 && order[keys[j]] > order[k]; j--) keys[j + 1] = keys[j]
			keys[j + 1] = k
		}

		out = ""
		for (i = 1; i <= n; i++) out = out (i > 1 ? ", " : "") tip[keys[i]]
		if (out == "") out = "(no stacks)"
		print target " ← " out
	}
' "$gitdir/config" "$gitdir/gitbutler/virtual_branches.toml"
