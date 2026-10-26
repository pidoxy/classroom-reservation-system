# Repository guidelines

How the whole repository is organised and how we work in it. Short on purpose. If a rule here gets in your way, open an issue and say why.

## 1. What belongs where

| Path | Holds | Who changes it |
| --- | --- | --- |
| `docs/brief/` | The Build Brief: requirements, data model, interfaces, edge cases | Maintainers, through an issue first |
| `docs/` (other) | Guides: schema contract, languages, agents, these guidelines | Anyone, by pull request |
| `spec/` | The machine-readable contract: `openapi.yaml`, `policy.yaml` | Maintainers, through an issue first |
| `tests/step-1/` | Plain SQL and pgbench checks for the database | Maintainers; additions welcome |
| `tests/acceptance/` | The acceptance tests as data | Maintainers |
| `tests/conformance/` | Language-free HTTP cases for steps 2 to 9 | Anyone |
| `db/migrations/` | Your schema, applied in filename order | You, in your fork |
| `scripts/` | Bash helpers that work for any language | Anyone, by pull request |
| `implementations/<language>/` | A starter for one language | The person adding that language |

Rule of thumb: the **contract** (Brief, spec, tests) is shared and changes slowly. **Implementations** are yours and change quickly.

## 2. The contract comes first

- A change to behaviour starts as a change to the Brief or spec, then the tests, then code. Never the other way round.
- Tests are never edited to make code pass. If a test is wrong, open an issue that names the test and the Brief line it contradicts.
- Every refusal uses the shape `{ "error": "<CODE>", "message": "...", "details": {} }`. The `error` code is the contract.

## 3. Branches and commits

- Branch from `main`. Name branches `type/short-description`, for example `docs/fix-typo-data-model` or `case/t-r6-conformance`.
- Student work lives in your fork. Branch per step: `step-1-schema`, `step-3-booking`.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org): `feat:`, `fix:`, `docs:`, `test:`, `chore:`. Write in the imperative: `feat: add exclusion constraint on bookings`.
- One logical change per commit. A commit that says "stuff" will be asked to be reworded.

## 4. Pull requests

- Keep them small. Under about 400 changed lines is easy to review; above that, split.
- One pull request does one thing: one step, one doc fix, one conformance case.
- Fill in the template. Include the output of the check you ran.
- Say in one line whether an AI agent helped and what you verified yourself.
- Reviews are about the work, not the person. Ask questions before making claims.

## 5. Tests and evidence

- Step 1 is proved by `./scripts/check-step1.sh` exiting 0.
- Later steps are proved by conformance cases passing against your running service.
- "It works on my machine" is not evidence. Pasted output is.

## 6. Secrets and safety

- Never commit a real password, token, or key. `.env` files are ignored by git.
- The only credentials in this repo are the local throwaway `postgres` / `postgres` database login in `docker-compose.yml`. They work on your own machine only.
- `./scripts/db-reset.sh` refuses to run against any host except `localhost`. Do not remove that guard.

## 7. Style

- Plain language in docs. Short sentences. Define a term the first time it appears.
- Markdown: one `#` heading per file, tables for comparisons, fenced code blocks with a language.
- SQL: lowercase keywords are fine, but be consistent within a file.
- Bash: `set -euo pipefail`, quote variables, no bashisms beyond bash 4.
- Respect `.editorconfig`.

## 8. Language neutrality

Nothing outside `implementations/` and `docs/languages/` may require a particular programming language. If you add a script or check, it must work with only `bash`, `psql`, `pgbench` (or Docker), and an HTTP tool.
