#!/usr/bin/env bash
#
# EVREN LLM API'sini OpenCode'a tanıtan kurulum betiği.
#
# Kullanım:
#   bash kur.sh
#
# Yaptıkları:
#   1. API anahtarını gizli olarak sorar (ekranda görünmez).
#   2. Anahtarı ve adresi EVREN'e karşı doğrular.
#   3. Kullanım şartları kabul edilmemişse metni indirir, onayını alır ve onaylar.
#   4. Anahtarı ~/.config/opencode/.evren-key dosyasına yazar (chmod 600).
#   5. /v1/models listesinden sohbet modellerini çekip OpenCode config'ini üretir.
#
# Gerekenler: bash, curl, python3 (Windows’ta Git Bash + python)

set -euo pipefail

# sh ile çalıştırılsa bile bash'e geç.
if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi

BASE_URL="https://evren-llmapi.ssyz.org.tr/v1"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
CONFIG_FILE="$CONFIG_DIR/opencode.json"
JSONC_FILE="$CONFIG_DIR/opencode.jsonc"
KEY_FILE="$CONFIG_DIR/.evren-key"
TERMS_FILE="$CONFIG_DIR/evren-kullanim-sartlari.md"

die() {
  printf '\nHata: %s\n' "$*" >&2
  if [ -t 0 ] && [ -t 1 ]; then
    read -r -p "Kapatmak için Enter'a bas..." _ || true
  fi
  exit 1
}

need() {
  command -v "$1" >/dev/null 2>&1 || die "'$1' bulunamadı. Lütfen kurup tekrar dene."
}

printf '\nEVREN → OpenCode kurulumu\n'
printf '=========================\n\n'

need curl
# Windows'ta (Git Bash) komut 'python', Microsoft Store kısayolu 'python3' çalışmaz; gerçekten çalışanı seç.
PY=""
for c in python3 python; do
  if "$c" -c 'import sys; sys.exit(sys.version_info[0] < 3)' >/dev/null 2>&1; then PY="$c"; break; fi
done
[ -n "$PY" ] || die "Python 3 bulunamadı. Lütfen kurup tekrar dene."

mkdir -p "$CONFIG_DIR"
chmod 700 "$CONFIG_DIR" 2>/dev/null || true

if [ -f "$JSONC_FILE" ]; then
  die "$JSONC_FILE zaten var. Bu betik yalnızca opencode.json dosyasını yönetir.
Önce opencode.jsonc dosyasını yedekleyip kaldır, sonra betiği tekrar çalıştır.
(İçindeki diğer sağlayıcıları kaybetmemek için önce yedek al.)"
fi

KEY=""
if [ -s "$KEY_FILE" ]; then
  read -r -p "Kayıtlı bir anahtar bulundu. Yenisini girmek ister misin? [e/H] " answer || answer="H"
  case "$answer" in
    e|E|evet|Evet|EVET) KEY="" ;;
    *) KEY="$(cat "$KEY_FILE")"; printf 'Mevcut anahtar kullanılacak.\n' ;;
  esac
fi

if [ -z "$KEY" ]; then
  read -r -s -p "EVREN API anahtarı (evren_llm_...): " KEY || die "Anahtar girilmedi."
  printf '\n'
fi

# Kopyala-yapıştır kaynaklı boşluk ve tırnakları temizle.
KEY="$(printf '%s' "$KEY" | tr -d '[:space:]' | sed -e 's/^["'\'']//' -e 's/["'\'']$//')"
[ -n "$KEY" ] || die "Anahtar boş olamaz."
case "$KEY" in
  evren_llm_*) ;;
  *) die "Anahtar 'evren_llm_' ile başlamalı. EVREN'de LLM Çıkarım → API Anahtarı Oluştur sayfasından al." ;;
esac

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

request() {
  curl -sS --max-time 30 -o "$TMP" -w '%{http_code}' "$@"
}

printf '\nAnahtar doğrulanıyor...\n'
code="$(request "$BASE_URL/models" -H "Authorization: Bearer $KEY")"

case "$code" in
  200)
    ;;
  401)
    die "Anahtar reddedildi (401). Anahtarın tamamını kopyaladığından ve EVREN'de 'LLM Çıkarım' sınıfında oluşturulduğundan emin ol."
    ;;
  403)
    err_code="$("$PY" -c "import json,sys;d=json.load(open(sys.argv[1]));print(d.get('error',{}).get('code',''))" "$TMP" 2>/dev/null || true)"
    if [ "$err_code" = "terms_not_accepted" ]; then
      printf 'Kullanım şartları henüz kabul edilmemiş.\n'
      tcode="$(request "$BASE_URL/terms/text" -H "Authorization: Bearer $KEY")"
      [ "$tcode" = "200" ] || die "Kullanım şartları metni alınamadı (HTTP $tcode)."
      "$PY" - "$TMP" "$TERMS_FILE" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
