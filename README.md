# EVREN'i OpenCode ile kullanma rehberi

EVREN platformundaki günlük token kotanı, terminalde çalışan bir yapay zeka kodlama ajanı olan [OpenCode](https://opencode.ai) ile nasıl kullanacağını anlatan kısa rehber.

> Bu rehber resmi değildir; EVREN veya SSB ile bağlantısı yoktur. Adres, model adları ve limitler `/v1/models` yanıtından alındı; **kendi hesabında doğrula**.

> ⚠️ **Önemli:** EVREN kullanım şartlarını **mutlaka okumanız gerekir.** Bu rehber ve `kur.sh` şartları sizin yerinize kabul etmez; onay size sorulur ve kabul sorumluluğu size aittir.

## Gerekenler

- EVREN hesabı (e-Devlet ile giriş) ve kotan
- [OpenCode](https://opencode.ai) (kurulu değilse 0. adıma bak)
- Platformdan üretilmiş bir LLM API anahtarı (`evren_llm_` ile başlar)
- `kur.sh` için: `bash`, `curl` ve Python 3 (macOS'ta Xcode Command Line Tools ile gelir)

## 0. OpenCode'u kur

OpenCode zaten kuruluysa bu adımı atla. Kontrol için terminale `opencode --version` yaz; sürüm numarası görürsen kurulu demektir.

Aşağıdaki yöntemlerden **birini** seç:

| Sistem | Komut |
| --- | --- |
| Linux / macOS (en kolayı) | `curl -fsSL https://opencode.ai/v2/install \| bash` |
| Node.js varsa | `npm install -g @opencode/cli` |
| macOS / Linux, Homebrew | `brew install anomalyco/tap/opencode-v2` |

Kurulumdan sonra **terminali kapatıp yeniden aç**, sonra `opencode --version` ile kontrol et. "command not found" çıkarsa yeni bir terminal açmayı unutmuş olabilirsin.

> Windows'ta en sorunsuz yol [WSL](https://learn.microsoft.com/windows/wsl/install) içinde Linux komutunu kullanmaktır. `kur.sh` cmd/PowerShell'de çalışmaz; WSL veya Git Bash gerekir (Git Bash'te Python 3 de kurulu olmalı). Kurulum seçenekleri değişebilir; güncel hali: <https://opencode.ai/v2/docs>.

## Hızlı kurulum: tek betik

OpenCode kurulduysa gerisini [`kur.sh`](kur.sh) yapar:

```bash
bash kur.sh
```

Betik sırayla:

1. API anahtarını **gizli** olarak sorar (ekranda görünmez).
2. Anahtarı EVREN'e karşı doğrular; yanlışsa nedenini söyler.
3. Kullanım şartları kabul edilmemişse metni indirir, **okumanı ister** ve "Kullanım şartlarını kabul ediyor musunuz? [e/H]" diye sorar. Şartlar senin adına otomatik kabul edilmez; yalnızca `e` yazarsan onaylanır.
4. Anahtarı `~/.config/opencode/.evren-key` dosyasına yazar (`chmod 600`).
5. `/v1/models` listesinden **tüm sohbet modellerini** çekip OpenCode config'ini üretir.
6. Varsa eski config'i zaman damgalı olarak yedekler.
7. Sonunda **1**'e basarsan OpenCode'u açar; isteğini orada yazabilirsin.

Sonunda `opencode` yazıp `/models` ile modeli seçmen yeterli.

### Betik modelleri nasıl ekliyor?

Bu işlemlerin hepsini `kur.sh` otomatik yapar. Betik model **indirmez**; yalnızca OpenCode'a model adlarını tanıtır. Modeller EVREN'in sunucularında çalışır.

1. `https://evren-llmapi.ssyz.org.tr/v1/models` listesini çeker.
2. Yalnızca sohbet modellerini seçer (`task` değeri `chat` veya `vision_chat` olanlar).
3. Bağlam/çıktı limitlerini ve araç kullanımı bilgilerini aynı yanıttan alır.
4. Hepsini `~/.config/opencode/opencode.json` içindeki `providers.evren.models` altına yazar.

Sonuçta `/models` ekranında şu yedi model görünür:

`glm-5.3`, `deepseek-v4.1-flash`, `qwen3.8-flash-next`, `mimo-v2.6-pro`, `gemma-4-31b`, `qwen3-vl-30b`, `auto`

OCR, embedding, rerank, ses, TTS, guard ve karar modelleri eklenmez; çünkü OpenCode bunları kodlama ajanı olarak kullanamaz.

> Elle kurmak veya betiğin ne yaptığını görmek istersen aşağıdaki adımları izle.

## 1. API anahtarını oluştur

EVREN'de **LLM Çıkarım → API Anahtarları → Yeni Anahtar** sayfasına gir ve formu şöyle doldur:

| Alan | Seçim |
| --- | --- |
| Anahtar adı | `OPENCODE` |
| **Sınıf** | **`LLM Çıkarım`** |
| Kredi hesabı | Kendi hesabın |
| Son kullanma tarihi | **Bugünden ileri bir tarih** (ör. `01.12.2026`); bugünün tarihini seçme |
| Modeller | **`Tümü`** (istersen yalnızca sohbet modellerini seç) |

Sonra **Oluştur**'a bas. Anahtar **yalnızca bir kez** gösterilir; hemen kopyala.

> `Model Çıkarımı` sınıfı kendi yüklediğin/eğittiğin modeller içindir; paylaşılan LLM API'sine erişemez. Yanlış sınıfta anahtar oluşturursan istekler `401 Geçersiz API anahtarı` döner.

> Anahtarın süresi dolduysa (`Son kullanım` tarihi geçmişse) aynı ekrandan yeni anahtar oluştur ve `bash kur.sh` ile değiştir. Süresi geçmiş anahtarla işlem yapma; `401` alırsın.

## 2. Kullanım şartlarını kabul et

Anahtar oluşturmak tek başına yetmez. İlk istek, şartlar kabul edilmediği için şu hatayı verir:

```text
403 terms_not_accepted
```

> ⚠️ **Kabul etmeden önce şartları mutlaka okuyun.** Metni okumadan onaylamayın; onay hesabınız adına verilir ve sorumluluk size aittir.

Anahtarı bir yere kaydettikten sonra şart metnini oku ve onayla:

```bash
# Şart metnini oku
curl https://evren-llmapi.ssyz.org.tr/v1/terms/text \
  -H "Authorization: Bearer $EVREN_LLM_API_KEY"

# Uygunsa onayla
curl -X POST https://evren-llmapi.ssyz.org.tr/v1/terms/accept \
  -H "Authorization: Bearer $EVREN_LLM_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"version": 1}'
```

Onay hesap başına bir kez verilir. Şartlarda esaslı bir değişiklik olursa yeniden istenir.

## 3. Anahtarı OpenCode'a tanıt

İki yöntem var; **dosya yöntemi** masaüstü/IDE ve arka plan servisinde de çalıştığı için daha güvenli.

### A. Dosyadan okuma (önerilen)

```bash
mkdir -p ~/.config/opencode
printf '%s' 'evren_llm_...' > ~/.config/opencode/.evren-key
chmod 600 ~/.config/opencode/.evren-key
```

`opencode.example.jsonc` içindeki `apiKey` satırı bu dosyayı okur:

```jsonc
"apiKey": "{file:./.evren-key}"
```

> Göreli yol, config dosyasının bulunduğu klasöre göre çözülür. `~` ile başlayan yollar bu sürümde genişletilmediği için `{file:./.evren-key}` kullanıyoruz.

### B. Ortam değişkeni

```bash
export EVREN_LLM_API_KEY="evren_llm_..."
```

Kalıcı olsun istersen `~/.bashrc` dosyasına ekle. Bu yöntemi kullanacaksan config dosyasındaki `apiKey` satırını silip sağlayıcıya şunu ekle:

```jsonc
"env": ["EVREN_LLM_API_KEY"]
```

> Ortam değişkeni, `.bashrc` okumayan masaüstü/IDE başlatmalarında boş gelebilir. Böyle bir durumda A yöntemini kullan.

## 4. Adres ve model adını sına

```bash
curl https://evren-llmapi.ssyz.org.tr/v1/models \
  -H "Authorization: Bearer $EVREN_LLM_API_KEY"
```

- `200` ve model listesi → adres ve anahtar doğru
- `401` → anahtar eksik/yanlış veya yanlış sınıfta oluşturulmuş
- `403 terms_not_accepted` → 2. adımı uygula

Sohbet için kullanabileceğin modeller (18 Ekim 2026 itibarıyla):

| API'deki ad | Bağlam | Çıktı | Not |
| --- | --- | --- | --- |
| `glm-5.3` | 512K | 16K | En yetenekli model; varsayılan |
| `deepseek-v4.1-flash` | 1M | 64K | Hızlı kod ve ajan işleri |
| `qwen3.8-flash-next` | 256K | 16K | Yüksek hacimli sohbet |
| `gemma-4-31b` | 256K | 16K | Hızlı, görsel girdi |
| `qwen3-vl-30b` | 256K | 16K | Belge ve ekran görüntüsü |
| `mimo-v2.6-pro` | 1M | 16K | Uzun ajan görevleri |
| `auto` | 32K | 16K | Yüke göre model seçer |

Bunların hepsi OpenCode'un `/models` ekranında görünür. API'de ayrıca şu modeller var; sohbet modeli olmadıkları için OpenCode ajanında seçilemezler, yalnızca kendi uç noktalarından çağrılırlar:

| API'deki ad | Görev |
| --- | --- |
| `deepseek-ocr-2`, `dots-ocr` | OCR (görselden metin) |
| `qwen3-embedding-8b` | Embedding |
| `qwen3-reranker-8b` | Yeniden sıralama |
| `qwen3-asr-1.7b` | Ses → metin |
| `voxcpm2` | Metin → ses |
| `qwen3-guard-4b` | İçerik güvenliği sınıflandırma |
| `laya` | Karar modeli (`/v1/systemone`) |

## 5. OpenCode'a tanıt

[`opencode.example.jsonc`](opencode.example.jsonc) dosyasını `~/.config/opencode/opencode.jsonc` olarak kopyala. Dosyada `providers.evren.models` altındaki `glm-5.3` yerine 4. adımda gördüğün adı yaz.

```bash
mkdir -p ~/.config/opencode
cp opencode.example.jsonc ~/.config/opencode/opencode.jsonc
```

> Bu rehber OpenCode **v2** içindir. Dosyadaki `providers`, `package` ve `settings` alanları v2'ye aittir; v1 kullanıyorsan eski karşılıkları `provider`, `npm` ve `options` olur.

Kontrol:

```bash
opencode models | grep evren
```

`evren/glm-5.3` görünüyorsa OpenCode sağlayıcıyı tanımış demektir.

## 6. Çalıştır

```bash
opencode
```

Açılınca `/models` yaz ve EVREN altındaki modeli seç. Model zaten varsayılan olarak `glm-5.3` seçili gelir.

Tek seferlik komut (arayüzü açmadan):

```bash
opencode run --model evren/glm-5.3 "Sadece OK yaz."
```

Cevap olarak `OK` görürsen her şey çalışıyor demektir.

## Örnek: ilk işini yaptır

Sıfırdan küçük bir proje üzerinde deneyelim.

```bash
mkdir deneme && cd deneme
opencode
```

OpenCode açılınca `/models` yazıp EVREN modelini seç, sonra istediğini normal Türkçe cümleyle yaz:

```text
Bu klasöre hesap.py adında bir dosya oluştur. İçinde iki sayıyı toplayan
bir toplama(a, b) fonksiyonu olsun ve dosya çalıştırılınca toplama(2, 3)
sonucunu ekrana yazsın.
```

Ne olacağı:

1. Model ne yapacağını yazar ve dosyayı oluşturmak için senden **izin ister**. Onaylarsan `hesap.py` klasörde oluşur.
2. İçeriği şuna benzer olur (birebir aynı olması gerekmez):

   ```python
   def toplama(a, b):
       return a + b

   print(toplama(2, 3))
   ```

3. Doğrulamak için başka bir terminalde `python3 hesap.py` çalıştır; `5` yazmalı.

Devamında "bir de çıkarma fonksiyonu ekle" gibi isteklerle dosyayı geliştirmeye devam edebilirsin. Hazır bir projede kullanacaksan o klasöre gidip `opencode` yaz; OpenCode projedeki `AGENTS.md` dosyalarını kendisi okur. Yoksa modele "Bu projeyi inceleyip bir AGENTS.md yaz" diyebilirsin.

> Yukarıdaki çıktı örnek amaçlıdır; modelin ürettiği kod ve cümleler her seferinde farklı olur.

## Günlük kullanım kısayolları

| Ne yapmak istiyorsun | Yaz / bas |
| --- | --- |
| Dosya eklemek | `@` yazıp dosya adını seç |
| Terminal komutu çalıştırmak | `!git status` gibi başında `!` |
| Yeni sohbet | `/new` |
| Eski sohbetlere dönmek | `/sessions` |
| Model değiştirmek | `/models` |
| İşi durdurmak | `Esc` |
| Çıkmak | `/exit` veya `Ctrl+C` |

## Sorun giderme

| Belirti | Olası neden |
| --- | --- |
| `401 Geçersiz API anahtarı` | Anahtar yanlış/eksik kopyalanmış veya `Model Çıkarımı` sınıfında oluşturulmuş; `LLM Çıkarım` sınıfında yeni anahtar oluştur |
| `401 API anahtarı eksik` | Ortam değişkeni tanımlı değil veya `.evren-key` dosyası boş (`echo ${EVREN_LLM_API_KEY:+tanimli}`) |
| `403 terms_not_accepted` | Kullanım şartları kabul edilmemiş; 2. adımı uygula |
| `NotFoundError` | Yanlış `baseURL` veya `/v1` eki; OpenCode'u güncelle |
| Model listede yok | `providers.evren.models` altındaki ad, API'nin döndürdüğü adla birebir aynı olmalı |
| `max_tokens is too large` | Model tanımındaki `limit.output` API sınırından büyük; örnekteki gibi `limit` ekle |
| `429` / "İstek limiti aşıldı" | Çok hızlı ardışık istek; birkaç saniye bekleyip tekrar dene |
| İstekler birden durdu | Günlük kota bitti; sıfırlanma TSİ 03:00 |

## Kota ve ücretsiz dönem

Günlük 15.000.000 token kota, tüm API anahtarlarının toplamıdır. Önbellekten okunan girdi token'ları kotaya %3 ağırlıkla yansır. Güncel kullanım EVREN'de **LLM Çıkarım → Kullanım** sayfasındadır.

`/v1/models` yanıtında modellerin `free_until` alanı `2026-12-01` görünüyor; ücretlendirme ve güncel kota için EVREN panelini esas al.

## Notlar ve doğrulanmayanlar

- Uç nokta `https://evren-llmapi.ssyz.org.tr/v1`; anahtarsız istek `401`, geçerli anahtarla `/v1/models` `200` döndürüyor.
- `glm-5.3`, `deepseek-v4.1-flash`, `qwen3.8-flash-next`, `gemma-4-31b`, `qwen3-vl-30b`, `mimo-v2.6-pro` ve `auto` adları `/v1/models` çıktısından doğrulandı.
- Model limitleri (`glm-5.3` için 524.288 bağlam / 16.384 çıktı) `/v1/models` yanıtındaki `context_length` ve `default_max_output_tokens` alanlarından alındı.
- Kullanım şartlarının `v1` sürümü ve `terms_not_accepted` davranışı gerçek API isteğiyle doğrulandı.
- OpenCode ayar biçimi [v2 sağlayıcı dokümanına](https://opencode.ai/v2/docs/providers) göre yazıldı ve v2.2.5 ile `opencode run` üzerinden test edildi.
- Günlük kota (15 milyon) ve sıfırlanma saati üçüncü taraf kaynaklardan; resmi dokümanla karşılaştırılmadı.
- `kur.sh` macOS ve Windows'ta çalıştırılarak denenmedi, yalnızca kod incelemesiyle kontrol edildi. macOS'in eski bash 3.2'sine uygun yazıldı; `python3` (Xcode Command Line Tools) gerekir.
- Windows'ta `kur.sh` yalnızca Git Bash veya WSL'de çalışır; cmd/PowerShell'de çalışmaz. Betik `python3` yoksa `python` komutunu dener.
- Windows'ta OpenCode'un ayarı `~/.config/opencode` altında arayıp aramadığı doğrulanmadı.
- Küçük modellerde çok dosyalı işlerin Claude kalitesinde olmayabileceği beklentisi bir tahmindir, ölçülmedi.

## Katkı

Hata veya farklı bir araçla (Aider, Cline, Continue) çalışan ayar bulursan issue veya PR aç.
