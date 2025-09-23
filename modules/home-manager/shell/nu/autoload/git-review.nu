module "git-review extern" {
    # Submit changes to Gerrit for review
    export extern "git review" [
        branch?: string
        --download (-d): string           # Download the contents of a change into a branch
        --cherrypick (-x): string         # Apply the contents of a change onto the current branch
        --cherrypickindicate (-X): string # Apply the contents of a change onto the current branch, indicating its origin
        --cherrypickonly (-N): string     # Apply the contents of a change to the working directory, without committing
        --compare (-m): string            # Download two patchsets of a change into branches, rebase on main and show their differences

        --list (-l)             # List available reviews for the current project, if passed more than once, will show more information
        --setup (-s)            # Just run the repo setup commands but don't submit anything

        --topic (-t): string    # Topic to submit branch to
        --no-topic (-T)         # No topic except if explicitly provided (deprecated)
        --hashtags: string      # Hashtags to submit branch to
        --message: string       # Message to add to patchset description
        --private (-p)          # Send patch as a private patch ready for review
        --remove-private (-P)   # Send patch which already in private state to normal patch
        --wip                   # Send patch as work in progress
        --work-in-progress (-w) # Send patch as work in progress
        --ready (-W)            # Send patch that is already work in progress as ready for review
        --cc: string            # Add CC to uploaded patchsets
        --reviewers: string     # Add reviewers to uploaded patchsets
        --notify: string@notify # Control to whom email notifications are sent (default: 'ALL')

        --force-rebase (-F)     # Force and push a rebase even when not needed
        --no-rebase (-R)        # Don't test for remote merge conflicts before pushing
        --keep-rebase (-K)      # Keep the unfinished test rebase if a merge conflict is detected

        --finish (-f)           # Close down this branch and switch back to master on successful submission
        --new-changeid (-i)     # Regenerate Change-id before submitting
        --remote (-r): string   # Git remote to use for gerrit
        --remote-hook           # Fetch the remote version of the commit-msg hook
        --update (-u)           # Force updates from remote locations
        --yes (-y)              # Indicate that you do, in fact, understand if you are submitting more than one patch
        --no-thin               # 'git push' with '--no-thin'. This may work around issues with pushing in some circumstances
        --no-custom-script      # Do not run custom scripts
        --track                 # Use tracked branch as default
        --no-track              # Ignore tracked branch
        --use-pushurl           # Use remote push-url logic instead of separate remotes

        --color: string@color   # Show color output
        --no-color              # Turn off colored output. Can be used to override configuration options. Same as setting --color=never.
        --dry-run (-n)          # Don't actually submit the branch for review
        --verbose (-v)          # Output more information about what's going on
        --license               # Print the license and exit
        --version               # Show program's version number and exit
        --help (-h)             # Show this help message and exit
    ]

    def notify [] { [NONE OWNER OWNER_REVIEWERS ALL] }

    def color [] { [always never auto] }
}

use "git-review extern" "git review"
