# Two-line prompt:
#   worktree/sub/dir branch ✗
#   ➜
function fish_prompt
    set -l last_status $status

    set -l cyan (set_color -o cyan)
    set -l yellow (set_color -o yellow)
    set -l red (set_color -o red)
    set -l green (set_color -o green)
    set -l blue (set_color -o blue)
    set -l normal (set_color --reset)

    # --show-toplevel is the root of the current worktree, not the main checkout
    set -l git_info (command git rev-parse --show-toplevel --show-prefix 2>/dev/null)
    if set -q git_info[1]
        set -l worktree (path basename $git_info[1])
        # Path inside the worktree, with all but the last directory abbreviated
        set -l subdir (string split -n / -- "$git_info[2]")
        if set -q subdir[2]
            set subdir[1..-2] (string sub -l 1 -- $subdir[1..-2])
        end
        set -l location $cyan(string join / -- $worktree $subdir)

        set -l branch (command git symbolic-ref --quiet --short HEAD 2>/dev/null)
        or set branch (command git rev-parse --short HEAD 2>/dev/null)

        set -l branch_info
        # Worktrees are usually named after their branch; don't print it twice
        if test "$branch" != "$worktree"
            set branch_info " $blue$branch"
        end

        set -l dirty
        if not command git diff-index --quiet HEAD -- &>/dev/null
            set dirty " $yellow✗"
        end

        echo -s $location $branch_info $dirty $normal
    else
        echo -s $cyan(prompt_pwd) $normal
    end

    set -l arrow_color $green
    if test $last_status -ne 0
        set arrow_color $red
    end
    set -l arrow ➜
    if fish_is_root_user
        set arrow '#'
    end
    echo -n -s $arrow_color $arrow ' ' $normal
end
