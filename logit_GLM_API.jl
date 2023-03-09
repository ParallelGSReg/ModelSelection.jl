julia

cd("C:\\Users\\Demian\\spillsjulia")
using CSV, DataFrames, GLM, StatsBase, CategoricalArrays, SparseArrays, BenchmarkTools
raw=CSV.read("spills2.csv",DataFrame)
data=raw[:, [:spillbin_tot_238 , :año_log_std , :oil_log_std , :distanciakm_log_std ,
:profundidadmt_log_std , :notinproduction_std , :dh_andrew_1992_r34_km_std , :dh_carmen_1974_r34_km_std ,
:dh_elena_1985_r34_km_std , :dh_georges_1998_r34_km_std , :dh_hilda_1964_r34_km_std , :dh_ike_2008_r34_km_std ,
:dh_ivan_2004_r34_km_std , :dh_jeanne_1980_r34_km_std , :dh_lili_2002_r34_km_std , :dh_opal_1995_r34_km_std ,
:dh_rita_2005_r34_km_std , :d_area_AC_std , :d_area_AT_std , :d_area_BA_std , :d_area_BM_std , :d_area_BS_std , :d_area_CA_std ,
:d_area_DC_std , :d_area_EB_std , :d_area_EC_std , :d_area_EI_std , :d_area_EW_std , :d_area_GA_std , :d_area_GB_std ,
:d_area_GC_std , :d_area_GI_std , :d_area_HI_std , :d_area_KC_std , :d_area_LL_std , :d_area_MC_std , :d_area_MI_std , 
:d_area_MO_std , :d_area_MP_std , :d_area_MU_std , :d_area_PE_std , :d_area_PL_std , :d_area_PN_std , :d_area_PS_std , 
:d_area_SA_std , :d_area_SM_std, :d_area_SP_std , :d_area_SS_std , :d_area_ST_std , :d_area_SX_std , :d_area_VK_std , 
:d_area_VR_std , :d_area_WC_std , :d_area_WD_std , :d_area_WR_std]]

data_nofe=raw[:, [:spillbin_tot_238 , :año_log_std , :oil_log_std , :distanciakm_log_std ,
:profundidadmt_log_std , :notinproduction_std , :dh_andrew_1992_r34_km , :dh_carmen_1974_r34_km ,
:dh_elena_1985_r34_km , :dh_georges_1998_r34_km , :dh_hilda_1964_r34_km , :dh_ike_2008_r34_km ,
:dh_ivan_2004_r34_km , :dh_jeanne_1980_r34_km , :dh_lili_2002_r34_km , :dh_opal_1995_r34_km ,
:dh_rita_2005_r34_km]]

data_nomiss=data[completecases(data), :]
data_nofe_nomiss=data_nofe[completecases(data_nofe), :]

y = Array{Float64}(data_nomiss[:, 1])
y_f32 = Array{Float32}(data_nomiss[:, 1])
y_sp = sparse(y)
y_f32_sp = sparse(y_f32)

x = Array{Float64}(data_nomiss[: , 2 : end])
x_f32 = Array{Float32}(data_nomiss[: , 2 : end])
x_nofe = Array{Float64}(data_nofe_nomiss[: , 2 : end])
x_nofe_f32 = Array{Float32}(data_nofe_nomiss[: , 2 : end])
x_sp = sparse(x)
x_f32_sp = sparse(x_f32)
x_nofe_sp = sparse(x_nofe)
x_nofe_f32_sp = sparse(x_nofe_f32)

Base.summarysize(data)
Base.summarysize(data_nofe)
Base.summarysize(y)
Base.summarysize(y_f32)
Base.summarysize(y_sp)
Base.summarysize(y_f32_sp)

Base.summarysize(x)
Base.summarysize(x_f32)
Base.summarysize(x_nofe)
Base.summarysize(x_nofe_f32)
Base.summarysize(x_sp)
Base.summarysize(x_f32_sp)
Base.summarysize(x_nofe_sp)
Base.summarysize(x_nofe_f32_sp)

