# Push skills, agents and output styles from this repo's plugins/ into ~/.claude/, so they take effect locally.

const claude_dir = '~/.claude'

# Every skill/agent/output-style across all plugins, with its kind and source path
def list-items []: nothing -> table<name: string, kind: string, source: path> {
    let skills = (glob 'plugins/*/skills/*' | where ($it | path type) != file | each {|p|
        {name: ($p | path basename), kind: 'skills', source: $p}
    })
    # Why: a skill that spawns a named subagent is dead without it, so the pair has to
    # travel together — the plugin layout keeps them adjacent, this makes both deploy.
    let agents = (glob 'plugins/*/agents/*.md' | each {|p|
        {name: ($p | path parse | get stem), kind: 'agents', source: $p}
    })
    let output_styles = (glob 'plugins/*/output-styles/*.md' | each {|p|
        {name: ($p | path parse | get stem), kind: 'output-styles', source: $p}
    })
    $skills ++ $agents ++ $output_styles
}

def "nu-complete skill-items" []: nothing -> list<string> {
    list-items | get name
}

export def main [] { }

# Copy skills/agents/output-styles from plugins/ into ~/.claude/ (all, or one by name)
@example "Push everything" { nu toolkit.nu push }
@example "Push one skill" { nu toolkit.nu push 40-land-branch }
@example "Push one agent" { nu toolkit.nu push quote-digger }
export def 'main push' [
    name?: string@"nu-complete skill-items" # Only push this skill/agent/output-style; omit to push all
]: nothing -> nothing {
    let global_dir = $claude_dir | path expand
    let items = list-items | where { $name == null or $in.name == $name }

    if ($items | is-empty) {
        error make {msg: (
            if $name == null {
                'No skills, agents or output-styles found under plugins/'
            } else {
                $"No skill, agent or output-style named ($name)"
            }
        )}
    }

    for item in $items {
        let filename = if $item.kind == 'skills' { $item.name } else { $"($item.name).md" }
        let dest = $global_dir | path join $item.kind $filename
        let tmp = $"($dest)~"

        if ($tmp | path exists) { rm -rf $tmp }
        mkdir ($dest | path dirname)
        cp -r $item.source $tmp
        if ($dest | path exists) { rm -rf $dest }
        mv $tmp $dest

        print $"(ansi green)✓(ansi reset) ($item.kind)/($item.name)"
    }

    print $"\n(ansi attr_dimmed)Pushed ($items | length) item\(s\) to ($global_dir)(ansi reset)"
}
