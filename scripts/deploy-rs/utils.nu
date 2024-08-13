use std

# Completion function for arguments representing deploy-rs nodes
export def complete-node []: nothing -> list<string> {
    (
        do -c { ^nix eval '.#deploy.nodes' --apply builtins.attrNames --json }
        | complete | get stdout
        | from json
    )
}

export def get-profile-info [
    ...nodes: string@complete-node
    --flake: string = "."
]: nothing -> list<record> {
    let deploy = (eval-deploy --flake $flake)
    let deploy_cfg = ($deploy | get-level-connection-config)

    let profiles = (
        $deploy.nodes | items {|node_name, node|
            let node_cfg = ($node | get-level-connection-config)

            $node.profiles | items {|profile_name, profile|
                let profile_cfg = ($profile | get-level-connection-config)

                let conn_cfg = (get-connection-config $deploy_cfg $node_cfg $profile_cfg)
                let profile_path = (
                    get-profile-path $node_name $profile_name $conn_cfg.user $profile.profilePath?
                )

                {
                    node: $node_name
                    profile: $profile_name
                    hostname: $node.hostname
                    profile_path: $profile_path
                    ssh_user: $conn_cfg.ssh_user
                    ssh_opts: $conn_cfg.ssh_opts
                    user: $conn_cfg.user
                }
            }
        } | flatten
    )

    for node in $nodes {
        if ($profiles | std iter find { $in.node == $node }) == null {
            error make --unspanned { msg: $"No profiles defined for node ($node)" }
        }
    }

    match $nodes {
        [] => { $profiles }
        _ => { $profiles | where node in $nodes }
    }
}

def eval-deploy [--flake: string]: nothing -> record {
    # The `path` attribute of a profile is the only part of the `deploy` output that can be
    # expensive to evaluate, we can keep everything else.
    let remove_profile_path = '
        deploy: deploy // {
            nodes = builtins.mapAttrs (name: node: node // {
                profiles = builtins.mapAttrs (name: profile:
                    builtins.removeAttrs profile ["path"]
                ) node.profiles;
            }) deploy.nodes;
        }
    '
    do -c { ^nix eval $"($flake)#deploy" --apply $remove_profile_path --json } | from json
}

def get-level-connection-config []: record -> record {
    let level = $in
    {
        ssh_user: $level.sshUser?,
        ssh_opts: (match $level.sshOpts? { null => { [] }, $opts => { $opts } }),
        user: $level.user?,
    }
}

def get-connection-config [
    deploy_cfg: record, node_cfg: record, profile_cfg: record
]: nothing -> record {
    let configured_ssh_user = (
        [$profile_cfg.ssh_user $node_cfg.ssh_user $deploy_cfg.ssh_user]
        | std iter find { $in != null }
    )
    let ssh_user = ([$configured_ssh_user $env.USER?] | std iter find { $in != null })
    std assert not equal $ssh_user null

    let ssh_opts = ([$deploy_cfg.ssh_opts $node_cfg.ssh_opts $profile_cfg.ssh_opts] | flatten)

    let user = (
        [$profile_cfg.user $node_cfg.user $deploy_cfg.user $configured_ssh_user]
        | std iter find { $in != null }
    )
    std assert not equal $user null

    { ssh_user: $ssh_user, ssh_opts: $ssh_opts, user: $user }
}

def get-profile-path [
    node_name: string, profile_name: string, user: string, configured_path?: string
]: nothing -> string {
    match [$configured_path $user $profile_name] {
        [null "root" "system"] => { "/nix/var/nix/profiles/system" }
        [null "root" _] => { $"/nix/var/nix/profiles/per-user/root/($profile_name)" }
        [null $u $p] => {
            let n = $node_name
            error make {
                msg: $"Cannot determine profile path for a non-root user ($u)"
                help: (
                    $"Specify `deploy.nodes.($n).profiles.($p).profilePath` explicitly,"
                    + " instead of relying on the default, which is determined"
                    + " dynamically by looking at which paths exist on the host"
                )
            }
        }
        [$explicit_path _ _] => { $explicit_path }
    }
}
