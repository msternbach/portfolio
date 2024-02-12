# load the libraries
import numpy as np
import pandas as pd
from pandas import Series,DataFrame

import matplotlib.pyplot as plt
import seaborn as sns

from google.colab import files
from sklearn.model_selection import GridSearchCV

# load the data to dataframes
train_df = pd.read_csv("https://s3.amazonaws.com/it4ba/Kaggle/train.csv")
test_df  = pd.read_csv("https://s3.amazonaws.com/it4ba/Kaggle/test.csv")

# Feature Engineering

for column in train_df[:-1]:
  if train_df[column].dtype in [float,int]:
      if train_df[column].isna().count() > 0:
        train_df[column].fillna(0,inplace=True)
  elif train_df[column].dtype == object:
    if train_df[column].isna().count() > 0:
      train_df[column].fillna('None',inplace=True)

for column in test_df:
    if test_df[column].dtype in [float,int]:
      if test_df[column].isna().count() > 0:
        test_df[column].fillna(0,inplace=True)
    elif test_df[column].dtype == object:
      if test_df[column].isna().count() > 0:
        test_df[column].fillna('None',inplace=True)

# Group neighborhood and sale price to see if there were large differences accross neighborhoods

train_df.groupby('Neighborhood')['SalePrice'].agg([np.min,np.max,np.mean,np.median]).sort_values(by='median', ascending=False)

# Use median to make new neighborhood variable

NeighMedian = train_df.groupby('Neighborhood')['SalePrice'].median().sort_values()
print(NeighMedian)

# Neighborhoods were seperated arbitraliliy where medians seemed the most similar
# This could possibly have been improved with a more mathematical approach

train_df['Neigh_Type'] = 'Luxury'

train_df.loc[train_df['Neighborhood'].isin(['Timber', 'Somerst', 'Veenker']), 'Neigh_Type'] = 'SemiLuxury'
train_df.loc[train_df['Neighborhood'].isin(['Crawfor', 'ClearCr', 'CollgCr', 'Blmngtn', 'NWAmes', 'Gilbert', 'SawyerW']), 'Neigh_Type'] = 'Great'
train_df.loc[train_df['Neighborhood'].isin(['Mitchel', 'NPkVill', 'NAmes', 'SWISU', 'Blueste', 'Sawyer']), 'Neigh_Type'] = 'Medium'
train_df.loc[train_df['Neighborhood'].isin(['BrkSide', 'Edwards', 'OldTown']), 'Neigh_Type'] = 'Ok'
train_df.loc[train_df['Neighborhood'].isin(['BrDale', 'IDOTRR', 'MeadowV']), 'Neigh_Type'] = 'Poor'

test_df['Neigh_Type'] = 'Luxury'

test_df.loc[test_df['Neighborhood'].isin(['Timber', 'Somerst', 'Veenker']), 'Neigh_Type'] = 'SemiLuxury'
test_df.loc[test_df['Neighborhood'].isin(['Crawfor', 'ClearCr', 'CollgCr', 'Blmngtn', 'NWAmes', 'Gilbert', 'SawyerW']), 'Neigh_Type'] = 'Great'
test_df.loc[test_df['Neighborhood'].isin(['Mitchel', 'NPkVill', 'NAmes', 'SWISU', 'Blueste', 'Sawyer']), 'Neigh_Type'] = 'Medium'
test_df.loc[test_df['Neighborhood'].isin(['BrkSide', 'Edwards', 'OldTown']), 'Neigh_Type'] = 'Ok'
test_df.loc[test_df['Neighborhood'].isin(['BrDale', 'IDOTRR', 'MeadowV']), 'Neigh_Type'] = 'Poor'

# Seperate the years of the houses into 20 year intervals
# Looking at scatter plot there was a clear difference in prices in different time periods

