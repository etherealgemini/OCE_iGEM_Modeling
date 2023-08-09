# 假设数据框df中的列名分别为"Time"（时间）、"Concentration"（甲醛浓度）、"Fluorescence"（荧光信号）
# 请根据您的实际数据框列名进行相应调整
# 导入openxlsx包
library(openxlsx)

# 读取Excel文件中的数据，假设文件名为"your_file.xlsx"，数据在Sheet1中
df <- read.xlsx("D:/Coding/jupyter_notebook/iGEM/data/test2.xlsx",skipEmptyCols = TRUE,skipEmptyRows = TRUE)
colnames(df) <- c('Time','Concentration','Fluorescence')

# 导入ggplot2库
library(ggplot2)





# 绘制带有误差棒的折线图
# ggplot(summary_df, aes(x = Concentration, y = Mean_Fluorescence, group = Time, color = Time)) +
#  geom_line() +
#  geom_point() +
#  geom_errorbar(aes(ymin = Mean_Fluorescence - SE_Fluorescence, ymax = Mean_Fluorescence + SE_Fluorescence), width = 0.2) +
#  labs(title = "荧光信号随甲醛浓度变化图",
#       x = "甲醛浓度",
#       y = "荧光信号",
#       color = "时间") +
#  theme_minimal()


# 假设您的数据框df中有"Concentration"列和"Fluorescence"列，分别表示甲醛浓度和荧光信号值



# 假设您的数据框df中有"Time"、"Concentration"和"Fluorescence"列，分别表示时间点、甲醛浓度和荧光信号值



# 假设您的数据框df中有"Time"、"Concentration"和"Fluorescence"列，分别表示时间点、甲醛浓度和荧光信号值
# 计算每个时间点、每个甲醛浓度下的平均值和标准误差

# 计算希尔变换后的响应变量H
df$H <- log(df$Fluorescence / (max(0.0001,max(df$Fluorescence) - df$Fluorescence)))
library(dplyr)

data_df <- df %>%
  group_by(Concentration) %>%
  summarize(
    Time = Time,
    x = log(Concentration),
    H = mean(H)
    # SE_H = sd(H) / sqrt(n())
  )
#log(S) = nlog(x/(x_max-x)) + nlog(Km)
# summary_df <- df %>%
#   group_by(Time,Concentration) %>%
#   summarize(
#     Mean_H = mean(H),
#     SE_H = sd(H) / sqrt(n())
#   )
fit <- nlsLM(H ~ k*(b+x),data = data_df,start = c(k=1,b=-1))
summary(fit)
# 绘制希尔图
k <- coef(fit)["k"]
b <- coef(fit)["b"]

p <- ggplot(data_df, aes(x = log(Concentration), y = H, group = Time, color = Time)) +
  geom_line() +
  geom_point() +
  stat_function(fun = function(x) k*(b +x), color = "red", linetype = "dashed")+
  # geom_errorbar(aes(ymin = H - SE_H, ymax = H + SE_H), width = 0.2) +
  labs(title = "希尔作图法处理荧光信号随甲醛浓度变化图",
       x = "log(甲醛浓度)",
       y = "H",
       color = "时间") +
  theme_minimal()

# 打印图形
print(p)