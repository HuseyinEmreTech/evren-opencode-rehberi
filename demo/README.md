# Demo klasörleri

İki küçük örnek proje:

| Klasör | Ne için |
| --- | --- |
| `ilk-dosya/` | Boş proje; modelden sıfırdan `hesap.py` oluşturması istenir |
| `hata-duzelt/` | Boş liste verildiğinde çöken `hesap.py`; modelden hatayı düzeltmesi istenir |


Her iki klasörde de `GOREV.md` dosyası, örnek istemi ve beklenen sonucu içerir.

## Örnekleri sıfırla

Modelin oluşturduğu/değiştirdiği dosyaları temizlemek için:

```bash
./demo/sifirla.sh
```

Bu komut `ilk-dosya/hesap.py` dosyasını siler ve `hata-duzelt/hesap.py` dosyasını
ilk (hatalı) haline döndürür.
