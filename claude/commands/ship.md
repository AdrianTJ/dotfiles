---
description: Verify, commit as Adrian + Claude co-author, and push (no PR unless asked)
---

Ship the current work: $ARGUMENTS

1. **Verify first** — run /verify. If anything fails, stop and show me the
   failures instead of shipping.
2. **Branch check** — if on `main`/`master`, create a branch named after what
   the change actually does (e.g. `add-retry-backoff`), then continue there.
   If the current branch name is generic, tell me but proceed.
3. **Commit** — stage the relevant changes (not blindly `add -A` if there is
   unrelated noise), write a clear message describing the why, authored as
   Adrian TJ <adrian.tame.jacobo@gmail.com>, ending with:

   ```
   Co-Authored-By: Claude <noreply@anthropic.com>
   ```

4. **Push** the branch to origin.
5. **No PR** unless I explicitly asked for one in the arguments. If I did:
   describe the change plainly — no attribution or "Generated with" block.
