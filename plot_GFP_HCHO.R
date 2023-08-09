# 假设数据框df中的列名分别为"Time"（时间）、"Concentration"（甲醛浓度）、"Fluorescence"（荧光信号）
# 导入openxlsx包
library(openxlsx)
library(ggGenshin)
# 读取Excel文件中的数据
df <- read.xlsx("D:/Coding/jupyter_notebook/iGEM/data/Flu_HCHO_Processed_Full_data.xlsx",skipEmptyCols = TRUE,skipEmptyRows = TRUE)
colnames(df) <- c('Time','Concentration','Fluorescence')

# 导入ggplot2库
library(ggplot2)
library(dplyr)

data_df <- df %>%
  filter(Concentration<251) %>%
  filter(Time<6100) %>%
  filter(Time>2900) %>%
  group_by(Time,Concentration) %>%
  summarize(
    Mean_Fluorescence = mean(Fluorescence),
    SE_Fluorescence = sd(Fluorescence) / sqrt(n())
  )
Smin <- min(data_df["Mean_Fluorescence"])
Smax <- max(data_df["Mean_Fluorescence"])


# 绘制带有误差棒的折线图
# 甲醛浓度/μmol*L-1 c(HCHO)/μmol*L-1
# 时间/sec Time/sec
# 单位OD值荧光信号
p<- ggplot(data_df, aes(x = Concentration, y = Mean_Fluorescence, group = Time, color = Time)) +
  geom_line() +
  geom_point() +
  geom_errorbar(aes(ymin = Mean_Fluorescence - SE_Fluorescence, ymax = Mean_Fluorescence + SE_Fluorescence), width = 3) +
  labs(x = "c(HCHO)/μmol*L-1",
       y = "Fluorescence intensity in units of OD",
       color = "Time/sec") +
  theme_minimal()+
  scale_color_gradient(low = "pink",high = "blue")
 # scale_color_gradient2(low = "pink1",mid = "blue",midpoint = 5000 ,high = "darkblue")
 # geom_vline(xintercept = 0,color = "black",linetype = "dashed")+
 # geom_vline(xintercept = 251,color = "black",linetype = "dashed")

print(p)
