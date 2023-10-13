
library(deSolve)

model <- function (t, x, params) {
  ##  Variant
  # reaction 1
  mRNA_FrmR <- x[1]
  FrmR <- x[2]
  # reaction 2
  PfrmR <- x[3]
  HCHO <- x[4]
  FrmR_HCHO <- x[5]
  FrmR_PfrmR <- x[6]
  
  
  # Parameters
  K_DegM <- params["K_DegM"]
  K_DegP <- params["K_DegP"]
  # reaction 1
  K_TC1 <- params["K_TC1"]
  DNA_FrmR <- 200
  K_TL1 <- params["K_TL1"]
  # reaction 2
  K_Asso_FP <-  params["K_Asso_FP"]
  K_Asso_FH <-  params["K_Asso_FH"]
  K_Sepe_FP <- params["K_Sepe_FP"]
  K_Sepe_FH <- params["K_Sepe_FH"]
  # reaction 3
  DNA_CI <- 20
  K_hill1 <- 400 # TrpR2-T抑制效果
  n1 <- 2
  K_TC2 <- params["K_TC2"]
  K_TL2 <- params["K_TL2"]
  K_Di2 <- params["K_Di2"]
  # reaction 4
  DNA_GFP <- 20
  K_hill2 <- 10
  n2 <- 2
  K_TC4 <- params["K_TC4"]
  K_TL4 <- params["K_TL4"]
  # reaction 5
  DNA_Taq <-  120
  K_hill3 <- 1.4
  n3 <- 1
  K_TC3 <- params["K_TC3"]
  K_TL3 <- params["K_TL3"]
  
  ## Equations
  # reaction 1
  dmRNA_FrmRdt <- K_TC1 * DNA_FrmR-K_DegM * mRNA_FrmR
  dFrmRdt <- K_TL1 * mRNA_FrmR - K_DegP * FrmR
  # reaction 2
  dFrmRdt <- K_Asso_FP * FrmR * PfrmR - K_Asso_FP * FrmR * HCHO + 
    K_Sepe_FH * FrmR_HCHO - K_Sepe_FP * FrmR_PfrmR
  dPfrmRdt <- -K_Asso_FP * FrmR * PfrmR + K_Sepe_FP * FrmR_PfrmR
  dFrmR_PfrmRdt <- K_Asso_FP * FrmR * PfrmR - K_Sepe_FP * FrmR_PfrmR
  dFrmR_HCHOdt <- K_Asso_FH * FrmR * HCHO - K_Sepe_FH * FrmR_HCHO
  # reaction 3
  dmRNA_CIdt <-
    K_TC2 * DNA_CI / (1 + (TrpR2_T / K_hill1) ^ n1) - K_DegM * mRNA_CI
  dCIdt <- K_TL2 * mRNA_CI - K_DegP * CI - 2 * K_Di2 * CI ^ 2
  dCI2dt <-
    K_Di2 * CI ^ 2 - K_DegP * CI2 # 没有抑制情况下为2，一半抑制情况下为1，抑制0.05
  # reaction 4
  dmRNA_GFPdt <-
    K_TC4 * DNA_GFP / (1 + ((CI2) / K_hill2) ^ n2) - K_DegM * mRNA_GFP
  dGFPt <- K_TL4 * mRNA_GFP - K_DegP * GFP
  
  # reaction 5
  dmRNA_Taqdt <-
    K_TC3 * DNA_Taq / (1 + (TrpR2_T / K_hill3) ^ n3) - K_DegM * mRNA_Taq
  dTaqdt <- K_TL3 * mRNA_Taq - K_DegP * Taq
  
  
  dxdt <-
    c(
      dmRNA_TrpRdt,
      dTrpRdt,
      dTrpR2dt,
      dTrpR2_Tdt,
      dmRNA_CIdt,
      dCIdt,
      dCI2dt,
      dmRNA_GFPdt,
      dGFPt,
      dmRNA_Taqdt,
      dTaqdt
    )
  list(dxdt)
}


## importing parameters

params <- c(
  K_DegM = 5.1986,
  K_DegP = 0.33862,
  K_TC1 = 0.358,
  K_TL1 = 7.28,
  K_Di1 = 0.03,
  # reaction 1
  K_Asso_T = 0.2,
  K_Sepe = 0.7,
  # reaction 2
  K_TC2 = 0.1557,
  K_TL2 = 3.34,
  K_Di2 = 0.05,
  # reaction 3
  K_TC4 = 0.1555,
  K_TL4 = 3.32, # reaction 4
  # reaction 5
  K_TC3 = 0.04,
  K_TL3 = 0.95
)


## Solving ODE

xstart <-
  c(
    mRNA_TrpR = 0,
    TrpR = 0,
    TrpR2 = 0,
    TrpR2_T = 0,
    mRNA_CI = 0,
    CI = 0,
    CI2 = 0,
    mRNA_GFP = 0,
    GFP = 0,
    mRNA_Taq = 0,
    Taq = 0
  )

times <- seq(from = 0, to = 72, by = 0.5)
out <- ode(
  func = model,
  y = xstart,
  times = times,
  parms = params
)
out.df <- as.data.frame(out)