#BASE COMPLETA - SIN API + DATAFRAME
@time orig1 = glm(@formula(spillbin_tot_238 ~ año_log_std + oil_log_std + distanciakm_log_std +
profundidadmt_log_std + notinproduction_std + dh_andrew_1992_r34_km_std + dh_carmen_1974_r34_km_std +
dh_elena_1985_r34_km_std + dh_georges_1998_r34_km_std + dh_hilda_1964_r34_km_std + dh_ike_2008_r34_km_std +
dh_ivan_2004_r34_km_std + dh_jeanne_1980_r34_km_std + dh_lili_2002_r34_km_std + dh_opal_1995_r34_km_std +
dh_rita_2005_r34_km_std + d_area_AC_std + d_area_AT_std + d_area_BA_std + d_area_BM_std + d_area_BS_std + d_area_CA_std +
d_area_DC_std + d_area_EB_std + d_area_EC_std + d_area_EI_std + d_area_EW_std + d_area_GA_std + d_area_GB_std +
d_area_GC_std + d_area_GI_std + d_area_HI_std + d_area_KC_std + d_area_LL_std + d_area_MC_std + d_area_MI_std + 
d_area_MO_std + d_area_MP_std + d_area_MU_std + d_area_PE_std + d_area_PL_std + d_area_PN_std + d_area_PS_std + 
d_area_SA_std + d_area_SM_std+ d_area_SP_std + d_area_SS_std + d_area_ST_std + d_area_SX_std + d_area_VK_std + 
d_area_VR_std + d_area_WC_std + d_area_WD_std + d_area_WR_std), data_nomiss, Bernoulli(), LogitLink()); coef0=coeftable(orig1).cols[1]; z0=coeftable(orig1).cols[3]; aic0=aic(orig1); ll0=loglikelihood(orig1); k0=size(orig1.model.pp.X,2)-1;n=size(data_nomiss,1);

function sinapi()
    origin2=nothing
    return orig2 = glm(@formula(spillbin_tot_238 ~  distanciakm_log_std +
    profundidadmt_log_std + notinproduction_std + dh_andrew_1992_r34_km_std + dh_carmen_1974_r34_km_std +
    dh_elena_1985_r34_km_std + dh_georges_1998_r34_km_std + dh_hilda_1964_r34_km_std + dh_ike_2008_r34_km_std +
    dh_ivan_2004_r34_km_std + dh_jeanne_1980_r34_km_std + dh_lili_2002_r34_km_std + dh_opal_1995_r34_km_std +
    dh_rita_2005_r34_km_std + d_area_AC_std + d_area_AT_std + d_area_BA_std + d_area_BM_std + d_area_BS_std + d_area_CA_std +
    d_area_DC_std + d_area_EB_std + d_area_EC_std + d_area_EI_std + d_area_EW_std + d_area_GA_std + d_area_GB_std +
    d_area_GC_std + d_area_GI_std + d_area_HI_std + d_area_KC_std + d_area_LL_std + d_area_MC_std + d_area_MI_std + 
    d_area_MO_std + d_area_MP_std + d_area_MU_std + d_area_PE_std + d_area_PL_std + d_area_PN_std + d_area_PS_std + 
    d_area_SA_std + d_area_SM_std+ d_area_SP_std + d_area_SS_std + d_area_ST_std + d_area_SX_std + d_area_VK_std + 
    d_area_VR_std + d_area_WC_std + d_area_WD_std + d_area_WR_std), data_nomiss, Bernoulli(), LogitLink(), start=coef0[3:end]); coef1=coeftable(orig2).cols[1]; z1=coeftable(orig2).cols[3]; aic1=aic(orig2); ll1=loglikelihood(orig2); k1=size(orig2.model.pp.X,2)-1;n=size(data_nomiss,1);