train_df['YearInterval'] = 0
train_df.loc[(1900 < train_df['YearBuilt']) & (train_df['YearBuilt'] <= 1920), 'YearInterval'] = 1
train_df.loc[(1920 < train_df['YearBuilt']) & (train_df['YearBuilt'] <= 1940), 'YearInterval'] = 2
train_df.loc[(1940 < train_df['YearBuilt']) & (train_df['YearBuilt'] <= 1960), 'YearInterval'] = 3
train_df.loc[(1960 < train_df['YearBuilt']) & (train_df['YearBuilt'] <= 1980), 'YearInterval'] = 4
train_df.loc[(1980 < train_df['YearBuilt']) & (train_df['YearBuilt'] <= 2000), 'YearInterval'] = 5
train_df.loc[train_df['YearBuilt'] > 2000, 'YearInterval'] = 6

test_df['YearInterval'] = 0
test_df.loc[(1900 < test_df['YearBuilt']) & (test_df['YearBuilt'] <= 1920), 'YearInterval'] = 1
test_df.loc[(1920 < test_df['YearBuilt']) & (test_df['YearBuilt'] <= 1940), 'YearInterval'] = 2
test_df.loc[(1940 < test_df['YearBuilt']) & (test_df['YearBuilt'] <= 1960), 'YearInterval'] = 3
test_df.loc[(1960 < test_df['YearBuilt']) & (test_df['YearBuilt'] <= 1980), 'YearInterval'] = 4
test_df.loc[(1980 < test_df['YearBuilt']) & (test_df['YearBuilt'] <= 2000), 'YearInterval'] = 5
test_df.loc[test_df['YearBuilt'] > 2000, 'YearInterval'] = 6

# Neigh Type variable helped visualize differences between the test and training set

sns.heatmap(pd.crosstab(train_df.MoSold,train_df.Neigh_Type,  normalize = "columns"), cmap="YlGnBu", annot=True, cbar=False)

sns.heatmap(pd.crosstab(test_df.MoSold,test_df.Neigh_Type,  normalize = "columns"), cmap="YlGnBu", annot=True, cbar=False)

sns.heatmap(pd.crosstab(train_df.YrSold,train_df.Neigh_Type,  normalize = "columns"), cmap="YlGnBu", annot=True, cbar=False)

# There are clear differences in the training and test sets for year and month sold

sns.heatmap(pd.crosstab(test_df.YrSold,test_df.Neigh_Type,  normalize = "columns"), cmap="YlGnBu", annot=True, cbar=False)

train_df.drop(columns=['YrSold', 'MoSold'],inplace=True)
test_df.drop(columns=['YrSold', 'MoSold'],inplace=True)

# Dummy variables for the garage and basement with 0 being if the house didn't have it and 1 if it did

train_df['GarageDummy'] = 1
train_df.loc[train_df['GarageYrBlt'] < 1700, 'GarageDummy'] = 0
test_df['GarageDummy'] = 1
test_df.loc[test_df['GarageYrBlt'] < 1700, 'GarageDummy'] = 0

train_df['BsmtDummy'] = 1
train_df.loc[train_df['BsmtQual'] == 'None', 'BsmtDummy'] = 0
test_df['BsmtDummy'] = 1
test_df.loc[test_df['BsmtQual'] == 'None', 'BsmtDummy'] = 0

#Scatter plot of every variable in the data set against the y variable(SalePrice)
#Plots were used to help identify which variables to remove

for column in train_df:
    train_df.plot(x=column,y='SalePrice',kind='scatter')
    plt.show()

train_df.drop(columns=['Id','Utilities','PoolQC','PoolArea','Condition2','RoofMatl','LowQualFinSF','3SsnPorch','Street', 'Condition1','Heating','Electrical', 'Exterior1st','Foundation', 'Functional','GarageCond', 'PavedDrive','Alley'],inplace=True)
test_df.drop(columns=['Utilities','PoolQC','PoolArea','Condition2','RoofMatl','LowQualFinSF','3SsnPorch','Street', 'Condition1','Heating','Electrical', 'Exterior1st','Foundation', 'Functional','GarageCond', 'PavedDrive','Alley'],inplace=True)

#Histograms to understand shape of data

train_df_numeric = train_df.drop('SalePrice', axis=1)
train_df_numeric = train_df_numeric.apply(pd.to_numeric, errors='coerce')
test_df_numeric = test_df.apply(pd.to_numeric, errors='coerce')
for column in train_df_numeric:
    train_df[column].hist(color='pink')
    test_df[column].hist(color='blue')
    plt.title(column)
    plt.show()