open(sys.argv[2], "w", encoding="utf-8").write(data.get("content", ""))
PY
      printf 'Şart metni kaydedildi: %s\n' "$TERMS_FILE"
      printf '\nLÜTFEN KULLANIM ŞARTLARINI OKUYUN. Şartlar sizin adınıza otomatik kabul edilmez.\n'
      printf 'Okumak için: less %s\n\n' "$TERMS_FILE"
      # /dev/tty: 'curl | bash' ile çalıştırılsa bile soru terminalden okunur
      read -r -p "Kullanım şartlarını kabul ediyor musunuz? [e/H] " ok </dev/tty || ok=""
      case "$ok" in
        e|E|evet|Evet|EVET) ;;
        *) die "Şartlar kabul edilmeden kurulum tamamlanamaz." ;;
      esac
      acode="$(request -X POST "$BASE_URL/terms/accept" \
        -H "Authorization: Bearer $KEY" \
        -H "Content-Type: application/json" \
        -d '{"version": 1}')"
      [ "$acode" = "200" ] || die "Şartlar onaylanamadı (HTTP $acode)."
      printf 'Şartlar kabul edildi.\n'
      code="$(request "$BASE_URL/models" -H "Authorization: Bearer $KEY")"
      [ "$code" = "200" ] || die "Model listesi alınamadı (HTTP $code)."
    else
      die "Erişim reddedildi (403, ${err_code:-bilinmeyen})."
    fi
    ;;
  *)
    die "Model listesi alınamadı (HTTP $code). İnternet bağlantını kontrol et."
    ;;
esac

printf 'Anahtar doğru, modeller alınıyor...\n'

umask 077
printf '%s' "$KEY" > "$KEY_FILE"
chmod 600 "$KEY_FILE"

if [ -f "$CONFIG_FILE" ]; then
  BACKUP="$CONFIG_FILE.bak.$(date +%Y%m%d-%H%M%S)"
  cp "$CONFIG_FILE" "$BACKUP"
  printf 'Eski config yedeklendi: %s\n' "$BACKUP"
fi

"$PY" - "$TMP" "$CONFIG_FILE" <<'PY'
import json
import sys

models_path, config_path = sys.argv[1], sys.argv[2]

data = json.load(open(models_path, encoding="utf-8"))
items = data.get("data", data if isinstance(data, list) else [])

names = {
    "glm-5.3": "GLM 5.3",
    "deepseek-v4.1-flash": "DeepSeek V4.1 Flash",
    "qwen3.8-flash-next": "Qwen3.8 Flash Next",
    "mimo-v2.6-pro": "MiMo V2.6 Pro",
    "gemma-4-31b": "Gemma 4 31B",
    "qwen3-vl-30b": "Qwen3 VL 30B",
    "auto": "EVREN Auto",
}

models = {}
for m in items:
    if m.get("task") not in ("chat", "vision_chat"):
        continue
    mid = m.get("id")
    if not mid:
        continue
    caps = m.get("capabilities") or {}
    models[mid] = {
        "name": names.get(mid, mid),
        "limit": {
            "context": m.get("context_length") or 128000,
            "output": m.get("default_max_output_tokens") or 8192,
        },
        "capabilities": {
            "tools": bool(caps.get("tools")),
            "input": m.get("modalities") or ["text"],
            "output": ["text"],
            "temperature": True,
            "reasoning": {"supported": bool(caps.get("thinking"))},
        },
    }

if not models:
    raise SystemExit("EVREN sohbet modeli bulunamadı.")

default_model = "glm-5.3" if "glm-5.3" in models else next(iter(models))

try:
    config = json.load(open(config_path, encoding="utf-8"))
except Exception:
    config = {}

config.setdefault("$schema", "https://opencode.ai/config.json")
config.setdefault("model", f"evren/{default_model}")
config.setdefault("providers", {})
config["providers"]["evren"] = {
    "name": "EVREN",
    "package": "@opencode/ai/providers/openai-compatible",
    "settings": {
        "baseURL": "https://evren-llmapi.ssyz.org.tr/v1",
        "apiKey": "{file:./.evren-key}",
    },
    "models": models,
}

with open(config_path, "w", encoding="utf-8") as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
    f.write("\n")

print(f"Config yazıldı: {config_path}")
print("Modeller: " + ", ".join(models))
PY

printf '\nKurulum tamamlandı.\n\n'
printf 'Ne yapmak istersin?\n'
printf "  1) OpenCode'u şimdi aç\n"
printf '  2) Çık\n'
read -r -p 'Seçim [1]: ' secim || secim=1
secim="${secim:-1}"

case "$secim" in
  1)
    if ! command -v opencode >/dev/null 2>&1; then
      printf '\nopencode bulunamadı. Kurmak için:\n'
      printf '  curl -fsSL https://opencode.ai/v2/install | bash\n\n'
      exit 1
    fi
    printf '\nOpenCode açılıyor...\n'
    printf 'Açılınca isteğini normal Türkçe yazabilirsin. Örnek:\n'
    printf '  "Bu klasördeki dosyaları özetle."\n\n'
    exec opencode
    ;;
  *)
    printf '\nÇıkılıyor.\n'
    ;;
esac
