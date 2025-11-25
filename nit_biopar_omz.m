 function nit = nit_biopar_omz(nit,varargin)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization of biologial parameters
% Versions: 0.1 : D. Bianchi, August 2020
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Model variables
 bgc.varnames = {'doc','o2','po4','no3','no2','nh4','n2o','n2'};
 bgc.nvar = length(bgc.varnames);

% Model diagnostics  (all in mol N units)
 bgc.diagnames = {'NRemOx', 'NRemAnox', 'Ammox','Nitrox', ...
                  'RemDen1','RemDen2','RemDen3', ...
                  'Jnn2o_Ax','Jno2_Ax','Anammox'};
 bgc.ndiag = length(bgc.diagnames);

 % Initialize biogeochemical variables (initial and boundary conditions)
 bgc = nit_initialize_omz(bgc,nit.ExpModule);

 % Organic matter form: C_aH_bO_cN_dP
 % Stoichiometric ratios: C:H:O:N:P = a:b:c:d:1
 % Anderson and Sarmiento 1994 stochiometry
 bgc.stoch_a = 106.0;
 bgc.stoch_b = 175.0;
 bgc.stoch_c = 42.0;
 bgc.stoch_d = 16.0;
 % Gets full stoichiometry
 bgc = get_stoichiometry(bgc,bgc.stoch_a,bgc.stoch_b,bgc.stoch_c,bgc.stoch_d);

 %%%%%%%% Ammonification %%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 bgc.krem 	= 0.08;			% 0.08    % Max. remineralization rate (1/s)
 bgc.KO2Rem  	= 0.5;			% 4       % Half sat. constant for respiration  (mmolO2/m3) - Martens-Habbena 2009

 %%%%%% Ammonium oxidationn %%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Ammox: NH4 --> NO2
 bgc.kAo 	= 0.04556;		% 0.045    Max. Ammonium oxidation rate (1/s) - Bristow 2017
 bgc.KNH4Ao  	= 0.0272;		% 0.1       % Half sat. constant for nh4 (mmolN/m3) - Peng 2016
 bgc.KO2Ao 	= 0.333;		% 0.333+-0.130  % Half sat. constant for Ammonium oxidation (mmolO2/m3) - Bristow 2017

 %%%%%%%% Nitrite oxidationn %%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Nitrox: NO2 --> NO3
 bgc.kNo 	= 0.255;		% 0.256    Max. Nitrite oxidation rate (1/s) - Bristow 2017
 bgc.KNO2No  	= 0.0272;		% Don't know (mmolN/m3)
 bgc.KO2No 	= 0.778;		% Half sat. constant of NO2 for Nitrite oxidation (mmolO2/m3) - Bristow 2017

 %%%%%%% Denitrification %%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Denitrif1: NO3 --> NO2
 bgc.kDen1 	= 0.08/2;		% Max. denitrif1 rate (1/s)
 bgc.KO2Den1 	= 1.0;			% O2 poisoning constant for denitrif1 (mmolO2/m3)
 bgc.KNO3Den1 	= 0.5;			% Half sat. constant of NO3 for denitrif1 (mmolNO3/m3)
    
 % Denitrif2: NO2 --> N2O
 bgc.kDen2 	= 0.08/6;		% Max. denitrif2 rate (1/s)
 bgc.KO2Den2 	= 0.3;			% O2 poisoning constant for denitrif2 (mmolO2/m3)
 bgc.KNO2Den2 	= 0.5;			% Half sat. constant of NO2 for denitrification2 (mmolNO3/m3)

 % Denitrif3: N2O --> N2
 bgc.kDen3 	= 0.08/3;		% Max. denitrif3 rate (1/s)
 bgc.KO2Den3 	= 0.0292;		% O2 poisoning constant for denitrif3 (mmolO2/m3)
 bgc.KN2ODen3 	= 0.02;			% Half sat. constant of N2O for denitrification3 (mmolNO3/m3)

 %%%%%%%%%%% Anammox %%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 bgc.kAx 	= 0.02;			% Max. Anaerobic Ammonium oxidation rate (1/s) - Bristow 2017
 bgc.KNH4Ax  	= 0.0274;		% Half sat. constant of NH4 for anammox (mmolNH4/m3)
 bgc.KNO2Ax  	= 0.5;			% Half sat. constant of NO2 for anammox (mmolNO2/m3)
 bgc.KO2Ax 	= 0.886;		% 1.0     %

 %%%%%% N2O prod via ammox %%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Parameters for calculation of N2O yields during Ammox and
 % nitrifier-denitrification (see n2o_yield.m).

 % Choose paramterization:
 % 'Ji': Ji et al 2018
 bgc.n2o_yield = 'Ji';

 if strcmp(bgc.n2o_yield, 'Ji')
    % Ji et al 2018
    bgc.Ji_a 	= 0.2;
    bgc.Ji_b  	= 0.08;
 end


 %--------------------------------------------------------------------------------
 % Here performs any substitution of default parameters based on user input (varargin)
 BioPar = parse_pv_pairs(bgc,varargin);
 %--------------------------------------------------------------------------------

 % Adds in the biological parameters in the main structure
 nit.BioPar = BioPar;

 %--------------------------------------------------------------------
 % Cut-outs
%bgc.diagnames = {'NRemOx', 'NRemDen1', 'NRemDen2', 'NRemDen3', ...
%                 'Ammox','Nitrox','RemDen1','RemDen2','RemDen3', ...
%                 'Jnn2o_hx','Jnn2o_nden','Jno2_hx','Jno2_nden','Anammox'};
