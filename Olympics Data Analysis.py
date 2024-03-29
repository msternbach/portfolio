# This was a group project for one of my MBA classes. One of my group members and I wrote the code for the project.

# Introduction

'''
Our project is based on a dataset of over 70,000 olympic athletes dating from the late 1800s until today. This dataset includes numerous variables including biometric data,
nationality, olympic sport, locatiom, and what medal they won if any. The purpose of our research is to determine which biometric attributes are most commonly found in
winners of gold medals in different olympic sports. For this reason, we will focus on age, weight, height, sex
'''

# Problem Statement

'''
Attempting to understand and measure the correlation between height, weight, and age with performance/ placement in the olympic games
'''

 # Project Objectives

'''
- Analyze and examine the relationship between these metrics and performance in the olympics
- Identify an ideal weight, age, and height index range that most olympic medals fall into
- Potentially use this data as a way to identify and forecast who will perform well in future olympics
'''

# Results and Discussion

#import libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# import csv file to dataframe format
df = pd.read_csv('dataset_olympics.csv')

# count the amount of entries missing for each column
df.isna().sum()

# drop the rows that are missing data for 'Age', 'Height, or 'Weight'
df = df.dropna(subset=['Age','Height','Weight'])

# Check that 'Medal' is the only column missing data
df.isna().sum()

# Fill all 'Metal' entries that are empty with the integer 0
df['Medal'] = df['Medal'].fillna(0)

# Replace all Metal values that are not the integer 0 with the integer 1
Bin_Medal = (df['Medal'] != 0).astype(int)
df['Medal'] = Bin_Medal

df = df.drop_duplicates(subset=['Name','Age','Games','Sport','Medal'])

df = df.sort_values(['Name','Games','Age','Medal'])

df = df.drop_duplicates(subset=['Name','Age','Games','Sport'],keep='last')

# Create a seperate DataFrame for male and female athletes
fem_df = df[df['Sex'] == 'F']
male_df = df[df['Sex'] == 'M']

# group the median age data by 'Sport' and then by 'Medal'
medmale = male_df.groupby(["Sport","Medal"])['Age'].median().unstack()
medfemale = fem_df.groupby(["Sport","Medal"])['Age'].median().unstack()
medmale0 = medmale[0].sort_values()
medmale1 = medmale[1].sort_values()
medfemale0 = medfemale[0].sort_values()
medfemale1 = medfemale[1].sort_values()
print(medmale)

#plot the median age of men who did not medal(Blue) and men who did (Orange) for each sport
plt.figure(figsize=(10, 6))
medmale0.plot(kind="bar",color="blue",position=1, width=0.4)
medmale1.plot(kind="bar",color="orange",position=0, width=0.4)
plt.xlabel('Sport')
plt.ylabel('Age')
plt.title('Median Male Ages')
plt.show()

#plot the median age of women who did not medal(Blue) and women who did (Orange) for each sport
plt.figure(figsize=(10, 6))
medfemale0.plot(kind="bar",color="blue",position=1, width=0.4)
medfemale1.plot(kind="bar",color="orange",position=0, width=0.4)
plt.xlabel('Sport')
plt.ylabel('Age')
plt.title('Median Female Ages')
plt.show()

# group the median height data by 'Sport' and then by 'Medal'
medmale = male_df.groupby(["Sport","Medal"])['Height'].median().unstack()
medfemale = fem_df.groupby(["Sport","Medal"])['Height'].median().unstack()
medmale0 = medmale[0].sort_values()
medmale1 = medmale[1].sort_values()
medfemale0 = medfemale[0].sort_values()
medfemale1 = medfemale[1].sort_values()

#plot the median height of men who did not medal(Blue) and men who did (Orange) for each sport
plt.figure(figsize=(10, 6))
medmale0.plot(kind="bar",color="blue",position=1, width=0.4)
medmale1.plot(kind="bar",color="orange",position=0, width=0.4)
plt.xlabel('Sport')
plt.ylabel('Height')
plt.title('Median Male Height')
plt.show()

#plot the median height of women who did not medal(Blue) and women who did (Orange) for each sport
plt.figure(figsize=(10, 6))
medfemale0.plot(kind="bar",color="blue",position=1, width=0.4)
medfemale1.plot(kind="bar",color="orange",position=0, width=0.4)
plt.xlabel('Sport')
plt.ylabel('Height')
plt.title('Median Female Heights')
plt.show()

# group the median 'Weight' data by 'Sport' and then by 'Medal'
medmale = male_df.groupby(["Sport","Medal"])['Weight'].median().unstack()
medfemale = fem_df.groupby(["Sport","Medal"])['Weight'].median().unstack()
medmale0 = medmale[0].sort_values()
medmale1 = medmale[1].sort_values()
medfemale0 = medfemale[0].sort_values()
medfemale1 = medfemale[1].sort_values()

