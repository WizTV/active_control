# Active Control - Instrukcja Obsługi (User Guide)

## Spis Treści
1. [Wstęp](#wstęp)
2. [Wymagania Systemowe](#wymagania-systemowe)
3. [Instalacja i Uruchomienie](#instalacja-i-uruchomienie)
4. [Przewodnik Użytkownika](#przewodnik-użytkownika)
5. [Funkcjonalności](#funkcjonalności)
6. [Rozwiązywanie Problemów](#rozwiązywanie-problemów)

---

## Wstęp

**Active Control** to nowoczesna aplikacja mobilna i webowa służąca do zarządzania i śledzenia treningów. Aplikacja umożliwia:
- Rejestrację i logowanie użytkowników
- Tworzenie i edycję planów treningowych
- Monitorowanie postępów w treningach
- Dostęp do treningów z różnych urządzeń

---

## Wymagania Systemowe

### Do uruchomienia aplikacji:
- **Systemy operacyjne**: Android (v6.0+), iOS (v12+), Windows, macOS, Web
- **Połączenie internetowe**: Wymagane do synchronizacji danych
- **Konto Google** (opcjonalnie): Do logowania poprzez Google Sign-In

### Do rozwoju aplikacji:
- Flutter SDK v3.7.2 lub nowszy
- Dart SDK (wchodzi w skład Flutter)
- Android Studio / Xcode (w zależności od platformy)
- Firebase Console (do konfiguracji)

---

## Instalacja i Uruchomienie

### Dla użytkowników końcowych:

#### Na urządzeniu Android:
1. Pobierz aplikację z Google Play Store (jeśli dostępna)
2. Zainstaluj aplikację
3. Uruchom aplikację

#### Na urządzeniu iOS:
1. Pobierz aplikację z Apple App Store (jeśli dostępna)
2. Zainstaluj aplikację
3. Uruchom aplikację

#### W przeglądarce (Web):
1. Przejdź do adresu aplikacji webowej
2. Aplikacja załaduje się automatycznie w przeglądarce

### Dla programistów:

```bash
# Klonowanie repozytorium
git clone <URL-repozytorium>
cd active_control

# Pobranie zależności
flutter pub get

# Uruchomienie na Windows
flutter run -d windows

# Uruchomienie na Android
flutter run -d android

# Uruchomienie na Web
flutter run -d chrome

# Uruchomienie testów
flutter test
```

---

## Przewodnik Użytkownika

### 1. Logowanie i Rejestracja

#### Pierwszego uruchomienie - Rejestracja
1. Uruchom aplikację
2. Zobaczysz ekran **Login**
3. Kliknij przycisk **"Nie masz konta? Zarejestruj się"**
4. Wypełnij formularz rejestracji:
   - **Email**: Wpisz swój adres email
   - **Hasło**: Wpisz bezpieczne hasło (co najmniej 8 znaków)
   - **Potwierdź hasło**: Powtórz hasło
5. Kliknij przycisk **"Zarejestruj się"**
6. Czekaj na potwierdzenie
7. Zostaniesz automatycznie zalogowany

#### Logowanie do istniejącego konta
1. Wpisz swój email
2. Wpisz hasło
3. Kliknij **"Zaloguj się"**

#### Logowanie przez Google
1. Kliknij przycisk **"Zaloguj się przez Google"**
2. Wybierz swoje konto Google
3. Udziel wymaganych uprawnień
4. Zostaniesz automatycznie zalogowany/zarejestrowany

---

### 2. Ekran Główny (Home)

Po zalogowaniu zobaczysz ekran główny z:
- **Lista Treningów**: Wyświetla wszystkie Twoje zaplanowane treningi
- **Przycisk FAB "+"**: Do dodania nowego treningu
- **Menu Drawer**: Dostęp do ustawień i wylogowania

#### Działania na liście treningów:
- **Kliknięcie na trening**: Otwiera szczegóły treningu
- **Przesunięcie w lewo** (swipe left): Opcja usunięcia treningu
- **Przesunięcie w prawo** (swipe right): Opcja edycji treningu

---

### 3. Tworzenie Nowego Treningu

1. Na ekranie głównym kliknij przycisk **"+"** w prawym dolnym rogu
2. Zostaniesz przeniesiony na ekran edycji
3. Wypełnij pola:
   - **Nazwa treningu**: (np. "Trening nóg")
   - **Opis**: (opcjonalnie, np. "Przysiad, martwy ciąg...")
   - **Data**: Wybierz datę treningu
   - **Oczekiwany czas trwania**: (w minutach)
4. Kliknij **"Zapisz trening"**
5. Trening pojawi się na liście

---

### 4. Edycja Treningu

#### Metoda 1: Ze szczegółów treningu
1. Kliknij na trening z listy
2. Kliknij ikę **"Edytuj"** (ołówek/pencil)
3. Zmień wymagane dane
4. Kliknij **"Zapisz zmiany"**

#### Metoda 2: Ze swipe'a
1. Na liście treningów, przesuwaj trening w prawo
2. Kliknij **"Edytuj"**
3. Dokonaj zmian i zapisz

---

### 5. Usuwanie Treningu

1. Na liście treningów, przesuwaj trening w lewo
2. Kliknij **"Usuń"**
3. Potwierdź usunięcie w oknie dialogowym

---

### 6. Ustawienia

1. Otwórz **Menu Drawer** (ikonę hamburgera ☰ w lewym górnym rogu)
2. Kliknij **"Ustawienia"**
3. Dostępne opcje:
   - Zmiana profilu użytkownika
   - Zmiana hasła
   - Powiadomienia
   - Inne preferencje

---

### 7. Wylogowanie

1. Otwórz **Menu Drawer**
2. Kliknij **"Wyloguj"**
3. Potwierdzisz wylogowanie
4. Wrócisz do ekranu logowania

---

## Funkcjonalności

### 🔐 Autentykacja i Bezpieczeństwo
- Rejestracja i logowanie z emailem/hasłem
- Logowanie przez Google (single sign-on)
- Firebase Authentication do bezpiecznego przechowywania danych
- Automatyczne wylogowanie po określonym czasie (opcja)

### 📋 Zarządzanie Treningami
- Tworzenie nowych treningów
- Edycja istniejących treningów
- Usuwanie treningów
- Synchronizacja danych w chmurze (Cloud Firestore)
- Dostęp do treningów z różnych urządzeń

### 📊 Śledzenie Postępów
- Historia treningów
- Notatki z treningów
- Czasy trwania treningów

### 👤 Profil Użytkownika
- Przeglądanie profilu
- Edycja danych użytkownika

### 📱 Responsywny Interfejs
- Dostosowanie do różnych rozmiarów ekranów
- Obsługa orientacji pionowej i poziomej
- Czytelny i intuicyjny interfejs

---

## Rozwiązywanie Problemów

### Problem: Nie mogę się zalogować
**Rozwiązania:**
1. Sprawdź połączenie internetowe
2. Upewnij się, że wpisałeś prawidłowy email i hasło
3. Spróbuj zresetować hasło
4. Wyczyść pamięć podręczną aplikacji
5. Zainstaluj najnowszą wersję aplikacji

### Problem: Nie widzę moich treningów
**Rozwiązania:**
1. Sprawdź, czy jesteś zalogowany
2. Poczekaj na załadowanie danych (są pobierane z chmury)
3. Odśwież aplikację (pull-to-refresh na liście)
4. Sprawdź połączenie internetowe

### Problem: Nie mogę zalogować się przez Google
**Rozwiązania:**
1. Sprawdź połączenie internetowe
2. Upewnij się, że zainstalowałeś Google Play Services (Android)
3. Wyloguj się z konta Google w ustawieniach urządzenia i zaloguj ponownie
4. Spróbuj zalogować się tradycyjnie (email/hasło)

### Problem: Aplikacja działa wolno
**Rozwiązania:**
1. Sprawdź szybkość połączenia internetowego
2. Zamknij zbędne aplikacje
3. Wyczyść pamięć podręczną aplikacji
4. Uruchom ponownie urządzenie
5. Zaktualizuj aplikację do najnowszej wersji

### Problem: Moje zmiany nie są zapisywane
**Rozwiązania:**
1. Sprawdź połączenie internetowe
2. Upewnij się, że czekasz na zakończenie synchronizacji (sprawdź ikonę ładowania)
3. Spróbuj ponownie zapisać trening
4. Wyloguj się i zaloguj ponownie

---

## Wsparcie i Kontakt

Jeśli napotkasz problem, który nie jest wymieniony powyżej:
1. Sprawdź zakładkę **FAQ** w aplikacji
2. Skontaktuj się z zespołem wsparcia
3. Wyślij email na: support@activecontrol.com (jeśli dostępne)

---

## Polityka Prywatności i Warunki Użytkowania

Używając tej aplikacji, akceptujesz:
- Naszą politykę prywatności
- Warunki użytkowania
- Politykę cookies

Szczegółowe informacje: [Link do polityki] (jeśli dostępny)

---

## Historia Zmian

### Wersja 1.0.0
- Pierwsze wydanie aplikacji
- Podstawowe funkcje logowania i zarządzania treningami
- Synchronizacja z Firebase

---

**Ostatnia aktualizacja**: Styczeń 2026

Dziękujemy za używanie Active Control! 🚀
