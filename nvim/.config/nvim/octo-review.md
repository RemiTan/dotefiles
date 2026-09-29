# Reviewing GitHub pull requests in Neovim

Octo.nvim uses the GitHub CLI. Install `gh` and sign in once with `gh auth
login` if you have not already. The config uses Telescope to pick pull
requests.

- `<leader>gp` lists pull requests for the current repository. Select one to
  open its PR conversation, including existing comments.
- `<leader>gV` opens the review diff for the PR associated with the current
  branch. This also works for a PR you authored, so you can work through your
  coworkers' review threads.
- In review mode, move through changed files with `]q` and `[q`. Put the cursor
  on a changed line and use `<localleader>ca` to add an inline comment. Save the
  comment buffer to add it to the pending review.
- Use `]t` and `[t` in the review diff to jump between existing comment threads.
  The thread appears beside the code; use `<localleader>cr` to reply, or
  `<localleader>r+`, `<localleader>rh`, and `<localleader>re` to react with 👍,
  ❤️, and 👀. Use `]c` and `[c` to move between comments in the open thread.
- `:Octo review comments` or `<leader>gC` jumps between comments you have
  drafted in your pending review; use `]t` and `[t` above for your coworkers'
  existing PR threads.
- To apply a requested code change, edit the checked-out PR branch in its normal
  file buffers, then return to the review diff to reply or resolve the thread.
- Run `:Octo review submit` to submit the review. In the prompt, `<C-m>` submits
  a comment-only review, `<C-a>` approves, and `<C-r>` requests changes.

You can also open a PR by URL with `:Octo https://github.com/owner/repo/pull/123`.
Run `:checkhealth octo` if GitHub authentication or plugin setup fails.
