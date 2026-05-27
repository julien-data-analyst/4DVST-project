#!/usr/bin/env bash
# ─────────────────────────────────────────
# export_dashboards.sh
# Exporte les dashboards, questions et sources
# Metabase via l'API REST → dossier dashboards/
# ─────────────────────────────────────────
set -euo pipefail

METABASE_URL="${METABASE_URL:-http://localhost:3000}"
MB_USER="${MB_USER:-admin@example.com}"
MB_PASSWORD="${MB_PASSWORD:-yourpassword}"
EXPORT_DIR="$(dirname "$0")/dashboards"

mkdir -p "$EXPORT_DIR"/{dashboards,questions,sources}

echo ">>> Authentification sur $METABASE_URL..."
SESSION=$(curl -sf -X POST "$METABASE_URL/api/session" \
  -H "Content-Type: application/json" \
  -d "{\"username\": \"$MB_USER\", \"password\": \"$MB_PASSWORD\"}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")

echo ">>> Session : $SESSION"

AUTH_HEADER="X-Metabase-Session: $SESSION"

# ── Export des sources (databases) ───────
echo ">>> Export des sources..."
curl -sf "$METABASE_URL/api/database" \
  -H "$AUTH_HEADER" \
  | python3 -c "
import sys, json
data = json.load(sys.stdin)
dbs = data.get('data', data) if isinstance(data, dict) else data
for db in dbs:
    fname = '${EXPORT_DIR}/sources/db_' + str(db['id']) + '_' + db['name'].replace(' ','_') + '.json'
    with open(fname, 'w') as f:
        json.dump(db, f, indent=2, ensure_ascii=False)
    print('  Exporté :', fname)
"

# ── Export des questions (cards) ─────────
echo ">>> Export des questions..."
curl -sf "$METABASE_URL/api/card" \
  -H "$AUTH_HEADER" \
  | python3 -c "
import sys, json
cards = json.load(sys.stdin)
for card in cards:
    fname = '${EXPORT_DIR}/questions/card_' + str(card['id']) + '_' + card['name'].replace(' ','_')[:50] + '.json'
    with open(fname, 'w') as f:
        json.dump(card, f, indent=2, ensure_ascii=False)
    print('  Exporté :', fname)
"

# ── Export des dashboards ─────────────────
echo ">>> Export des dashboards..."
DASHBOARD_IDS=$(curl -sf "$METABASE_URL/api/dashboard" \
  -H "$AUTH_HEADER" \
  | python3 -c "import sys,json; [print(d['id']) for d in json.load(sys.stdin)]")

for ID in $DASHBOARD_IDS; do
  DASHBOARD=$(curl -sf "$METABASE_URL/api/dashboard/$ID" -H "$AUTH_HEADER")
  NAME=$(echo "$DASHBOARD" | python3 -c "import sys,json; print(json.load(sys.stdin)['name'].replace(' ','_')[:50])")
  FNAME="${EXPORT_DIR}/dashboards/dashboard_${ID}_${NAME}.json"
  echo "$DASHBOARD" | python3 -c "
import sys, json
data = json.load(sys.stdin)
with open('$FNAME', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
"
  echo "  Exporté : $FNAME"
done

echo ""
echo "✅ Export terminé dans $EXPORT_DIR"
echo "   Pensez à committer ce dossier dans votre dépôt Git."
