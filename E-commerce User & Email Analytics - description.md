# sql-portfolio

# 📊 E-commerce User & Email Analytics

## Goal
Build a dataset to analyze user growth and email engagement across countries and user segments.

## Data
BigQuery e-commerce dataset (accounts, sessions, email events).

## Solution
The query combines account creation and email activity using:

- CTEs for modular logic
- UNION ALL to merge datasets
- Window functions for ranking and totals

## Metrics
- account_cnt — number of created accounts
- sent_msg — emails sent
- open_msg — emails opened
- visit_msg — link clicks

## Additional Metrics
- total_country_account_cnt
- total_country_sent_cnt
- ranking of countries

## Key Features
- segmentation by country, verification, subscription status
- time-based analysis
- top-10 country filtering

## Dashboard
Includes:
- country comparison
- ranking visualization
- email activity over time

🔗 [Open Interactive Dashboard](https://datastudio.google.com/reporting/e27f71c7-2b2a-4afa-8cb0-b215290cd249)
