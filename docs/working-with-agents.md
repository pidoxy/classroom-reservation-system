# Working with an AI coding agent

You can build every step by hand, with an agent, or a mix. This repo is built so the agent is never the judge. The tests are.

## The loop

1. **Pick one step** from [build order](brief/build-order.md). One step per session.
2. **Give the agent the parts it needs, and only those**: the Brief page for the step, [`schema-contract.md`](schema-contract.md) or [`spec/openapi.yaml`](../spec/openapi.yaml), and the command that checks the step.
3. **Ask for a plan first.** Read it. If it touches things outside the step, cut them.
4. **Let it build, then run the check yourself.** Do not accept "it passes" from the agent. Run `./scripts/check-step1.sh` (or the conformance cases for later steps) and read the output.
5. **Review the diff** as if a stranger wrote it. Look for constraints missing their "only where active" condition, rules enforced only in code, and tests that were edited to pass.
6. **Commit the step on its own**, with a message that says what changed and which tests now pass.

## A good first message to an agent

> Build Step 1 from `docs/brief/build-order.md`. The contract is `docs/schema-contract.md`. Write plain SQL files in `db/migrations/`. Do not edit anything under `tests/`. When you finish, run `./scripts/check-step1.sh` and paste the full output. Do not claim success unless it exits 0.

## Rules that keep you in control

- **The agent never edits the tests.** If a test seems wrong, open an issue instead.
- **One step, one branch, one pull request.**
- **Show your evidence.** Paste the check output into the pull request.
- **Never paste secrets into a prompt.** The local database login is a throwaway, but any real key is not.
- **Write your own rules file.** In Week 5 you will write the instructions file your agent reads (some tools call it `AGENTS.md`). This repo does not ship one on purpose, so yours reflects how you work.

## Declare it

Every pull request says in one line whether an agent helped and what you checked yourself. That is not a penalty. It is how reviewers know where to look hardest.
