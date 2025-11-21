# ScoutConnect - African Football Talent Valuation

## Mission
ScoutConnect bridges the gap between african talent in different sports and global scouts, scouting programs and talent organizations. This linear regression model help close valuation gap between African football talent and global scouts using AI-powered market predictions. It will help young athletes understand their worth and scouts identify undervalued talent using FIFA data analytics.

## Data Source  
**FIFA 23 Players Dataset** from Kaggle, filtered for African nationalities. Contains 100+ player attributes including skills, physical stats, and market values for 17,000+ players.

## Model Implementation
This project implements ALL required regression models:
- **Linear Regression** (Baseline implementation)
- **Gradient Descent** (SGDRegressor with loss curve visualization)  
- **Decision Trees**
- **Random Forest**

While linear regression was our starting point, Random Forest achieved superior performance (93.7% R² vs 45.2%) due to football's non-linear valuation patterns.

## API Endpoint
**Live API:** https://scoutconnect-api.onrender.com

## Video Demo

## Mobile App Setup
1. Clone repository: `git clone https://github.com/YinkaAjao/linear_regression_model.git`
2. Navigate: `cd linear_regression_model/summative/FlutterApp`
3. Install dependencies: `flutter pub get`
4. Run app: `flutter run`# linear_regression_model