#plot the median weight of men who did not medal(Blue) and men who did (Orange) for each sport
plt.figure(figsize=(10, 6))
medmale0.plot(kind="bar",color="blue",position=1, width=0.4)
medmale1.plot(kind="bar",color="orange",position=0, width=0.4)
plt.xlabel('Sport')
plt.ylabel('Weight')
plt.title('Median Male Weight')
plt.show()

#plot the median weight of women who did not medal(Blue) and women who did (Orange) for each sport
plt.figure(figsize=(10, 6))
medfemale0.plot(kind="bar",color="blue",position=1, width=0.4)
medfemale1.plot(kind="bar",color="orange",position=0, width=0.4)
plt.xlabel('Sport')
plt.ylabel('Weight')
plt.title('Median Female Weights')
plt.show()

# group the mean age data by 'Sport' and then by 'Medal'
medmale_age = male_df.groupby(["Year","Medal"])['Age'].mean().unstack()
medfemale_age = fem_df.groupby(["Year","Medal"])['Age'].mean().unstack()
medmale_age0 = medmale_age[0]
medmale_age1 = medmale_age[1]
medfemale_age0 = medfemale_age[0]
medfemale_age1 = medfemale_age[1]
print(medmale_age)

#plot the mean age of men who did not medal(Blue) and men who did (Orange) for each sport
plt.figure(figsize=(10, 6))
medmale_age0.plot(kind="bar",color="blue",position=1, width=0.4)
medmale_age1.plot(kind="bar",color="orange",position=0, width=0.4)
plt.xlabel('Year')
plt.ylabel('Age')
plt.title('Mean Male Ages Over Time')
plt.show()

#plot the mean weight of women who did not medal(Blue) and women who did (Orange) for each sport
plt.figure(figsize=(10, 6))
medfemale_age0.plot(kind="bar",color="blue",position=1, width=0.4)
medfemale_age1.plot(kind="bar",color="orange",position=0, width=0.4)
plt.xlabel('Year')
plt.ylabel('Age')
plt.title('Mean Female Ages Over Time')
plt.show()

# group the mean 'Height' data by 'Sport' and then by 'Medal'
medmale_height = male_df.groupby(["Year","Medal"])['Height'].mean().unstack()
medfemale_height = fem_df.groupby(["Year","Medal"])['Height'].mean().unstack()
medmale_height0 = medmale_height[0]
medmale_height1 = medmale_height[1]
medfemale_height0 = medfemale_height[0]
medfemale_height1 = medfemale_height[1]
print(medmale_height)

#plot the mean height of men who did not medal(Blue) and men who did (Orange) for each sport
plt.figure(figsize=(10, 6))
medmale_height0.plot(kind="bar",color="blue",position=1, width=0.4)
medmale_height1.plot(kind="bar",color="orange",position=0, width=0.4)
plt.xlabel('Year')
plt.ylabel('Height')
plt.title('Mean Male Heights Over Time')
plt.show()

#plot the mean height of women who did not medal(Blue) and women who did (Orange) for each sport
plt.figure(figsize=(10, 6))
medfemale_height0.plot(kind="bar",color="blue",position=1, width=0.4)
medfemale_height1.plot(kind="bar",color="orange",position=0, width=0.4)
plt.xlabel('Year')
plt.ylabel('Height')
plt.title('Mean Female Heights Over Time')
plt.show()

# group the mean 'Weight' data by 'Sport' and then by 'Medal'
medmale_weight = male_df.groupby(["Year","Medal"])['Weight'].mean().unstack()
medfemale_weight = fem_df.groupby(["Year","Medal"])['Weight'].mean().unstack()
medmale_weight0 = medmale_weight[0]
medmale_weight1 = medmale_weight[1]
medfemale_weight0 = medfemale_weight[0]
medfemale_weight1 = medfemale_weight[1]

#plot the mean weight of men who did not medal(Blue) and men who did (Orange) for each sport
plt.figure(figsize=(10, 6))
medmale_weight0.plot(kind="bar",color="blue",position=1, width=0.4)
medmale_weight1.plot(kind="bar",color="orange",position=0, width=0.4)
plt.xlabel('Year')
plt.ylabel('Weight')
plt.title('Mean Male Weights Over Time')
plt.show()

#plot the mean weight of women who did not medal(Blue) and women who did (Orange) for each sport
plt.figure(figsize=(10, 6))
medfemale_weight0.plot(kind="bar",color="blue",position=1, width=0.4)
medfemale_weight1.plot(kind="bar",color="orange",position=0, width=0.4)
plt.xlabel('Year')
plt.ylabel('Weight')
plt.title('Mean Female Weights Over Time')
plt.show()

