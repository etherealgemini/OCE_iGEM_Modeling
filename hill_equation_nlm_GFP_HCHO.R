# 假设数据框df中的列名分别为"Time"（时间）、"Concentration"（甲醛浓度）、"Fluorescence"（荧光信号）
# 请根据您的实际数据框列名进行相应调整
# 导入openxlsx包
library(openxlsx)

# 读取Excel文件中的数据，假设文件名为"your_file.xlsx"，数据在Sheet1中
df <- read.xlsx("D:/Coding/jupyter_notebook/iGEM/data/Flu_HCHO_Processed_Full_data.xlsx",skipEmptyCols = TRUE,skipEmptyRows = TRUE)
colnames(df) <- c('Time','Concentration','Fluorescence')


# 导入ggplot2库
library(ggplot2)
library(dplyr)

data_df <- df %>%
  filter(Concentration<251) %>%
  filter(Time<6000) %>%
  filter(Time>2900) %>%
  group_by(Concentration) %>%
  summarize(
    Mean_Fluorescence = mean(Fluorescence),
    SE_Fluorescence = sd(Fluorescence) / sqrt(n())
  )
Smin <- min(data_df["Mean_Fluorescence"])
Smax <- max(data_df["Mean_Fluorescence"])


library(minpack.lm)
# 使用nls函数拟合希尔方程
fit <- nlsLM(Mean_Fluorescence ~ (Smin+(Smax-Smin) * (Concentration^n) / ((Km^n) + (Concentration^n))),
           data = data_df,
           start = list(Km = 50,
                        n = 1))  # 设置初始值
summary(fit)
# 提取拟合的参数n和Km
n <- coef(fit)["n"]
Km <- coef(fit)["Km"]

cor(data_df["Mean_Fluorescence"],predict(fit))

# 绘制带有误差棒的折线图，并加入拟合曲线
p <- ggplot(data_df, aes(x = Concentration, y = Mean_Fluorescence)) +
  #geom_line(color="cornflowerblue",linewidth = 1) +
  geom_point(color="slateblue4") +
  geom_errorbar(aes(ymin = Mean_Fluorescence - SE_Fluorescence, ymax = Mean_Fluorescence + SE_Fluorescence),linewidth=0.5, width = 3,color="slateblue4") +
  stat_function(fun = function(x) Smin+(Smax-Smin) * (x^n) / (Km^n + (x^n)), color = "skyblue3",linewidth=1) +  # 添加拟合曲线
  labs(
  #      title = "Fitted curve of fluorescence signal in units of OD value and HCHO concentration",
       x = "c(HCHO)/μmol*L-1",
       y = "fluorescence signal in unit of OD") +
  theme_minimal()

# 打印图形
print(p)

