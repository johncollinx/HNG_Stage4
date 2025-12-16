Crypto Price Tracking App | HNG Stage 4 Task

Overview

This is a modern, responsive mobile application built with Flutter for tracking real-time cryptocurrency market data. It provides users with a clean, stylish overview of the top market leaders and an interactive detail view, including price charts.

The application adheres strictly to the Model-View-ViewModel (MVVM) architectural pattern for clean separation of concerns and maintainable code.

Features

Stylish Home Screen: Features a gradient-styled portfolio header for a premium user experience.

Real-time Market Data: Displays current price, 24-hour price change percentage, and market cap rank for the top 100 cryptocurrencies.

Coin Detail View: Dedicated screen providing detailed information for a selected coin.

Interactive Charts: Dynamic line charts powered by fl_chart to visualize historical price data over various timelines (e.g., 7 days, 30 days).

Responsive UI: Designed with a clean, mobile-first approach using a light theme.

Pull-to-Refresh: Allows users to manually refresh the coin list.

Architecture

The project is structured using the MVVM (Model-View-ViewModel) pattern:

Models (lib/models): Data structures (Coin, PricePoint) defining the data fetched from the API.

Views (lib/views): The UI layer (HomeScreen, DetailScreen). They only listen to ViewModels and render the UI.

ViewModels (lib/viewmodels): Contains the presentation logic and state management (CoinListViewModel, CoinDetailViewModel). They use the Provider package to expose data to the Views.

Services (lib/services): Handles all external data operations, specifically interacting with the CoinGecko API.

Tech Stack & Dependencies

Framework: Flutter

Language: Dart (SDK >=3.0.0)

State Management: provider

Networking: http

Charting: fl_chart

Utility: intl (for currency and date formatting)

Getting Started

Prerequisites

Flutter SDK installed (version 3.0.0 or higher recommended).

A functional IDE (VS Code or Android Studio).

Installation & Run

Clone the repository:

git clone [https://github.com/johncollinx/Coin_Listing_App]
cd crypto_tracker_mvvm


Install dependencies:

flutter pub get


Run the application:

flutter run


API Configuration Note

The application uses the CoinGecko API for cryptocurrency data.

The API key is currently managed within lib/services/api_service.dart. While a demo key is used in the provided code, for production or heavy testing, you should register for your own CoinGecko API key and replace the placeholder value in the ApiService class.
