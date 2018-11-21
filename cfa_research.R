install.packages('Rblpapi')
library(quantmod) ; library(Rblpapi)

blpConnect(host = getOption('blpHost', 'localhost'), port = getOption('blpPort', 8194L), default = T)

opt <- c("periodicitySelection"="Daily")

UST10TY <- bdh('USGG10YR Index', c('PX_LAST'), start.date = as.Date('2011-01-01'),)

C <- bdh('USGG10YR Index', c('PX_LAST'), start.date = as.Date('2011-01-01'),)