end;
orig3 = @benchmark sinapi() samples=100 evals=1


#BASE COMPLETA + FLOAT64
@time a1=fit(GeneralizedLinearModel, x, y,Binomial(),LogitLink(), start=zeros(size(x,2))); coef0=coeftable(a1).cols[1]; z0=coeftable(a1).cols[3]; aic0=aic(a1); ll0=loglikelihood(a1); k0=size(x,2); n=size(y,1);
function full_f64()
    a2=nothing
    return a2=fit(GeneralizedLinearModel, @view(x[: , 3 : end]), y,Binomial(),LogitLink(), start=coef0[3:end]); coef1=coeftable(a2).cols[1]; z1=coeftable(a2).cols[3]; aic1=aic(a2); ll1=loglikelihood(a2); k1=size(x[: , 3 : end],2); n1=size(y,1);
end;
a3 = @benchmark full_f64() samples=100 evals=1


#BASE SIN EFECTOS FIJOS + FLOAT64
@time b1=fit(GeneralizedLinearModel, x_nofe, y,Binomial(),LogitLink(), start=zeros(size(x_nofe,2))); coef0=coeftable(b1).cols[1]; z0=coeftable(a1).cols[3]; aic0=aic(a1); ll0=loglikelihood(a1); k0=size(x_nofe,2); n=size(y,1);
function nofe_f64()
    b2=nothing
    return b2=fit(GeneralizedLinearModel, x_nofe[: , 3 : end], y,Binomial(),LogitLink(), start=coef0[3:end]); coef1=coeftable(b2).cols[1]; z1=coeftable(b2).cols[3]; aic1=aic(b2); ll1=loglikelihood(b2); k1=size(x_nofe[: , 3 : end],2); n1=size(y,1);
end;
b3 = @benchmark nofe_f64() samples=100 evals=1


#BASE COMPLETA + FLOAT32
@time c1=fit(GeneralizedLinearModel, x_f32, y_f32,Binomial(),LogitLink(), start=zeros(size(x_f32,2))); coef0=coeftable(c1).cols[1]; z0=coeftable(c1).cols[3]; aic0=aic(c1); ll0=loglikelihood(c1); k0=size(x_f32,2); n0=size(y_f32,1);
function full_f32()
    c2=nothing
    return c2=fit(GeneralizedLinearModel, x_f32[: , 3 : end], y_f32,Binomial(),LogitLink(), start=coef0[3:end]); coef1=coeftable(c2).cols[1]; z1=coeftable(c2).cols[3]; aic1=aic(c2); ll1=loglikelihood(c2); k1=size(x_f32[: , 3 : end],2); n1=size(y_f32,1);
end;
c3 = @benchmark full_f32() samples=100 evals=1


#BASE SIN EFECTOS FIJOS + FLOAT32
@time d1=fit(GeneralizedLinearModel, x_nofe_f32, y_f32,Binomial(),LogitLink(), start=zeros(size(x_nofe_f32,2))); coef0=coeftable(d1).cols[1]; z0=coeftable(d1).cols[3]; aic0=aic(d1); ll0=loglikelihood(d1); k0=size(x_nofe_f32,2); n0=size(y_f32,1);
function nofe_f32()
    d2=nothing
    return d2=fit(GeneralizedLinearModel, @view(x_nofe_f32[: , 3 : end]), y_f32,Binomial(),LogitLink(), start=coef0[3:end]); coef1=coeftable(d2).cols[1]; z1=coeftable(d2).cols[3]; aic1=aic(d2); ll1=loglikelihood(d2); k1=size(x_nofe_f32[: , 3 : end],2); n1=size(y_f32,1);
end;
d3 = @benchmark nofe_f32() samples=1000 evals=1

