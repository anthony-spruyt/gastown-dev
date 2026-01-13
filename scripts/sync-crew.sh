#!/bin/bash
set -euo pipefail

WORKSPACE="/workspaces/gastown-dev"
GT_ROOT="$WORKSPACE/gt"

echo "Syncing crew workspaces with remote..."
echo

# Find all crew folders across all rigs
# Pattern: gt/<rig>/crew/<name>/
crew_folders=()
for rig_dir in "$GT_ROOT"/*/; do
    rig_dir="${rig_dir%/}"  # Remove trailing slash
    rig_name=$(basename "$rig_dir")
    # Skip non-rig directories
    [[ "$rig_name" == ".beads" ]] && continue
    [[ "$rig_name" == ".claude" ]] && continue
    [[ "$rig_name" == "daemon" ]] && continue
    [[ "$rig_name" == "deacon" ]] && continue
    [[ "$rig_name" == "logs" ]] && continue
    [[ "$rig_name" == "mayor" ]] && continue
    [[ "$rig_name" == "plugins" ]] && continue
    [[ "$rig_name" == "settings" ]] && continue

    crew_dir="$rig_dir/crew"
    if [ -d "$crew_dir" ]; then
        for crew_member in "$crew_dir"/*/; do
            crew_member="${crew_member%/}"  # Remove trailing slash
            [ -d "$crew_member/.git" ] || [ -f "$crew_member/.git" ] && crew_folders+=("$crew_member")
        done
    fi
done

if [ ${#crew_folders[@]} -eq 0 ]; then
    echo "No crew workspaces found."
    exit 0
fi

echo "Found ${#crew_folders[@]} crew workspace(s):"
for folder in "${crew_folders[@]}"; do
    echo "  - $folder"
done
echo

# Sync each crew folder
success=0
failed=0
skipped=0

for folder in "${crew_folders[@]}"; do
    rel_path="${folder#$GT_ROOT/}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Syncing: $rel_path"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    cd "$folder"

    # Check current branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "")
    if [ -z "$current_branch" ]; then
        echo "  ⚠ Not on a branch (detached HEAD?) - skipping"
        skipped=$((skipped + 1))
        continue
    fi
    echo "  Branch: $current_branch"

    # Check for uncommitted changes
    has_changes=false
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
        has_changes=true
        echo "  Stashing local changes..."
        if ! git stash push -m "sync-crew auto-stash $(date +%Y-%m-%d_%H:%M:%S)"; then
            echo "  ✗ Failed to stash changes"
            failed=$((failed + 1))
            continue
        fi
    fi

    # Fetch from origin
    echo "  Fetching from origin..."
    if ! git fetch origin 2>/dev/null; then
        echo "  ✗ Failed to fetch"
        # Pop stash if we stashed
        [ "$has_changes" = true ] && git stash pop --quiet 2>/dev/null || true
        failed=$((failed + 1))
        continue
    fi

    # Rebase on origin/main (or origin/<current_branch>)
    rebase_target="origin/main"
    if git rev-parse --verify "origin/$current_branch" &>/dev/null; then
        rebase_target="origin/$current_branch"
    fi

    echo "  Rebasing on $rebase_target..."
    if ! git rebase "$rebase_target" 2>/dev/null; then
        echo "  ✗ Rebase failed - aborting and restoring state"
        git rebase --abort 2>/dev/null || true
        [ "$has_changes" = true ] && git stash pop --quiet 2>/dev/null || true
        failed=$((failed + 1))
        continue
    fi

    # Pop stash if we stashed
    if [ "$has_changes" = true ]; then
        echo "  Restoring local changes..."
        if ! git stash pop 2>/dev/null; then
            echo "  ⚠ Stash pop had conflicts - changes in stash@{0}"
            failed=$((failed + 1))
            continue
        fi
    fi

    echo "  ✓ Synced successfully"
    success=$((success + 1))
done

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Sync complete: $success succeeded, $failed failed, $skipped skipped"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ $failed -eq 0 ] || exit 1
