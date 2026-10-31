#!/usr/bin/env bash
#
# Demo klasörlerini ilk haline döndürür. Yeni bir çekimden önce çalıştır.
#
set -euo pipefail

cd "$(dirname "$0")"

rm -f ilk-dosya/hesap.py

cat > hata-duzelt/hesap.py <<'PY'
def ortalama(sayilar):
    return sum(sayilar) / len(sayilar)


def en_buyuk(sayilar):
    return max(sayilar)


if __name__ == "__main__":
    print("Ortalama:", ortalama([2, 4, 6]))
    print("En büyük:", en_buyuk([2, 9, 4]))
PY

rm -f hata-duzelt/test_*.py
rm -rf ilk-dosya/__pycache__ hata-duzelt/__pycache__

printf 'Demo klasörleri ilk haline döndü.\n'
