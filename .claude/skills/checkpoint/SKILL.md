---
description: Commit, tag and push the current iteration after I've reviewed the diff
argument-hint: "[iteration-number] [focus]"
disable-model-invocation: true
allowed-tools: Bash(git *)
---
Show `git status --short` and `git diff --stat`. Then run:
git add -A && git commit -m "Iteration $ARGUMENTS" && git tag iter-$0 && git push && git push --tags
Report the commit hash and tag. Do not modify any files.
