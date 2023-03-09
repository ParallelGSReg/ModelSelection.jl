# logit in GLM
using CSV, DataFrames, GLM
cd("C:\\Users\\Demian\\spillsjulia")
data=CSV.read("spills.csv",DataFrame)
@time logit = glm(@formula(spillbin_tot_238 ~ año_log_std + oil_log_std + 
distanciakm_log_std + profundidadmt_log_std + notinproduction + dh_andrew_1992_r34_km + 
dh_carmen_1974_r34_km + dh_elena_1985_r34_km + dh_georges_1998_r34_km + dh_hilda_1964_r34_km + 
dh_ike_2008_r34_km + dh_ivan_2004_r34_km + dh_jeanne_1980_r34_km + dh_lili_2002_r34_km + 
dh_opal_1995_r34_km + dh_rita_2005_r34_km + d_area_AC + d_area_AT + d_area_BA + d_area_BM + 
d_area_BS + d_area_CA + d_area_DC + d_area_EB + d_area_EC + d_area_EI + d_area_EW + 
d_area_GA + d_area_GB + d_area_GC + d_area_GI + d_area_HI + d_area_KC + d_area_LL + 
d_area_MC + d_area_MI + d_area_MO + d_area_MP + d_area_MU + d_area_PE + d_area_PL + 
d_area_PN + d_area_PS + d_area_SA + d_area_SM + d_area_SP + d_area_SS + d_area_ST + 
d_area_SX + d_area_VK + d_area_VR + d_area_WC + d_area_WD + d_area_WR
), data, Bernoulli(), LogitLink());

@time logit2 = glm(@formula(spillbin_tot_238 ~ año_log_std +  oil_log_std +
distanciakm_log_std + profundidadmt_log_std + notinproduction + dh_andrew_1992_r34_km + 
dh_carmen_1974_r34_km + dh_elena_1985_r34_km + dh_georges_1998_r34_km + dh_hilda_1964_r34_km + 
dh_ike_2008_r34_km + dh_ivan_2004_r34_km + dh_jeanne_1980_r34_km + dh_lili_2002_r34_km + 
dh_opal_1995_r34_km + dh_rita_2005_r34_km + d_area_AC + d_area_AT + d_area_BA + d_area_BM + 
d_area_BS + d_area_CA + d_area_DC + d_area_EB + d_area_EC + d_area_EI + d_area_EW + 
d_area_GA + d_area_GB + d_area_GC + d_area_GI + d_area_HI + d_area_KC + d_area_LL + 
d_area_MC + d_area_MI + d_area_MO + d_area_MP + d_area_MU + d_area_PE + d_area_PL + 
d_area_PN + d_area_PS + d_area_SA + d_area_SM + d_area_SP + d_area_SS + d_area_ST + 
d_area_SX + d_area_VK + d_area_VR + d_area_WC + d_area_WD + d_area_WR
), data, Bernoulli(), LogitLink());

@time logit3 = glm(@formula(spillbin_tot_238 ~  oil_log_std + 
distanciakm_log_std + profundidadmt_log_std + notinproduction + dh_andrew_1992_r34_km + 
dh_carmen_1974_r34_km + dh_elena_1985_r34_km + dh_georges_1998_r34_km + dh_hilda_1964_r34_km + 
dh_ike_2008_r34_km + dh_ivan_2004_r34_km + dh_jeanne_1980_r34_km + dh_lili_2002_r34_km + 
dh_opal_1995_r34_km + dh_rita_2005_r34_km + d_area_AC + d_area_AT + d_area_BA + d_area_BM + 
d_area_BS + d_area_CA + d_area_DC + d_area_EB + d_area_EC + d_area_EI + d_area_EW + 
d_area_GA + d_area_GB + d_area_GC + d_area_GI + d_area_HI + d_area_KC + d_area_LL + 
d_area_MC + d_area_MI + d_area_MO + d_area_MP + d_area_MU + d_area_PE + d_area_PL + 
d_area_PN + d_area_PS + d_area_SA + d_area_SM + d_area_SP + d_area_SS + d_area_ST + 
d_area_SX + d_area_VK + d_area_VR + d_area_WC + d_area_WD + d_area_WR
), data, Bernoulli(), LogitLink());

