# 导入openxlsx包
library(openxlsx)
library(ggplot2)
library(dplyr)
library(tidyr)

# 读取Excel文件中的数据，假设文件名为"your_file.xlsx"，数据在Sheet1中
setwd("D:/Coding/RProjects/OCE_iGEM_Modeling")

filepath <- "./Data/Raw_data_on_formaldehyde_metabolism_of_Escherichia_coli.xlsx"
df_OD412 <- read.xlsx(filepath,skipEmptyCols = TRUE,skipEmptyRows = TRUE,sheet = "Sheet3")
df_OD600 <- read.xlsx(filepath,skipEmptyCols = TRUE,skipEmptyRows = TRUE,sheet = "Sheet4")
colnames(df_OD600) <- c('Type','M_0','M_10','M_20','M_30','M_40','M_50')

df_std_raw <- read.xlsx(filepath,skipEmptyCols = TRUE,skipEmptyRows = TRUE,sheet = "Sheet2",colNames = F)
df_conc <- t(df_std_raw[1,])
df_std <- df_std_raw[2:4,]
df_std_avg <- colSums(df_std)/3

df_std_data <- data.frame(t(bind_rows(df_std_raw[1,],df_std_avg)))


# std curve fit
std_curve_fit <- lm(df_conc ~ 0+df_std_avg)
summary(std_curve_fit)

k <- coef(std_curve_fit)

std_func <- function(x){
  return(k[1]*x)
}

p <- ggplot(df_std_data, aes(x = X2, y = X1)) +
  #geom_line(color="cornflowerblue",linewidth = 1) +
  geom_point(color="slateblue3",size = 1.5) +
  stat_function(fun = std_func, color = "skyblue3",linewidth=0.8) +  # 添加拟合曲线
  labs(
    title = "Fitted curve of fluorescence signal in units of OD value and HCHO concentration",
    x = "fluorescence signal in unit of OD",
    y = "c(HCHO)/μmol*L-1") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

show(p)
ggsave('std_curve.tiff',p,width = 6,height = 5.2)

df_cell <- list()
for (i in 2:6){
  df_cell[i-1] <- (df_OD600[i]+df_OD600[i+1])/2
}
df_cell <- data.frame(df_cell)
colnames(df_cell) <- c('M_0','M_10','M_20','M_30','M_40')

df_temp <- df_OD412[,2:7]
df_temp <- std_func(df_temp)
print(df_temp == df_HCHO[,1:6])
df_HCHO <- bind_cols(df_temp,df_OD412$Type)
colnames(df_HCHO)[7]<-'Type'

df_HCHO_1 <- df_HCHO %>%
  rowwise() %>%
  filter(Type == 'Cb' || Type == 'BL21')
data_long <- gather(df_HCHO, key = "Time", value = "Value", -Type)
data_long_1 <- gather(df_HCHO_1, key = "Time", value = "Value", -Type)
summary_data <- data_long_1 %>%
  group_by(Time, Type) %>%
  reframe(
    Mean = mean(Value, na.rm = TRUE),
    SD = sd(Value, na.rm = TRUE)
  )
p <- ggplot(summary_data, aes(x = Time, y = Mean,group = Type, color = Type)) +
  geom_point(color='pink2') +
  geom_line(linewidth = 0.5) +
  geom_errorbar(aes(ymin = Mean - SD, ymax = Mean + SD), width = 0.07) +
  labs(title = "Measured HCHO concentration change with time",
       x = "Time/min",
       y = "c(HCHO)/μM",
       color = "Type") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))
show(p)
ggsave('HCHO_consomption_Cb_BL21.tiff',p,width = 6,height = 5.2)

colnames(df_HCHO) <- c('M_0','M_10','M_20','M_30','M_40','M_50','Type')

df_HCHO_mean <- df_HCHO %>%
  group_by(Type) %>%
  summarise(
    mean_0 = mean(M_0),
    mean_10 = mean(M_10),
    mean_20 = mean(M_20),
    mean_30 = mean(M_30),
    mean_40 = mean(M_40),
    mean_50 = mean(M_50)
  )

df_HCHO_sd <- df_HCHO %>%
  group_by(Type) %>%
  summarise(
    sd_0 = sd(M_0),
    sd_10 = sd(M_10),
    sd_20 = sd(M_20),
    sd_30 = sd(M_30),
    sd_40 = sd(M_40),
    sd_50 = sd(M_50)
  )

df_v_mean <- df_HCHO_mean %>%
  select(2:7) %>%
  t() %>%
  as.matrix() %>%
  diff() %>%
  t()

df_v_sd <- df_HCHO_sd %>%
  select(2:7) %>%
  t() %>%
  as.matrix() %>%
  diff() %>%
  t()
  


df_v_mean<-data.frame(df_v_mean[,1:5]/(10))
df_v_mean[is.na(df_v_mean)] <- 0

