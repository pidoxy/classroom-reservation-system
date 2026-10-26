# JavaScript starter

A connection check and a place to put your service. Use Express, Fastify, Hono, Nest, or the built-in `http` module. The contract is [`spec/openapi.yaml`](../../spec/openapi.yaml), not a framework.

Full guide: [docs/languages/javascript.md](../../docs/languages/javascript.md).

```bash
cd implementations/javascript
npm install
npm run check-db
```

Before Step 1 is done it tells you which tables are missing. After, it says all four exist. Needs Node 20 or newer.