# get dummy values for year, sex, sport, age, height, weight
olympic_dummies = pd.get_dummies(df[['Year','Sex','Sport','Age','Height','Weight']],drop_first=True)

# set X to the dummy values and y to the 'Medal' values
X = olympic_dummies.values
y = df['Medal'].values

# split the data into a training set and a testing set
from sklearn.model_selection import train_test_split
X_train, X_test, y_train,y_test = train_test_split(X,y,test_size=0.2)
len(X_test)

# use standardscaler to standerdize the data for X_trian and X_test
from sklearn.preprocessing import StandardScaler
sc = StandardScaler()
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)

# Print out the number of datapoints for each sport
print(fem_df.Sport.value_counts())
print(male_df.Sport.value_counts())

# Function to use Random Forest Analysis on females in specified sport
from sklearn.metrics import precision_score,recall_score
def FemSportAccuracy(Sport):
  fem_sport_df = fem_df[fem_df['Sport'] == Sport]
  fem_sport_dummies = pd.get_dummies(fem_sport_df[['Year','Sex','Sport','Age','Height','Weight']],drop_first=True)
  X = fem_sport_dummies.values
  y = fem_sport_df['Medal'].values
  X_train, X_test, y_train, y_test = train_test_split(X,y,test_size=0.2)
  sc = StandardScaler()
  X_train = sc.fit_transform(X_train)
  X_test = sc.transform(X_test)
  classifier = RandomForestClassifier(n_estimators = 10, criterion = 'entropy', random_state = 0)
  classifier.fit(X_train, y_train)
  y_pred = classifier.predict(X_test)
  cm = confusion_matrix(y_test, y_pred)
  print(cm)
  print("accuracy score: ",accuracy_score(y_test, y_pred))
  print("recall score: ",recall_score(y_test, y_pred))
  print("precision score: ",precision_score(y_test, y_pred))

# Function to use Random Forest Analysis on males in specified sport
def MaleSportAccuracy(Sport):
  male_sport_df = male_df[male_df['Sport'] == Sport]
  male_sport_dummies = pd.get_dummies(male_sport_df[['Year','Sex','Sport','Age','Height','Weight']],drop_first=True)
  X = male_sport_dummies.values
  y = male_sport_df['Medal'].values
  X_train, X_test, y_train, y_test = train_test_split(X,y,test_size=0.2)
  sc = StandardScaler()
  X_train = sc.fit_transform(X_train)
  X_test = sc.transform(X_test)
  classifier = RandomForestClassifier(n_estimators = 10, criterion = 'entropy', random_state = 0)
  classifier.fit(X_train, y_train)
  y_pred = classifier.predict(X_test)
  cm = confusion_matrix(y_test, y_pred)
  print(cm)
  print("accuracy score: ",accuracy_score(y_test, y_pred))
  print("recall score: ",recall_score(y_test, y_pred))
  print("precision score: ",precision_score(y_test, y_pred))

FemSportAccuracy('Athletics')

FemSportAccuracy('Swimming')

FemSportAccuracy('Gymnastics')

MaleSportAccuracy('Athletics')

MaleSportAccuracy('Swimming')

MaleSportAccuracy('Rowing')

# Conclusions

'''
Based on the data collected, it is apparent that many sports favor those with a larger body. When compared against each other. Sports like basketball, volleyball, handball,
and rowing tend to be composed of athletes who are on average taller and heavier than those of sports like gymnastics, trampolining and table tennis. This makes sense, as
height and weight is advantageous to athletes in certain sports but not in others. When biometrics were analyzed on athletes of a single sport compared to each other, there
was not a significant difference between the heights and weights of gold medal winners compared to those who did not win gold. In general the median weights, ages, and 
heights of olympic winners tended to be slightly higher than those who did not medal. The age amongst Olympic winners for both men and women fall into the 21-25 year old 
range. Certain sports such as sailing, golf, and equestrian however, are outliers as they have median ages in the 30-40 year old range. This makes sense as these sports are
not as physically taxing on the body, and benefit those who are older and may possess more skills or knowledge. Our main conclusion was that certain biometric attributes are
more advantageous when it comes to participating in certain sports, but are less likely to be a determining factor when it comes to winning gold medals. As a result, even
though there are relationships between these atributes and the likelyhood of winning an olympic medal, these relationships are not strong enough for machine learning to be
implemented in order to accurately predict winners. Even though inaccurate however, the scores of models were better for some sports than others indicating the relationship
between age, weight, and height matters more in those sports.
'''

