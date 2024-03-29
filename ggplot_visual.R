#setting path
setwd('C:/Users/600037209/Documents/Classes/R/Data Processing')

#import libraries
library(readxl)
library(dplyr)

#importing data
Data = read_excel('C:/Users/600037209/Documents/Classes/Project/Sales Data.xlsx', sheet="Data")
head(Data)
View(Data)
names(Data)
str(Data)

#Rename columns
names(Data)[1] = "Unique Store Code"
names(Data)[names(Data) == "Residential Index (Lookup)"] = "Residential Index"
names(Data)[names(Data) == "Commercial Index (lookup)"] = "Commercial Index"

#Delete unused variables
Sales_df <- Data[-c(2,5,6,8)]

#converting variables to factors and numeric
Sales_df$`Unique Store Code` <- as.factor(Sales_df$`Unique Store Code`)
Sales_df$`Sales-Bucket` <- as.factor(Sales_df$`Sales-Bucket`)
Sales_df$Neighbourhood <- as.factor(Sales_df$Neighbourhood)
Sales_df$`Total households` <- as.numeric(Sales_df$`Total households`) 
Sales_df$`Total population` <- as.numeric(Sales_df$`Total population`)
Sales_df$`Per capita income` <- as.numeric(Sales_df$`Per capita income`)
Sales_df$`Per capita savings` <- as.numeric(Sales_df$`Per capita savings`)
Sales_df$`Per capita expenditure` <- as.numeric(Sales_df$`Per capita expenditure`)
Sales_df$`Total household income` <- as.numeric(Sales_df$`Total household income`)
Sales_df$`Total household expenditure` <- as.numeric(Sales_df$`Total household expenditure`)
Sales_df$`Residential Index` <- as.factor(Sales_df$`Residential Index`)
Sales_df$`Commercial Index` <- as.factor(Sales_df$`Commercial Index`)
Sales_df$`Poverty Index` <- as.factor(Sales_df$`Poverty Index`)

str(Sales_df)

#missing values
colSums(is.na(Data))
colSums(is.na(Sales_df))

#Taking missing values as a seperate
missing_data<-subset(Sales_df, is.na(`Total households`))

#Taking not null values
Sales_data<-subset(Sales_df, !is.na(`Total households`))

str(Sales_data)
colSums(is.na(Sales_data))


levels(Sales_data$`Residential Index`)

#Dropping NA factor
Sales_data <- droplevels(Sales_data)

#Trimming whitespaces
Sales_data$Neighbourhood <- trimws(Sales_data$Neighbourhood)

#Creating Store count
test <- Sales_data[,c("Unique Store Code","Neighbourhood")] %>% arrange(`Neighbourhood`) %>% group_by(`Neighbourhood`) %>% summarize(`Store Count` = n())

uni <- Sales_data['Neighbourhood'] %>% arrange(`Neighbourhood`) %>% unique()


Temp_df <- data.frame(test$`Store Count`,uni)
names(Temp_df)[1] <- "Store Count"

Sales_full_data <- merge(Sales_data,Temp_df, by='Neighbourhood')

#creating Average household size
Sales_full_data$`Average household size` <- Sales_full_data$`Total household income` / Sales_full_data$`Total households`

max(Sales_full_data$Sales)

#Deleting Outliers
outliers <- boxplot(Sales_full_data$Sales, plot=FALSE)$out
Sales_dat <- Sales_full_data[-which(Sales_full_data$Sales %in% outliers),]

#visualization
library(ggplot2)
library(ggthemes)
#Box plot
ggplot(Sales_dat, aes(y=Sales)) + geom_boxplot()

#Histogram
ggplot(Sales_dat, aes(x=Sales)) + geom_density()

#Bar graph
p <- ggplot(Sales_dat, aes(x=`Sales-Bucket`)) + geom_bar() + labs(x = "Sales Bucket", y = "Frequency", title = 'Sales frequency bar plot', subtitle = 'Just a bar plot',caption = 'This is a caption') + theme_classic()

ggplotly(p)

Sales_dat %>% arrange(`Sales`) %>% tail(10) %>%  ggplot(aes(x=Neighbourhood , y=Sales )) + geom_bar(stat = 'identity') + theme_tufte()
str(Sales_dat)
names(Sales_dat)
#scatter plot
p <- ggplot(Sales_dat, aes(x=`Total households`, y = `Total population`, z=`Sales`)) + geom_point(aes(x=`Total population`,y=`Sales`, col = 'Total Population')) + geom_point(aes(x=`Per capita income`,y=`Sales`, col = 'Per capita income'))
ggplotly(p)
options(scipen = 999)