df_v_sd<-data.frame(df_v_sd[,1:5]/(10))
df_v_sd[is.na(df_v_sd)] <- 0

#cal_mean <- function(x){
#  return((x+lag(x))/2)
#}
df_vtemp <- df_v_mean[4,]
df_v_mean[4,] <- df_v_mean[2,]
df_v_mean[2,] <- df_vtemp

df_vtemp <- df_v_sd[4,]
df_v_sd[4,] <- df_v_sd[2,]
df_v_sd[2,] <- df_vtemp

df_v_mean[1:4,] <- data.frame(df_v_mean[1:4,] / df_cell) 
df_v_sd[1:4,] <- data.frame(df_v_sd[1:4,] / df_cell) 

#for (i in 1:5){
#  print(i)
#  if(i==4){
#    next
#  }
#  df_v_mean <- df_v_mean
#  j <- 1+3*(i-1)
#  df_v[j,] <- df_v[j,] / df_cell[min(i,4),]
#  df_v[(j+1),] <- df_v[(j+1),] / df_cell[min(i,4),]
#  df_v[(j+2),] <- df_v[(j+2),] / df_cell[min(i,4),]
#}

#df_v <- bind_cols(df_v,df_HCHO$Type)
#colnames(df_v) <- c('M_10','M_20','M_30','M_40','M_50','Type')

#df_v_sd<- df_v %>%
#  group_by(Type) %>%
#  reframe(
#    sd_10 = sd(M_10),
#    sd_20 = sd(M_20),
#    sd_30 = sd(M_30),
#    sd_40 = sd(M_40),
#    sd_50 = sd(M_50)
#  ) %>%
#  t()
#df_v_mean<- df_v %>%
#  group_by(Type) %>%
#  reframe(
#    M_10 = mean(M_10),
#    M_20 = mean(M_20),
#   M_30 = mean(M_30),
 #   M_40 = mean(M_40),
  #  M_50 = mean(M_50)
  #) %>%
  #t()


type_name <- c(rep('2b+Kan',5),rep('BL21',5),
               rep('Cb',5),rep('Cb+Kan',5),rep('LB+Kan',5))
time_seq <- c(rep(seq(10,50,10),5))
library(purrr)

df_v_sd_long<-bind_cols(time_seq,as.numeric(t(data.frame(flatten(list(df_v_sd))))),type_name)
df_v_mean_long<-bind_cols(time_seq,as.numeric(t(data.frame(flatten(list(df_v_mean))))),type_name)

colnames(df_v_sd_long) <- c('Time','sd_v','Type')
colnames(df_v_mean_long) <- c('Time','mean_v','Type')

df_data <- bind_cols(df_v_mean_long,df_v_sd_long$sd_v)
colnames(df_data)[4] <- 'sd_v'

p <- ggplot(df_data, aes(x = Time, y = -mean_v,group=Type,color = Type)) +
  geom_line(linewidth = 0.6) +
  geom_point() +
  geom_errorbar(aes(ymin = -mean_v - sd_v, ymax = -mean_v + sd_v),linewidth=0.4, width = 0.7,color="pink3") +
  labs(
    title = "The formaldehyde metabolism rate over time at a unit OD600 value",
    x = "Time/min",
    y = "HCHO consumption velocity/μM * min-1") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))
show(p)

ggsave('HCHO_consomption_velocity_rev.tiff',p,width = 7,height = 5.2)

df_v_mean_1 <- df_v_mean[3:4,]
df_v_sd_1 <- df_v_sd[3:4,]

type_name <- c(rep('Cb',5),
               rep('BL21',5))
time_seq <- c(rep(seq(10,50,10),2))
library(purrr)

df_v_sd_long<-bind_cols(time_seq,as.numeric(t(data.frame(flatten(list(df_v_sd_1))))),type_name)
df_v_mean_long<-bind_cols(time_seq,as.numeric(t(data.frame(flatten(list(df_v_mean_1))))),type_name)

colnames(df_v_sd_long) <- c('Time','sd_v','Type')
colnames(df_v_mean_long) <- c('Time','mean_v','Type')

df_data <- bind_cols(df_v_mean_long,df_v_sd_long$sd_v)
colnames(df_data)[4] <- 'sd_v'

p <- ggplot(df_data, aes(x = Time, y = -mean_v,group=Type,color = Type)) +
  geom_line(linewidth = 0.6) +
  geom_point() +
  geom_errorbar(aes(ymin = -mean_v - sd_v, ymax = -mean_v + sd_v),linewidth=0.4, width = 0.7,color="pink3") +
  labs(
    title = "The formaldehyde metabolism rate over time at a unit OD600 value",
    x = "Time/min",
    y = "HCHO consumption velocity/μM * min-1") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))
show(p)
ggsave('HCHO_consomption_velocity_rev_cb_bl21.tiff',p,width = 7,height = 5.2)
