# Python starter

A connection check and a place to put your service. Nothing here decides how you build it. Use FastAPI, Flask, Django, or the standard library. The contract is [`spec/openapi.yaml`](../../spec/openapi.yaml), not a framework.

Full guide: [docs/languages/python.md](../../docs/languages/python.md).

```bash
cd implementations/python
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt
python check_db.py
```

Before Step 1 is done it tells you which tables are missing. After, it says all four exist.