#Get dummies function to encode the categorial data of the test and training set
#align to account for issues where some categorical variables weren't the same in the test set

X_train = pd.get_dummies(train_df.drop('SalePrice', axis=1),drop_first=True)
X_test = pd.get_dummies(test_df.drop('Id', axis=1),drop_first=True)
X_train, X_test = X_train.align(X_test, axis=1, fill_value=0)
Y_train = train_df["SalePrice"]

# Machine Learning Models

#Cross Valudation

from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score

X_train2, X_val, Y_train2, Y_val = train_test_split(X_train, Y_train, test_size=0.2, random_state=0)

from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.tree import DecisionTreeRegressor
import xgboost as xgb
from sklearn.linear_model import Ridge, Lasso

rf = RandomForestRegressor(n_estimators= 10, random_state=0)
dt = DecisionTreeRegressor(max_depth=10,random_state=0)
xg_reg = xgb.XGBRegressor(objective = "reg:linear",n_estimators = 10,random_state=0)
ridge = Ridge(alpha = 0.01,random_state=0)
lasso = Lasso(alpha = 0.01,random_state=0)
gb = GradientBoostingRegressor(max_depth=4, n_estimators=200,random_state=2)

#R squared of the training set for each model
# Random Forest, Decision Trees, XGBoost, and Gradient Boosting had high R squared values

models = [rf,dt,xg_reg,ridge,lasso,gb]
for model in models:
  model.fit(X_train, Y_train)

  Y_predval = model.predict(X_val)

  r2 = r2_score(Y_val, Y_predval)
  print("R^2 Score:", r2)

# MSE
# Same variables with high R squared had the lowest MSEs with gradient boosting having the lowest by a lot
# Decision trees had great performance on the training set but when actually using it for the test set it performed routinely bad, possibly due to overfitting

from sklearn.metrics import mean_squared_error as MSE

for model in models:
  model.fit(X_train, Y_train)

  Y_predval = model.predict(X_val)

  mse = MSE(Y_val, Y_predval)
  rmse = mse**(1/2)
  print("MSE Score:", rmse)

# XGB Regressor 
# XGB feature importance was used to test the variables
# If the feature importance was extremely low for a variable such as > 0.000001 it was removed from the dataset
# Some of variables removed above were removed because of low feature importance in previous iterations of this model

xg_reg.fit(X_train,Y_train)
feature_importance = [(X_train.columns[i], item) for i, item in enumerate(xg_reg.feature_importances_)]

sorted_feature_importance = sorted(feature_importance, key=lambda x: x[1], reverse=True)

for feature, importance in sorted_feature_importance:
    print("{0:s}: {1:.6f}".format(feature, importance))

xgb_params = {
    'colsample_bytree': [0.8, 0.7,0.6],
    'n_estimators': [60,70,80],
    'max_depth': [4,5,7]
}

xgb_grid = GridSearchCV(
    estimator = xg_reg, param_grid =  xgb_params, scoring="neg_mean_squared_error",cv=4,verbose=1
    )

# Gradient Boosting

gb_params = {
    'max_depth':[4,5],
    'n_estimators':[250,275],
    'subsample':[0.75,0.8],
            'max_features':[0.2]
}

gb_grid = GridSearchCV(
    estimator = gb, param_grid =  gb_params, scoring="neg_mean_squared_error",cv=5,verbose=1
    )

# After multiple trials xgb and gradient boosting were most successful models which is why they are the models used in the voting regressor

regressors = [ ('XGBRegressor',xgb_grid),('GradientBoostingRegressor',gb_grid)]

# Combing variables in a voting regression was the most effective method for minimizing RMSE

from sklearn.ensemble import VotingRegressor
vr = VotingRegressor(estimators=regressors)
vr.fit(X_train,Y_train)
Y_pred = vr.predict(X_test)

# submission file to be scored on Kaggle
submission = pd.DataFrame({
        "Id": test_df["Id"],
        "SalePrice": Y_pred
    })
submission.to_csv('dt1.csv', index=False)

files.download('dt1.csv')
