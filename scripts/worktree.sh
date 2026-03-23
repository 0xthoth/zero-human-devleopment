#!/usr/bin/env bash
# Git Worktree helper for multi-agent parallel development
# Usage:
#   worktree.sh create <agent> <branch> [base]   — create worktree from base (default: origin/master)
#   worktree.sh remove <agent>                    — remove worktree and delete branch
#   worktree.sh list                              — list active worktrees
#   worktree.sh clean                             — remove all agent worktrees

set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-$HOME/project}"
WORKTREE_DIR="${WORKTREE_DIR:-$HOME/worktrees}"

cmd="${1:-help}"
shift || true

case "$cmd" in
  create)
    agent="${1:?Usage: worktree.sh create <agent> <branch> [base]}"
    branch="${2:?Usage: worktree.sh create <agent> <branch> [base]}"
    base="${3:-origin/master}"
    wt_path="$WORKTREE_DIR/$agent"

    # Fetch latest
    cd "$PROJECT_DIR"
    git fetch origin

    # Remove existing worktree if any
    if [ -d "$wt_path" ]; then
      echo "⚠️  Removing existing worktree at $wt_path"
      git worktree remove "$wt_path" --force 2>/dev/null || rm -rf "$wt_path"
      git branch -D "$branch" 2>/dev/null || true
    fi

    # Create worktree
    mkdir -p "$WORKTREE_DIR"
    git worktree add -b "$branch" "$wt_path" "$base"

    # Set git identity based on agent name
    cd "$wt_path"
    case "$agent" in
      frontend) git config user.name "Frontend Dev" && git config user.email "frontend@team.com" ;;
      backend)  git config user.name "Backend Dev"  && git config user.email "backend@team.com" ;;
      tester)   git config user.name "Tester"       && git config user.email "tester@team.com" ;;
      qa)       git config user.name "QA Lead"      && git config user.email "qa@team.com" ;;
      *)        git config user.name "$agent"       && git config user.email "$agent@team.com" ;;
    esac

    # Install dependencies
    echo "📦 Installing dependencies..."
    pnpm install --frozen-lockfile 2>/dev/null || pnpm install

    echo ""
    echo "✅ Worktree ready!"
    echo "   Path:   $wt_path"
    echo "   Branch: $branch"
    echo "   Base:   $base"
    echo "   Git:    $(git config user.name) <$(git config user.email)>"
    ;;

  remove)
    agent="${1:?Usage: worktree.sh remove <agent>}"
    wt_path="$WORKTREE_DIR/$agent"

    cd "$PROJECT_DIR"

    if [ -d "$wt_path" ]; then
      # Get branch name before removing
      branch=$(git -C "$wt_path" branch --show-current 2>/dev/null || echo "")
      git worktree remove "$wt_path" --force 2>/dev/null || rm -rf "$wt_path"
      echo "✅ Worktree removed: $wt_path"

      # Optionally delete branch if merged
      if [ -n "$branch" ] && [ "$branch" != "master" ] && [ "$branch" != "main" ]; then
        echo "ℹ️  Branch '$branch' still exists locally. Delete with: git branch -D $branch"
      fi
    else
      echo "⚠️  No worktree found at $wt_path"
    fi
    ;;

  list)
    cd "$PROJECT_DIR"
    echo "📂 Active worktrees:"
    git worktree list
    ;;

  clean)
    cd "$PROJECT_DIR"
    echo "🧹 Cleaning all agent worktrees..."
    for dir in "$WORKTREE_DIR"/*/; do
      [ -d "$dir" ] || continue
      agent=$(basename "$dir")
      echo "  Removing: $agent"
      git worktree remove "$dir" --force 2>/dev/null || rm -rf "$dir"
    done
    echo "✅ All agent worktrees removed"
    ;;

  help|*)
    echo "Git Worktree Helper for Multi-Agent Development"
    echo ""
    echo "Usage:"
    echo "  worktree.sh create <agent> <branch> [base]  — create worktree"
    echo "  worktree.sh remove <agent>                   — remove worktree"
    echo "  worktree.sh list                             — list worktrees"
    echo "  worktree.sh clean                            — remove all worktrees"
    echo ""
    echo "Examples:"
    echo "  worktree.sh create frontend feat/fe-health"
    echo "  worktree.sh create backend feat/be-auth origin/main"
    echo "  worktree.sh remove frontend"
    echo ""
    echo "Environment:"
    echo "  PROJECT_DIR   — main repo path (default: ~/project)"
    echo "  WORKTREE_DIR  — worktrees root (default: ~/worktrees)"
    ;;
esac
