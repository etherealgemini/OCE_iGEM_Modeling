

fit <- nlsLM(Mean_Fluorescence ~ (Smin+(Smax-Smin) * (Concentration^n) / ((Km^n) + (Concentration^n))),
             data = data_df,
             start = list(Km = 50,
                          n = 1))  # 设置初始值