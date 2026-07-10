## Installing Hermes

1) add to.env with
```
OPENROUTER_API_KEY
API_SERVER_KEY
CLAWHUB_API_KEY
```

2) build with

```
docker compose build
```

3) configure openai

In the list of Settings -> Admin Settings -> Web Search

Web search -> True
Web search engine -> SearXNG
http://searxng-core:8080
Bypass embedding and retrieval -> true
Bypass web loader -> True

4) To configure openclaw configure
```
docker compose run -ti --rm --remove-orphans openclaw openclaw configure
```
