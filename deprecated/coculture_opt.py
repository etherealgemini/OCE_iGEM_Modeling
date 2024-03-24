import numpy as np
from scipy.optimize import minimize


# 定义目标函数
def objective_function(vars):
    m_ecoli, m_algae = vars
    return -m_ecoli  # 最大化大肠杆菌的干重，因此加负号


# 定义约束条件
def constraint(vars):
    m_ecoli_0, m_algae_0 = vars
    m_ecoli = m_ecoli_0*np.exp(μ_1*t)
    m_algae = m_algae_0*np.exp(μ_2*t)
    return [
        - 2*Y_x_glc * m_ecoli + m_algae * v_suc,  # 葡萄糖消耗速率约束
        - m_ecoli - m_algae + C  # 总干重约束
    ]



# 定义优化问题
problem = {
    'fun': objective_function,
    'constraints': constraint,
    'bounds': [(0, None), (0, None)]
}

# 初始猜测值
initial_guess = [1.0, 1.0]  # 请根据具体情况设定初始值

# 参数示例（请根据实际情况修改）
Y_x_glc = 0.41*1000/180.16
μ_1 = 0.38
μ_2 = 0.054
t = 0.01
m_0 = 0
v_suc = 0.15
C = 100

# 求解优化问题
uneq_1 = {'type': 'ineq', 'fun': constraint}
result = minimize(objective_function, np.array(initial_guess), constraints=uneq_1)

# 输出结果
optimized_m_ecoli, optimized_m_algae = result.x
maximized_value = -result.fun  # 因为目标函数带了负号，这里取相反数得到最大值

# print("Maximum e_coli biomass (g)：", optimized_m_ecoli)
# print("最大化值：", maximized_value)
# print("Corresponding algae biomass (g)：", optimized_m_algae)
print("Optimize ratio: m_ecoli_tot:m_algae = %f:%f = %f" % (optimized_m_algae,optimized_m_ecoli,optimized_m_algae/optimized_m_ecoli))