#######################
#BASE COMPLETA + FLOAT64 + SPARSE ---- DA ERROR
@time e1=fit(GeneralizedLinearModel, x_sp, y_sp, Binomial(),LogitLink(), start=zeros(size(x_sp,2))); coef0=coeftable(e1).cols[1]; z0=coeftable(e1).cols[3]; aic0=aic(e1); ll0=loglikelihood(e1); k0=size(x_sp,2); n=size(y_sp,1);
function full_f64_sp()
    return e2=fit(GeneralizedLinearModel, x_sp[: , 3 : end], y_sp,Binomial(),LogitLink(), start=coef0[3:end]); coef1=coeftable(e2).cols[1]; z1=coeftable(e2).cols[3]; aic1=aic(e2); ll1=loglikelihood(e2); k1=size(x_sp[: , 3 : end],2); n1=size(y_sp,1);
end;
e3 = @benchmark full_f64_sp() samples=1000 evals=1


#BASE SIN EFECTOS FIJOS + FLOAT64 + SPARSE --- DA ERROR
@time f1=fit(GeneralizedLinearModel, x_f32_sp, y_f32_sp, Binomial(),LogitLink(), start=zeros(size(x_f32_sp,2))); coef0=coeftable(f1).cols[1]; z0=coeftable(f1).cols[3]; aic0=aic(f1); ll0=loglikelihood(f1); k0=size(x_f32_sp,2); n=size(y_f32_sp,1);
function noef_f32_sp()
    return f2=fit(GeneralizedLinearModel, x_f32_sp[: , 3 : end], y_f32_sp,Binomial(),LogitLink(), start=coef0[3:end]); coef1=coeftable(f2).cols[1]; z1=coeftable(f2).cols[3]; aic1=aic(f2); ll1=loglikelihood(f2); k1=size(x_f32_sp[: , 3 : end],2); n1=size(y_f32_sp,1);
end;
f3 = @benchmark noef_f32_sp() samples=100 evals=1


#BASE COMPLETA + FLOAT32 + SPARSE --- DA ERROR
@time f1=fit(GeneralizedLinearModel, x_f32_sp, y_f32_sp, Binomial(),LogitLink(), start=zeros(size(x_f32_sp,2))); coef0=coeftable(f1).cols[1]; z0=coeftable(f1).cols[3]; aic0=aic(f1); ll0=loglikelihood(f1); k0=size(x_f32_sp,2); n=size(y_f32_sp,1);
function noef_f32_sp()
    return f2=fit(GeneralizedLinearModel, x_f32_sp[: , 3 : end], y_f32_sp,Binomial(),LogitLink(), start=coef0[3:end]); coef1=coeftable(f2).cols[1]; z1=coeftable(f2).cols[3]; aic1=aic(f2); ll1=loglikelihood(f2); k1=size(x_f32_sp[: , 3 : end],2); n1=size(y_f32_sp,1);
end;
f3 = @benchmark noef_f32_sp() samples=100 evals=1


#BASE SIN EFECTOS FIJOS + FLOAT32 + SPARSE
@time h1=fit(GeneralizedLinearModel, x_nofe_f32_sp, y_f32_sp,Binomial(),LogitLink(), start=zeros(size(x_nofe_f32_sp,2))); coef0=coeftable(h1).cols[1]; z0=coeftable(h1).cols[3]; aic0=aic(h1); ll0=loglikelihood(h1); k0=size(x_nofe_f32_sp,2); n0=size(y_f32_sp,1);
function nofe_f32_sp()
    return h2=fit(GeneralizedLinearModel, x_nofe_f32_sp[: , 3 : end], y_f32_sp,Binomial(),LogitLink(), start=coef0[3:end]); coef1=coeftable(h2).cols[1]; z1=coeftable(h2).cols[3]; aic1=aic(h2); ll1=loglikelihood(h2); k1=size(x_nofe_f32_sp[: , 3 : end],2); n1=size(y_f32_sp,1);
end;
h3 = @benchmark nofe_f32_sp() samples=100 evals=1

