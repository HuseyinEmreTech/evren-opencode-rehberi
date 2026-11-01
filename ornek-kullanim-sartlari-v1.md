# EVREN LLM Gateway — Kullanım Şartları ve Kabul Edilebilir Kullanım Politikası

![Versiyon](https://img.shields.io/badge/versiyon-1-blue) ![Durum](https://img.shields.io/badge/durum-esaslı%20(v1%2C%20ilk%20yayın)-orange)

> Bu belge **v1**'dir — EVREN LLM Gateway'in ilk yayın sürümü. Bu sürüm **esaslı**
> (`is_material=true`) sayılır: gateway'i kullanan her hesap, ilk API çağrısından
> önce bu metni açıkça kabul etmelidir (`POST /v1/terms/accept`). Sonraki sürümler
> yalnızca **esaslı değişiklik** taşıyorsa yeniden kabul tetikler; salt kozmetik/
> yazım düzeltmeleri tetiklemez.

---

## 1. Kapsam

Bu şartlar, `api.evren.<domain>` üzerinden sunulan OpenAI-uyumlu LLM Gateway'in
(`/v1/chat/completions`, `/v1/responses`, `/v1/embeddings`, `/v1/models` ve
ilgili tüm uçlar) kullanımını kapsar. API anahtarı oluşturan veya LLM Chat
Portal'ı kullanan her hesap bu şartlara tabidir.

## 2. Kabul Edilebilir Kullanım

Aşağıdaki kullanımlar **yasaktır**:

- Yasadışı, zararlı veya üçüncü tarafların haklarını ihlal eden içerik üretimi.
- Kritik altyapıya yönelik saldırı hazırlığı veya kolaylaştırılması.
- Reşit olmayanlara zarar verecek içerik.
- Barındırılan modellerin kendi lisans şartlarında (bkz.
  `docs/compliance/LLM_MODEL_LICENSE_REVIEW.md`) tanımlı kullanım-bazlı
  kısıtlamaların ihlali.
- Hız sınırlarını, kota mekanizmalarını veya kimlik doğrulamasını atlatmaya
  yönelik teknik girişimler (rate-limit bypass, anahtar paylaşımı, otomatik
  hesap oluşturma).

EVREN, `content_guard` (prompt güvenlik sınıflandırması) ve `content_policy`
(Wave 1 metin-dışı içerik reddi) katmanlarıyla bu politikayı teknik olarak
kısmen uygular — ama nihai sorumluluk kullanıcıdadır.

## 3. Faturalama ve Kredi Ekonomisi

Kullanım, HOLD → SETTLE zinciriyle kredi (CR) cinsinden faturalanır. Kesin
tutarlar `/v1/models` ve admin fiyatlandırma panelinde şeffaf şekilde
yayınlanır. Beklenmeyen kesinti (gateway çökmesi, ağ kesintisi) durumunda
`billing_pending` mekanizması devreye girer — bkz. dahili mühendislik
belgeleri, kullanıcıya karşı garanti bu belgenin kapsamı dışıdır.

## 4. Veri İşleme ve KVKK

Kullanım verileri (prompt/completion metni) KVKK kapsamında işlenir — org
düzeyinde rıza (`llm_corpus_consent`) ve kullanıcı düzeyinde unutulma hakkı
(`llm_privacy_tombstone`) mekanizmaları mevcuttur. Detaylar
`docs/compliance/` altındaki ayrı KVKK belgelerinde ele alınır.

## 5. Hizmet Seviyesi ve Sorumluluk Sınırı

Hizmet "olduğu gibi" sağlanır. EVREN, barındırılan modellerin çıktılarının
doğruluğunu garanti etmez. Planlı/plansız kesintilerde en iyi çaba (best-effort)
telafi (kısmi/tam kredi iadesi) uygulanır — kesin SLA taahhüdü bu belgenin
kapsamı dışıdır, ayrı bir ticari sözleşmenin konusudur.

## 6. Fesih

EVREN, bu şartların ihlali durumunda hesabı/API anahtarını askıya alma veya
sonlandırma hakkını saklı tutar. Kullanıcı, API anahtarını istediği zaman
admin panelinden devre dışı bırakabilir.

## 7. Değişiklikler

- **Esaslı değişiklik** (`is_material=true`): fiyatlandırma modeli, veri
  işleme kapsamı, sorumluluk sınırları gibi kullanıcı kararını etkileyecek
  maddelerde değişiklik — yeni sürüm yayınlanır, TÜM kullanıcılar yeniden
  kabul etmeden gateway'i kullanamaz.
- **Kozmetik değişiklik** (`is_material=false`): yazım düzeltmesi, netleştirme
  — yeniden kabul TETİKLEMEZ, ama denetim kaydı için yeni bir versiyon satırı
  yine oluşturulur.

---

*Bu belge bir hukuk ekibi tarafından nihai olarak gözden geçirilmemiştir —
platformun ilk yayın öncesi taslak sürümüdür.*
