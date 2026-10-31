def ortalama(sayilar):
    return sum(sayilar) / len(sayilar)


def en_buyuk(sayilar):
    return max(sayilar)


if __name__ == "__main__":
    print("Ortalama:", ortalama([2, 4, 6]))
    print("En büyük:", en_buyuk([2, 9, 4]))
