# Demo: hatayı bul ve düzelt

Bu klasördeki `hesap.py` boş liste verildiğinde çöker:

```bash
python3 hesap.py          # çalışır
python3 -c "import hesap; print(hesap.ortalama([]))"   # ZeroDivisionError
```

Örnek istem:

```text
hesap.py dosyasındaki hatayı bul. ortalama ve en_buyuk fonksiyonları boş liste
verilince çökmemeli; mantıklı bir değer döndürmeli. Düzelt ve standart
kütüphanedeki unittest ile basit testler ekle.
```

Beklenen: model dosyayı düzenler, boş liste durumunu ele alır ve `python3 -m unittest` ile testleri çalıştırır.
