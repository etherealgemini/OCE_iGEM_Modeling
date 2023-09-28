import numpy as np
import matplotlib.pyplot as plt


def model(y, t, k):
    # Unpack state variables
    [FrmR, PfrmR, FrmR_PfrmR, FrmR_HCHO, mRNAR, R,
     NAD_plus, HCHO_air, HCHO_in_vivo, HMGS,
     S_formylglutathione, mid2, mid3, CO2_in_vivo, CO2_air, GSH, fghA, f_dh, adh,nadh] = y

    # dFrmR_dt, dPfrmR_dt, dFrmR_PfrmR_dt, dFrmR_HCHO_dt, dmRNAR_dt, dR_dt,
    # dNAD_plus_dt, dHCHO_in_vivo_dt, dHMGS_dt, dNADH_dt, dS_formylglutathione_dt,
    #             dmid2_dt, dmid3_dt, dCO2_in_vivo_dt, dCO2_air_dt, dGSH_dt,dnadh_dt
    dFrmR_dt = (
            k["kAsso_FP"] * FrmR * PfrmR
            - k["kAsso_FH"] * FrmR * HCHO_in_vivo
            + k["kSepe_FH"] * (FrmR_HCHO - FrmR)
            - k["kSepe_FP"] * FrmR_PfrmR
    )

    dPfrmR_dt = (
            -k["kAsso_FP"] * FrmR * PfrmR
            + k["kSepe_FP"] * FrmR_PfrmR
    )

    dFrmR_PfrmR_dt = (
            k["kAsso_FP"] * FrmR * PfrmR
            - k["kSepe_FP"] * FrmR_PfrmR
    )

    dFrmR_HCHO_dt = (
            k["kAsso_FH"] * FrmR * HCHO_in_vivo
            - k["kSepe_FH"] * (FrmR_HCHO - FrmR)
    )

    dmRNAR_dt = k["kTC2"] * PfrmR - k["kDegM"] * mRNAR

    dR_dt = k["kTL2"] * PfrmR - k["kDegP"] * R

    # Compute rate equations
    dNAD_plus_dt = (
            -k["k2"] * HMGS * NAD_plus * adh
            + k["k2"] * HMGS * NAD_plus * adh
    )

    dHCHO_in_vivo_dt = (
            k["k0"] * HCHO_air
            - k["k1"] * HCHO_in_vivo * GSH
    )

    dHMGS_dt = (
            k["k1"] * HCHO_in_vivo * GSH
            - k["k2"] * HMGS * NAD_plus * adh
    )

    dS_formylglutathione_dt = (
            k["k2"] * HMGS * NAD_plus * adh
            - k["k3"] * S_formylglutathione * fghA
    )

    dmid2_dt = (
            k["k3"] * S_formylglutathione * fghA
            - k["k4"] * mid2 * f_dh
    )

    dmid3_dt = (
            k["k4"] * mid2 * f_dh
            - k["k5"] * mid3
    )

    dCO2_in_vivo_dt = (
            k["k5"] * mid3
            - k["k6"] * CO2_in_vivo
    )

    dCO2_air_dt = k["k6"] * CO2_in_vivo

    dGSH_dt = (
            -k["k1"] * HCHO_in_vivo * GSH
            + k["k2"] * HMGS * NAD_plus * adh
    )

    dHCHO_air_dt = (
            -k["k0"] * HCHO_air
    )
    dNADH_dt = k["k2"] * HMGS * NAD_plus * adh - k["k2"] * HMGS * NAD_plus * adh
    dfghA_dt = -k["k3"] * S_formylglutathione * fghA + k["k3"] * S_formylglutathione * fghA
    df_dh_dt = -k["k4"] * mid2 * f_dh + k["k4"] * mid2 * f_dh
    dadh_dt = -k["k2"] * HMGS * NAD_plus * adh + k["k2"] * HMGS * NAD_plus * adh

    # [FrmR, PfrmR, FrmR_PfrmR, FrmR_HCHO, mRNAR, R,
    #      NAD_plus,HCHO_air ,HCHO_in_vivo, HMGS,
    #      S_formylglutathione, mid2, mid3, CO2_in_vivo, CO2_air, GSH, fghA, f_dh, adh, nadh] = y
    dydt = [dFrmR_dt, dPfrmR_dt, dFrmR_PfrmR_dt, dFrmR_HCHO_dt, dmRNAR_dt, dR_dt,
            dNAD_plus_dt, dHCHO_air_dt, dHCHO_in_vivo_dt, dHMGS_dt, dS_formylglutathione_dt,
            dmid2_dt, dmid3_dt, dCO2_in_vivo_dt, dCO2_air_dt, dGSH_dt, dfghA_dt, df_dh_dt, dadh_dt, dNADH_dt]

    return dydt


# Initial conditions
mets = ["FrmR", "PfrmR", "FrmR_PfrmR", "FrmR_HCHO", "mRNAR", "R",
      "NAD_plus", "HCHO_air", "HCHO_in_vivo", "HMGS",
      "S_formylglutathione", "mid2", "mid3", "CO2_in_vivo", "CO2_air", "GSH", "fghA", "f_dh", "adh","NADH"]

y0 = [FrmR, PfrmR, FrmR_PfrmR, FrmR_HCHO, mRNAR, R,
      NAD_plus, HCHO_air, HCHO_in_vivo, HMGS,
      S_formylglutathione, mid2, mid3, CO2_in_vivo, CO2_air, GSH, fghA, f_dh, adh,nadh] = np.repeat(0.1, 20)
# Time points
start_time = 0
end_time = 2
num_points = 1000
t = np.linspace(start_time, end_time, num_points)

# Parameters
k = {
    "kAsso_FP": 1000,
    "kAsso_FH": 1000,
    "kSepe_FP": 0.05,
    "kSepe_FH": 0.01,
    "kTC2": 1000,
    "kDegM": 10,
    "kTL2": 1000,
    "kDegP": 10,
    "k0": 100,
    "k1": 1000,
    "k2": 1,
    "k3": 1,
    "k4": 1,
    "k5": 1,
    "k6": 1,
}

# Solve the ODEs
from scipy.integrate import odeint

sol = odeint(model, y0, t, args=(k,))

plt.figure(figsize=(10, 10))

for i in range(0,len(sol[1])):
    plt.plot(t, sol[:, i],label=mets[i])
# plt.imshow(sol,cmap=cmap)
plt.legend(loc='best')
plt.xlabel('t')
plt.grid()
plt.show()
