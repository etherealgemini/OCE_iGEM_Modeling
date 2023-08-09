import copy

import xlrd3
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

# transform the table in Excel to a numpy array.
def ex2nparray(ws, row_0, col_0, row_t, col_t):
    col = col_t - col_0
    row = row_t - row_0
    matrix = np.zeros((row, col))

    for x in range(col):
        for y in range(row):
            matrix[y, x] = ws.cell_value(y + row_0, x + col_0)

    return matrix


wb1 = xlrd3.open_workbook('./data/OD600 & FLUORESCENCE oce (Modified)_20230705_235.xlsx')
ws1 = wb1.sheet_by_index(1)

# trying to represent special numbers in a clean way, but seems failed.
num = 12 * 2
nxt = 13

row_st = 5
col_st = 1
CONT_NUM = 9
BLANK = 9
LB = 10

data = []

for m in range(num):
    next_frame = nxt * m
    matrix = ex2nparray(ws1, row_st + next_frame, col_st,
                        row_st + next_frame + 3, col_st + 11)

    data.append(matrix)

# (fl_1~CONT_NUM - fl_11)/(od_1~CONT_NUM - od_11) - (fl_10-fl_11)/(od_10-od_11)

result = np.zeros((1 + 3 * CONT_NUM, 13))
Con_raw = [0, 5, 10, 25, 50, 100, 250, 500, 1000]

for m in range(12):
    od = data[m]
    fl = data[m + 12]
    for i in range(CONT_NUM):
        result[1 + i * 3:4 + i * 3, m + 1] = (fl[:, i] - fl[:, LB]) / (od[:, i] - od[:, LB]) - \
                                             (fl[:, BLANK] - fl[:, LB]) / (od[:, BLANK] - od[:, LB])
        result[1 + i * 3:4 + i * 3, 0] = Con_raw[i]
    result[0, m + 1] = ws1.cell_value(1 + m * nxt, 1)

result = result.transpose()

data = pd.DataFrame(result)

## enable this if want to output the form suit for R to process
# time = np.tile(result[1:,0],reps=27)
#
# GFP = np.zeros((27*12,1))
# for i in range(27):
#     GFP[12 * i:12 * (i + 1), 0] = result[1:, i + 1]
# Con = np.repeat(result[0,1:],repeats=12)
#
# out = np.zeros((12*27,3))
# out[:,0] = time
# out[:,1] = Con
# out[:,2] = GFP[:,0]
# data = pd.DataFrame(out)
# writer = pd.ExcelWriter('Flu_HCHO_processed_full_data.xlsx')

writer = pd.ExcelWriter('Flu_HCHO_processed_full_data_tense_form.xlsx')
data.to_excel(writer, 'sheet_1', float_format='%.2f', header=False, index=False)
writer.save()
