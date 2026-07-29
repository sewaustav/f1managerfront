# TZ: F1 Manager — Flutter Frontend

## 1. Контекст проекта

Go-бэкенд F1 Manager уже написан. Задача — создать Flutter-приложение (iOS / Android / Web), которое работает с REST API и WebSocket. Фронтенд не хранит игровое состояние на сервере кроме случаев явно указанных ниже; локально хранятся только сетапы (до 3 комплектов).

Фронтенд имеет право создавать PR на бэкенд для добавления недостающих ручек или исправления существующих — всё через PR, не в main напрямую.

---

## 2. Сетевой слой

### REST (base URL: `http(s)://<host>/api/v1`)

Все запросы кроме auth требуют `Authorization: Bearer <access_token>`.

**Auth**
- `POST /auth/register` — `{email, username, password}` → `{access_token, refresh_token}`
- `POST /auth/login` — `{login, password}` → `{access_token, refresh_token}`
- `POST /auth/refresh` — `{refresh_token}` → `{access_token, refresh_token}`
- `POST /auth/logout` — инвалидирует все refresh-сессии

**Группы**
- `POST /groups` — создать группу `{name, password}`
- `POST /groups/join` — войти в группу `{id, password}`

**Данные (справочник, доступны всегда)**
- `GET /pilots` — все пилоты с рейтингами
- `GET /teams` — все команды (публичные поля: название, бюджет, двигатель, IsManufacturer)
- `GET /principals` — все тим-принципалы
- `GET /track?track=<name>` — информация о трассе (или все)
- `GET /my-team` — полные данные своей команды (рейтинги болида, детали базы)
- `GET /players` — список игроков группы
- `GET /players/squads` — составы всех игроков (без деталей болида и базы)

**Драфт**
- `POST /draft/start` — организатор стартует драфт
- `POST /draft/pick` — `{pick: 0|1|2, item_id, engine?}` (0=пилот, 1=команда, 2=принципал)
- `POST /draft/bots/swap` — `{team_a, team_b, pilot_a, pilot_b}` — поменять пилотов ботов

**Сезон**
- `POST /setup` — отправить настройки на гонку `{aero_dynamic, engine, chassis, floor, tyres, reliability, settings_angle}`
- `POST /token-setup` — настройки на сезон (те же поля)
- `GET /race-result` — результаты последней гонки `{stage, results[]}`
- `GET /standing` — текущий чемпионат `{drivers: {id: pts}, teams: {id: pts}}`
- `POST /rounds/:stage/init` — организатор открывает этап (stage = 1..24)

**Межсезонье / обновления болида**
- `POST /updates` — `{type: 0|1, coast, stage}` (0=улучшение болида, 1=синергия)
- `POST /base` — инвестиции в базу `{base, engineer, tube, sim}`
- `POST /transfers/pilot` — `{pilot_id, price}`
- `POST /transfers/principal` — `{principal_id, price}`

**Недостающие ручки (добавить через PR на бэкенд)**
- `GET /season/state` — текущее состояние сезона: номер этапа, фаза (draft / pre-race / racing / inter-season), кто уже отправил сетап
- `GET /engines` — список двигателей с ценами
- `GET /budget` — актуальный бюджет и токены текущего игрока
- `POST /ready` — игрок готов к старту нового сезона (сигнал что токены распределены)

### WebSocket (`ws(s)://<host>/api/v1/ws`)

Подключение сразу после логина, переподключение с exponential backoff.

**Входящие сообщения (сервер → клиент)**

```
draft_turn        {round: int}                      — твой ход в драфте
draft_retry       {round: int, error: string}       — ход отклонён, повтори
draft_pick_made   {user_id, pick, item_id}          — broadcast, кто что взял
draft_finished    {}                                — драфт завершён
transfer_request  {pilot_id, price}                 — входящее предложение о трансфере
race_finished     {status, stage}                   — симуляция гонки завершена
```

**Исходящие сообщения (клиент → сервер)**

```
transfer_response {type: "transfer_response", pilot_id, accept: bool}
```

---

## 3. Локальное хранилище

Только сетапы — до 3 именованных комплектов:
```dart
class SetupPreset {
  String name;
  int aeroDynamic, engine, chassis, floor, tyres, reliability;
  int settingsAngle; // 0=rear, 1=front
}
```
Хранятся в `SharedPreferences` / `Hive`. Сервер их не знает — при отправке гонки пользователь выбирает один из сохранённых или вводит вручную.

Токены авторизации хранятся в `FlutterSecureStorage`.

---

## 4. Архитектура Flutter-проекта

```
lib/
├── core/
│   ├── api/          # Dio client, interceptors, REST endpoints
│   ├── ws/           # WebSocket service, reconnect logic
│   ├── storage/      # SecureStorage (tokens), Hive/SharedPrefs (setups)
│   └── models/       # DTO классы, json_serializable
├── features/
│   ├── auth/         # login, register, token refresh
│   ├── lobby/        # создание/вход в группу
│   ├── draft/        # экран драфта
│   ├── season/       # экран сезона (гонки, обновления)
│   ├── inter_season/ # межсезонье (трансферы, база)
│   ├── standings/    # чемпионат
│   ├── track_info/   # следующая трасса
│   └── my_team/      # детальная карточка своей команды
├── shared/
│   ├── widgets/      # переиспользуемые компоненты
│   └── theme/        # цвета, типографика
└── main.dart
```

