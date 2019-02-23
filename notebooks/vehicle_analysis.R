library('dplyr')
library('ggplot2')

setwd('~/Desktop/datathon/datathon/Datasets/')
air_concentrations <- read.csv('air_concentrations.csv')
energy_workforce_training <- read.csv('energy_workforce_training.csv')
land_temp_by_city <- read.csv('land_temp_by_city.csv')
land_temp_by_state <- read.csv('land_temp_by_state.csv')
power_plants <- read.csv('power_plants.csv')
revenue_to_provider <- read.csv('revenue_to_provider.csv')
seds <- read.csv('seds.csv')
vehicles <- read.csv('vehicles.csv')

vehicles_with_co2 <- vehicles[!is.na(vehicles$co2), ]
vehicles_single_fuel <- vehicles_with_co2 %>% filter(fuel_type_alt == '')
table(vehicles_single_fuel %>% filter(year==2017))

sort(table(energy_workforce_training$state_code), decreasing = T)


# Number of EV models per manufacturers per year
ev_num <- vehicles_with_co2 %>% filter(fuel_type_alt == '') %>% 
  group_by(year, make, fuel_type) %>% summarize(count=n())


toyota_corolla <- vehicles_single_fuel %>% filter(make == 'Toyota' & model == 'Corolla') %>% arrange(year)
plot(toyota_corolla$year, toyota_corolla$petrol_consump, type='l')
plot(toyota_corolla$year, toyota_corolla$co2, type='l')

vehicles_with_co2$dual <- 'Single fuel (Non-electric)'
vehicles_with_co2[vehicles_with_co2$fuel_type_alt == '' & vehicles_with_co2$fuel_type == 'Electricity', 
                  'dual'] <- 'Single fuel (Electric)'
vehicles_with_co2[vehicles_with_co2$fuel_type_alt != '' & (vehicles_with_co2$fuel_type == 'Electricity' | 
                                                             vehicles_with_co2$fuel_type_alt == 'Electricity'), 
                  'dual'] <- 'Hybrid (Electric)'
vehicles_with_co2[vehicles_with_co2$fuel_type_alt != '' & (vehicles_with_co2$fuel_type != 'Electricity' & 
                                                             vehicles_with_co2$fuel_type_alt != 'Electricity'), 
                  'dual'] <- 'Hybrid (Non-electric)'

plot(vehicles_with_co2$petrol_consump, vehicles_with_co2$co2,
     col=as.factor(vehicles_with_co2$dual), xlab='petrol consumption', ylab='CO2')
legend('bottomright', legend=levels(as.factor(vehicles_with_co2$dual)), col=1:4, pch=1)
table(vehicles_with_co2$dual)

year_dual_count <- vehicles_with_co2 %>% group_by(year, dual) %>% 
  summarize(count=n())

ggplot(year_dual_count %>% filter(dual %in% c('Hybrid (Electric)', 'Single fuel (Electric)')), 
       aes(x=year, y=count, color=dual)) + geom_line()


plot(vehicles_with_co2$petrol_consump, vehicles_with_co2$co2,
     col=as.factor(vehicles_with_co2$dual), xlab='petrol consumption', ylab='CO2')
legend('bottomright', legend=levels(as.factor(vehicles_with_co2$dual)), col=1:4, pch=1)

ggplot(year_dual_count, 
       aes(x=year, y=log(count), color=dual)) + geom_line()

mean_savings_list <- lapply(2008:2017, function(curr_year) {
  recent <- vehicles_with_co2 %>% filter(year >= curr_year - 5) 
  most_recent <- vehicles_with_co2 %>% select(year, make, model) %>%
    filter(year >= curr_year - 5) %>%
    group_by(make, model) %>%
    summarize(year=max(year)) %>%
    inner_join(recent, by=c('make', 'model', 'year'))
  mean_savings <- most_recent %>% group_by(dual) %>%
    summarize(mean_savings=mean(you_saved_spend)) %>%
    arrange(desc(mean_savings))
  mean_savings$year <- curr_year
  mean_savings
})

mean_savings_df <- do.call(rbind, mean_savings_list)
mean_savings_df$type <- mean_savings_df$dual
ggplot(mean_savings_df, aes(x=year, y=mean_savings, color=type, lty=type)) + 
  geom_line(lwd=1.1) + geom_point(size=2) + 
  ggtitle('Mean savings for different fuel types') +
  ylab('mean savings') +
  xlab('year') +
  scale_x_continuous(breaks = seq(2008, 2017, by = 2))
  theme_set(theme_grey(base_size = 13)) 
  
# Number of hybrid cars from 2012 to 2017 
df_recent <- vehicles_with_co2 %>% filter(year >= 2012)
df <- with(df_recent, table(vehicle_class, dual))  
df[rowSums(df) == 0, ]

table_recent <- with(df_recent, table(make, dual))
env <- table_recent[, c(1, 3)]
env[rowSums(env) != 0, ]
mean(rowSums(env) != 0)


year_dual_count$type <- year_dual_count$dual
ggplot(year_dual_count, 
       aes(x=year, y=log(count), color=type, lty=type)) + 
  geom_line() + geom_point() +
  geom_vline(xintercept=c(1995, 2007)) +
  scale_x_continuous(breaks = c(1960, 1980, 1995, 2000, 2007, 2017)) +
  ggtitle('Number of new models')
  
