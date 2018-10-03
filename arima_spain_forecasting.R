install.packages('tidyverse')
install.packages('eurostat')
install.packages('forecast')
install.packages('GGally')

library('tidyverse')
library('eurostat')
library('forecast')
library('GGally')

data <- get_eurostat('namq_10_gdp', time_forecast = 'num')
data <- label_eurostat(data)

data <- data %>% 
        mutate(geo = as.character(geo)) %>% 
          filter(unit == "Current prices, million euro",
                 s_adj == "Unadjusted data (i.e. neither seasonally adjusted nor calendar adjusted data)",
                 geo == "Spain") %>% 
                    arrange(time) %>% 
                        spread(na_item, values)
data$unit <- NULL  
data$s_adj <- NULL
data$geo <- NULL

data <- data[, c(1,3,7,18,19,22,31)]

names(data)[2] <- paste('GDP')
names(data)[3] <- paste('Consumption')
names(data)[4] <- paste('Gross Capital')
names(data)[5] <- paste('Export')
names(data)[6] <- paste('Imports')
names(data)[7] <- paste('Salaries')


names(data)

data <- ts(data[, -1], start = c(1995,1), frequency = 4)
head(data, 20)

#Plot all the time series together

autoplot(data, facets =  TRUE) +
  labs(title = 'Time Series plot of Spain economic indicators',
       subtitle = '1995-2018 / In millions of euros (€)',
       y = 'millions of euros (€)',
       x = 'Period')

#Plot the GDP time series
autoplot(data[, 'GDP']) +
  labs(titles = 'Spains GDP evoluation',
       subtitle = '1995-2018 / In millions of euros (€)',
       y = 'GDP (€) in millions',
       x = 'Period')

#Subseries plot

ggsubseriesplot(data[,'GDP']) +
  labs(title = 'Subseries Plot: observe average seasonality for all years',
       subtitle = 'Spains quarterly GDP',
       y = 'GDP (€) in millions')

# Seasonplot

ggseasonplot(data[,'GDP'], year.labels = TRUE, year.labels.left = TRUE) +
  labs(titles = 'Subseries Plot: observe seasonally in each year',
       subtitle = 'Spain quarterly GDP',
       y = 'GDP (€) in millions') +
  theme_classic()

train_set <- window(data, end = c(2016, 4))

#Fit ARIMA model

arima_train <- auto.arima(train_set[, 'GDP'],
                          trace = FALSE,
                          ic = 'aicc',
                          approximation = FALSE,
                          stepwise = FALSE,
                          lambda = 'auto')
arima_train

checkresiduals(arima_train)

round(accuracy(forecast(arima_train, h = 5), data[,'GDP']), 3)

arima_full <- auto.arima(data[,'GDP'],
                         trace = FALSE,
                         ic = 'aicc',
                         approximation =FALSE,
                         stepwise = FALSE,
                         lambda =  'auto')

arima_full

# Forecast and plot

options(scipen = 999)

arima_full %>% forecast(h = 8) %>% autoplot() +
  labs(title = 'Spains quarterly GDP forecast: ARIMA modelling',
       subtitle = 'In millions of euro (€), 2018-19',
       y = 'GDP (€)')+
  scale_x_continuous(breaks = seq(1995, 2020, 1)) +
  theme(axis.text.x = element_text(angle =  45, hjust = 1))

gdp_fcst <- as.data.frame(forecast(arima_full, h = 8))
gdp_fcst$Indicator <- 'GDP'
gdp_fcst$Period <- rownames(gdp_fcst)
gdp_fcst

#Consumption

consumption_model <- auto.arima(data[, "Consumption"], 
                                trace = FALSE, 
                                ic = "aicc", 
                                approximation = FALSE,
                                stepwise = FALSE,
                                lambda = "auto")
consumption_model %>%
  forecast(h = 8) %>%
  autoplot() +
  labs(title = 'Spains quarterly Consumption forecast: ARIMA modelling',
       subtitle = 'In million euro (€), for years 2018-2019',
       y = 'GDP (€)')+
  scale_x_continuous(breaks = seq(1995, 2020, 1)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

con_fcst <- as.data.frame(forecast(consumption_model, h = 8))
con_fcst$Indicator <- 'Consumption'
con_fcst$Period <-  rownames(con_fcst)

#Gross Capital

Gross_Capital_model <-  auto.arima(data[,'Gross Capital'],
                                   trace = FALSE,
                                   ic = 'aicc',
                                   approximation =FALSE,
                                   stepwise = FALSE,
                                   lambda = 'auto')

Gross_Capital_model %>%
  forecast(h = 8) %>%
  autoplot() +
  labs(title = 'Spains quarterly Gross Capital forecast: ARIMA modelling',
       subtitle = 'In million euro (€), for years 2018-19',
       y= 'GDP (€)')+
  scale_x_continuous(breaks = seq(1995, 2020, 1)) +
  theme(axis.text.x = element_text(angle = 45, hjust =1))
