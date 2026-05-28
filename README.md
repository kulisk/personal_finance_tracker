# Personal finance tracker

Personal Finance Tracker is a Flutter app for tracking accounts, income, and expenses with local storage and charts.

## What the app does
* Track accounts with starting balances and updated running balances.
* Record income and expense transactions with categories and dates.
* Attach an optional photo to a transaction.
* Filter and sort the transaction list by type and date.
* Review monthly and yearly income and expense totals in charts.
* View EUR exchange rates against USD and GBP with a history chart.
* Change the theme seed color from the home screen.

## Key screens
* Transactions: list, filters, totals, and access to transaction details.
* Accounts: list of accounts and account details.
* Statistics: monthly and yearly charts with a year selector.
* Rates: exchange rate summary, chart, and refresh control.

## Data model
* Account: `id`, `name`, `initialBalance`, `balance`, `createdAt`.
* FinanceTransaction: `id`, `title`, `amount`, `type`, `category`, `date`, `createdAt`, `accountId`, `photoPath`.
* TransactionType: `income`, `expense`.
* CategoryType: `food`, `transport`, `bills`, `entertainment`, `shopping`, `health`, `salary`, `other`.

## Storage and state
* Hive boxes: `accounts`, `transactions`, `settings`.
* State management: Provider with `FinanceStore` and `ThemeStore`.

## Exchange rates
The rates screen loads EUR exchange rates from the Frankfurter API and shows USD and GBP series.

## Project structure
* lib/app.dart - root widget and providers.
* lib/main.dart - app entrypoint and Hive initialization.
* lib/models - data models and Hive adapters.
* lib/screens - UI screens and navigation flows.
* lib/services - Hive setup and exchange rate client.
* lib/stores - application state.
* lib/utils - formatting helpers and category metadata.
* lib/widgets - shared UI components.

## Getting started
* Install Flutter SDK with Dart 3.7 or later.
* Run `flutter pub get` to install dependencies.
* Choose a device or emulator.
* Run `flutter run`.

## Common commands
```bash
flutter pub get
flutter run
```

```bash
dart format .
dart analyze --fatal-infos
dart run dart_code_linter:metrics analyze lib
dart test
```
