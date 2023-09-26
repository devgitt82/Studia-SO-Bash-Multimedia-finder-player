# Multimedia File Finder and Player - skrypt BASH wraz z manualem.

Skrypt BASH tworzący wyszukiwarkę plików multimedialnych oraz umożliwiający odtworzenie lub wyświetlenie wybranego pliku. Służy do wyszukania wszystkich plików multimedialnych o wybranym przez użytkownika typie (video, dźwięk, foto) oraz wprowadzonej nazwie i lokalizacji. Po zakończonym wyszukiwaniu skrypt daje możliwość wyświetlenia lub odtworzenia wybranego przez użytkownika pliku. 

Do komunikacji z użytkownikiem wykorzystywany jest interfejs semigraficzny. Łatwość użycia skryptu jest jego największą zaletą. Użytkownik nie musi znać skompilowanych poleceń, które musiałby wystukać na klawiaturze aby odnaleźć pożądany plik. Wystarczy że uruchomi skrypt a ten następnie poprowadzi go za rękę:
- pozwoli mu wybrać z listy wyboru jakiego typu plik pragnie odnaleźć
- pozwoli mu wybrać rozszerzenia plików jakimi jest zainteresowany
- zapyta użytkownika o podanie nazwy pliku lub jej części
- poprosi użytkownika o podanie ścieżki początkowej wyszukiwania (przeszukanie będzie się odbywać w głąb podanej ścieżki). Pozostawienie pustego pola będzie oznaczało przeszukanie całego drzewa plików od korzenia w głąb.

Wyniki zostaną wyświetlone w postaci przewijanego menu. Użytkownik wybierze, interesujący go plik i wybierając opcje <code>OK</code> spowoduje uruchomienie odpowiedniego programu, który wyświetli lub odtworzy plik multimedialny wybrany przez użytkownika. Wybranie opcji <code>Anuluj</code> w dowolnym momencie spowoduje zakończenie wykonywania skryptu.

Program może być uruchomiony z odpowiednimi opcjami:
- <code>-h</code>	powoduje wyświetlenie pomocy – podstawowych informacji o skrypcie
- <code>-v</code>	wyświetla informacje o numerze wersji programu
- <code>-a</code>	wyświetla informacje o autorze

---

Do skryptu dołączony jest plik manuala.

**Zadanie  z przedmiotu Systemy Operacyjne na czwartym semestrze studiów**

---

- Skrypt do poprawnego działania potrzebuje zainstalowanego programu `dialog`, odtwarzacza zdjęć `eog` oraz zainstalowanego odtwarzacza `vlc` wraz najnowszymi kodekami video.
- Do wyszukiwania plików program korzysta z programu `find` wykorzystując wyrażenia regularne.

    Program testowany na dystrybucji `Fedora`.