@time logit4 = glm(@formula(spillbin_tot_238 ~  oil_log_std + 
distanciakm_log_std + profundidadmt_log_std  + dh_andrew_1992_r34_km + 
dh_carmen_1974_r34_km + dh_elena_1985_r34_km + dh_georges_1998_r34_km + dh_hilda_1964_r34_km + 
dh_ike_2008_r34_km + dh_ivan_2004_r34_km + dh_jeanne_1980_r34_km + dh_lili_2002_r34_km + 
dh_opal_1995_r34_km + dh_rita_2005_r34_km + d_area_AC + d_area_AT + d_area_BA + d_area_BM + 
d_area_BS + d_area_CA + d_area_DC + d_area_EB + d_area_EC + d_area_EI + d_area_EW + 
d_area_GA + d_area_GB + d_area_GC + d_area_GI + d_area_HI + d_area_KC + d_area_LL + 
d_area_MC + d_area_MI + d_area_MO + d_area_MP + d_area_MU + d_area_PE + d_area_PL + 
d_area_PN + d_area_PS + d_area_SA + d_area_SM + d_area_SP + d_area_SS + d_area_ST + 
d_area_SX + d_area_VK + d_area_VR + d_area_WC + d_area_WD + d_area_WR
), data, Bernoulli(), LogitLink());

@time logit5 = glm(@formula(spillbin_tot_238 ~  oil_log_std + 
distanciakm_log_std   + dh_andrew_1992_r34_km + 
dh_carmen_1974_r34_km + dh_elena_1985_r34_km + dh_georges_1998_r34_km + dh_hilda_1964_r34_km + 
dh_ike_2008_r34_km + dh_ivan_2004_r34_km + dh_jeanne_1980_r34_km + dh_lili_2002_r34_km + 
dh_opal_1995_r34_km + dh_rita_2005_r34_km + d_area_AC + d_area_AT + d_area_BA + d_area_BM + 
d_area_BS + d_area_CA + d_area_DC + d_area_EB + d_area_EC + d_area_EI + d_area_EW + 
d_area_GA + d_area_GB + d_area_GC + d_area_GI + d_area_HI + d_area_KC + d_area_LL + 
d_area_MC + d_area_MI + d_area_MO + d_area_MP + d_area_MU + d_area_PE + d_area_PL + 
d_area_PN + d_area_PS + d_area_SA + d_area_SM + d_area_SP + d_area_SS + d_area_ST + 
d_area_SX + d_area_VK + d_area_VR + d_area_WC + d_area_WD + d_area_WR
), data, Bernoulli(), LogitLink());

@time logit6 = glm(@formula(spillbin_tot_238 ~  oil_log_std + 
dh_andrew_1992_r34_km + 
dh_carmen_1974_r34_km + dh_elena_1985_r34_km + dh_georges_1998_r34_km + dh_hilda_1964_r34_km + 
dh_ike_2008_r34_km + dh_ivan_2004_r34_km + dh_jeanne_1980_r34_km + dh_lili_2002_r34_km + 
dh_opal_1995_r34_km + dh_rita_2005_r34_km + d_area_AC + d_area_AT + d_area_BA + d_area_BM + 
d_area_BS + d_area_CA + d_area_DC + d_area_EB + d_area_EC + d_area_EI + d_area_EW + 
d_area_GA + d_area_GB + d_area_GC + d_area_GI + d_area_HI + d_area_KC + d_area_LL + 
d_area_MC + d_area_MI + d_area_MO + d_area_MP + d_area_MU + d_area_PE + d_area_PL + 
d_area_PN + d_area_PS + d_area_SA + d_area_SM + d_area_SP + d_area_SS + d_area_ST + 
d_area_SX + d_area_VK + d_area_VR + d_area_WC + d_area_WD + d_area_WR
), data, Bernoulli(), LogitLink());



#= @time logit3 = fit(GeneralizedLinearModel, @formula(spillbin_tot_238 ~ año_log_std + oil_log_std + 
distanciakm_log_std + profundidadmt_log_std + notinproduction + dh_andrew_1992_r34_km + 
dh_carmen_1974_r34_km + dh_elena_1985_r34_km + dh_georges_1998_r34_km + dh_hilda_1964_r34_km + 
dh_ike_2008_r34_km + dh_ivan_2004_r34_km + dh_jeanne_1980_r34_km + dh_lili_2002_r34_km + 
dh_opal_1995_r34_km + dh_rita_2005_r34_km + d_area_AC + d_area_AT + d_area_BA + d_area_BM + 
d_area_BS + d_area_CA + d_area_DC + d_area_EB + d_area_EC + d_area_EI + d_area_EW + 
d_area_GA + d_area_GB + d_area_GC + d_area_GI + d_area_HI + d_area_KC + d_area_LL + 
d_area_MC + d_area_MI + d_area_MO + d_area_MP + d_area_MU + d_area_PE + d_area_PL + 
d_area_PN + d_area_PS + d_area_SA + d_area_SM + d_area_SP + d_area_SS + d_area_ST + 
d_area_SX + d_area_VK + d_area_VR + d_area_WC + d_area_WD + d_area_WR), data,
Binomial(), LogitLink()) =#