State management: **Riverpod** (или BLoC — на выбор ИИ, но один стиль на весь проект).

Навигация: **GoRouter**.

---

## 5. Игровые экраны и их логика

### 5.1 Auth
- Логин / регистрация
- После логина — WS-соединение, редирект в лобби

### 5.2 Лобби
- Если нет группы: создать или войти по паролю
- Если есть группа: видеть список игроков, статус сезона
- Кнопка "Начать драфт" (только организатор / любой, пока ролей нет)

### 5.3 Драфт
- Список доступных пилотов, команд, принципалов с фильтрами и сортировкой
- Индикатор: чей сейчас ход (из WS `draft_turn`)
- При своём ходе — разблокированы кнопки выбора
- При выборе команды: модалка выбора двигателя (с ценами), учёт типа команды
- Бюджет-бар: реал-тайм остаток (110 → обновляется при выборе команды)
- История пиков (broadcast `draft_pick_made`)
- По `draft_finished` → переход на экран настройки токенов

### 5.4 Настройка токенов (пред-сезонная)
- 6 слайдеров: Aero, Engine, Chassis, Floor, Tyres, Reliability
- Счётчик оставшихся токенов (от базового кол-ва команды)
- Переключатель Settings Angle (Rear / Front)
- Сохранить как пресет (до 3 штук, локально)
- Кнопка "Отправить" → `POST /token-setup`
- После отправки всех игроков → начинается сезон (сигнал через `GET /season/state` или WS)

### 5.5 Гонка (основной экран сезона)
- Карточка следующей трассы (название, тип, сложность, дождь %, износ шин)
- Выбор сетапа из пресетов или ввод вручную
- Кнопка "Подтвердить сетап" → `POST /setup`
- Статус: ожидание остальных игроков (polling `GET /season/state` каждые 5с или WS)
- По WS `race_finished` → запрос `GET /race-result`, показать результаты
- Таблица результатов гонки: позиция, пилот, команда, квала, гонка, очки, DNF
- Кнопка "Следующий этап"

### 5.6 Окна обновлений болида (этапы 3, 8, 13)
- После гонки на этих этапах появляется модалка
- Два варианта: улучшить характеристики болида (до 15 млн) / синергия пилот-болид
- Ввод суммы, расчёт эффекта → `POST /updates`

### 5.7 Межсезонье
- Экран трансферов: список свободных пилотов и пилотов других игроков, цены
- Сделать предложение → `POST /transfers/pilot`; входящие через WS `transfer_request`, ответ через WS
- Уволить пилота / принципала (ручка нужна — PR на бэк)
- Нанять принципала → `POST /transfers/principal`
- Инвестиции в базу → `POST /base` (слайдеры base ≤10, engineer ≤5, tube ≤5, sim ≤5)
- Информация о текущем состоянии базы команды (из `GET /my-team`)

### 5.8 Чемпионат
- Таблица WDC (пилоты) и WCC (команды) из `GET /standing`
- Обновляется после каждой гонки

### 5.9 My Team (всегда доступна как таб)
- Болид: уровень, компоненты, настройки
- Пилоты: все характеристики
- Тим-принципал: уровень
- Бюджет и токены (`GET /budget`)
- База: все уровни

### 5.10 Info (всегда доступна как таб)
- Следующая трасса с полной инфой
- Составы всех команд (`GET /players/squads`) — без деталей болида
- Список всех пилотов с публичными рейтингами

---

## 6. Фазы игры и навигация между ними

```
Auth
  └── Lobby (нет группы → создать/войти)
       └── Group Lobby (ждём старта драфта)
            └── Draft
                 └── Token Setup (пред-сезон)
                      └── Season Loop:
                           ├── Race Setup → Race Result
                           ├── Update Window (этапы 3, 8, 13)
                           └── [24 этапа завершены]
                                └── Inter-Season
                                     └── Token Setup → Season Loop
```

Фазу определяет `GET /season/state`. Приложение при запуске всегда читает state и кидает пользователя на нужный экран.

---

## 7. Требования к PR на бэкенд

Следующие вещи добавить через PR:

- `GET /season/state` — возвращает `{phase: "draft"|"token_setup"|"racing"|"inter_season", stage: int, submitted_setups: [user_id], total_players: int}`
- `GET /engines` — список движков `[{id, name, price, base_level}]`
- `GET /budget` — `{budget: int, tokens: int}`
- `POST /ready` — межсезонье: игрок объявляет что готов к новому сезону
- `POST /fire` — уволить пилота/принципала `{who: "pilot"|"principal", id: int}`
- WebSocket message `season_started` — broadcast когда все готовы к сезону

---

## 8. Нефункциональные требования

- Модульность: каждый `feature/` — независимый модуль со своими provider/bloc, repository, моделями. При добавлении новой фичи достаточно добавить новую папку и зарегистрировать роут.
- Переподключение WS: exponential backoff 1s → 2s → 4s → max 30s. При переподключении — повторный запрос `GET /season/state`.
- Обработка ошибок: все сетевые ошибки показывают снекбар с причиной. 401 → автоматический refresh токена через interceptor.
- Тема: минималистичная, тёмная + светлая, F1-стилистика (красный акцент).
- Платформы: iOS, Android, Web (responsive, min-width 320px).
