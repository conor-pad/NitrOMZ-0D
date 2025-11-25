function [SMS, DIAGS] = nit_sms_omz(nit,Var,EnvVar)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SMS calculations
% Versions: 0.1 : D. Bianchi, 4 Sept 2020
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% BE CAREFUL ABOUT N VS C UNITS. WHEN DOING SMS FOR AN N-BASED TRACER, WE NEED TO OBVIOSULY USE N UNITS


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------------------------------------
% Variables:
% BioPar.varnames = {'o2','no3','doc','po4','n2o','nh4','no2','n2'};
%------------------------------------------------
% Preliminary processing
nvar = nit.BioPar.nvar;        % number of model state variables
% Create a structure with current state variables, for simplicity
for indv=1:nvar
    %var.(nit.BioPar.varnames{indv}) = Var(indv);
    % If a variable is negative, it will be set to zero (or to a very small number)
    %var.(nit.BioPar.varnames{indv}) = max(1e-6,Var(indv));
    var.(nit.BioPar.varnames{indv}) = max(0,Var(indv));
end

nevar = nit.SetUp.nevar;        % number of environemntal forcing variables
% Create a structure with current environmental variables, for simplicity
for indv=1:nevar
    evar.(nit.SetUp.evarnames{indv}) = EnvVar(indv);
end

% Structure with the bioparameters, for simplicity
bio = nit.BioPar;
%------------------------------------------------

% % % % % % % % % % % %
% % % % J-OXIC  % % % %
% % % % % % % % % % % %
%----------------------------------------------------------------------
% (1) Oxic Respiration rate (C-units):
%----------------------------------------------------------------------
RemOx = bio.krem .* mm1(var.o2,bio.KO2Rem) .* var.doc;
% bio.krem = max DOC remineralization rate (C-units, per time)
% mm1(var.o2, bio.KO2Rem)—— (saturating; ~0 in anoxic water, ~1 at high O₂)
% var.doc = substrate concentration

%----------------------------------------------------------------------
% (2) Ammonium oxidation (molN-units):
%----------------------------------------------------------------------

% rate of NH₄ oxidation in mol N per time per volume
Ammox = bio.kAo .*  mm1(var.o2,bio.KO2Ao) .*  mm1(var.nh4,bio.KNH4Ao) ;

% KO2Ao > KNH4Ao. Contribution to rate of oxygen is smaller than NH4, which
% makes sense

%----------------------------------------------------------------------
% (3) Nitrite oxidation (molN-units):
%----------------------------------------------------------------------

Nitrox = bio.kNo .*  mm1(var.o2,bio.KO2No) .* mm1(var.no2,bio.KNO2No);

% Process: NO₂⁻ → NO₃⁻
% bio.kNo: max NO₂ oxidation rate
% mm1(var.o2,bio.KO2No): O₂ limitation
% mm1(var.no2,bio.KNO2No): NO₂ limitation


% KO2No > KNO2No by about 0.6. So compared with (2), oxygen is even less important

%----------------------------------------------------------------------
% (4) N2O and NO2 production by ammox and nitrifier-denitrif (molN-units):
%----------------------------------------------------------------------
% Note: here yileds are split for potential use in isotopes (and perhaps
% better parameterization of nitrifier-denitrification);
Y = n2o_yield(var.o2, bio);
% via NH2OH
Jnn2o_hx  = Ammox .* Y.nn2o_hx_nh4;
Jno2_hx   = Ammox .* Y.no2_hx_nh4;
% via NH4->NO2->N2O
Jnn2o_nden = Ammox .* Y.nn2o_nden_nh4;
Jno2_nden  = Ammox .* Y.no2_nden_nh4;

% for a given unit of Ammox (NH₄ oxidation), Y tells what fraction of that N flux becomes N₂O or NO₂ via different pathways.

% nn2o → nitrification-related N₂O
% no2 → NO₂ production
% hx → "hydroxylamine" (NH₂OH) pathway
% nden → "nitrifier denitrification" pathway
% _nh4 → per unit of NH₄ oxidized

% Jnn2o_hx = Ammox * Y.nn2o_hx_nh4
%     Units: mol N per time per volume
%     Meaning: N₂O production flux via the hydroxylamine (NH₂OH) pathway during nitrification
% Jno2_hx = Ammox * Y.no2_hx_nh4
%     Meaning: NO₂ production flux associated with same NH₂OH pathway
% 
% Jnn2o_nden = Ammox * Y.nn2o_nden_nh4
%     Meaning: N₂O production flux via nitrifier denitrification (NO₂ → N₂O in low O₂ conditions by nitrifiers)
% Jno2_nden = Ammox * Y.no2_nden_nh4
%     Meaning: NO₂ production flux associated with nitrifier denitrification



% % % % % % % % % % % %
% % %   J-ANOXIC  % % %
% % % % % % % % % % % %

%----------------------------------------------------------------------
% (5) Denitrification (C-units)
%----------------------------------------------------------------------
RemDen1 = bio.kDen1 .* mm1(var.no3,bio.KNO3Den1) .* fexp(var.o2,bio.KO2Den1) .* var.doc;
RemDen2 = bio.kDen2 .* mm1(var.no2,bio.KNO2Den2) .* fexp(var.o2,bio.KO2Den2) .* var.doc;
RemDen3 = bio.kDen3 .* mm1(var.n2o,bio.KN2ODen3) .* fexp(var.o2,bio.KO2Den3) .* var.doc;

% RemDen1: DOC oxidation coupled to NO₃⁻ → NO₂⁻
%     Limited by NO₃ (mm1(var.no3, KNO3Den1))
%     Inhibited by O₂ via fexp(var.o2, KO2Den1) (fexp is usually an exponential suppression, ~exp(−O2/KO2))
%     Proportional to DOC
% RemDen2: DOC oxidation coupled to NO₂⁻ → N₂O
% RemDen3: DOC oxidation coupled to N₂O → N₂


%----------------------------------------------------------------------
% (6) Anaerobic ammonium oxidation (molN-units):
%----------------------------------------------------------------------
Anammox = bio.kAx .* mm1(var.nh4,bio.KNH4Ax) .* mm1(var.no2,bio.KNO2Ax) .* fexp(var.o2,bio.KO2Ax);

% Process: NH₄⁺ + NO₂⁻ → N₂ + other products (e.g. NO₃⁻ in real stoichiometry)
% bio.kAx: max anammox rate
% mm1(var.nh4, KNH4Ax): NH₄ limitation
% mm1(var.no2, KNO2Ax): NO₂ limitation
% fexp(var.o2, KO2Ax): inhibition by O₂ (anammox is strictly anoxic)


%kRemOx = RemOx./var.doc;
%kRemDen1 = RemDen1./var.doc;
%kRemDen2 = RemDen2./var.doc;
%kRemDen3 = RemDen3./var.doc;

%----------------------------------------------------------------------
% (8)  Calculate SMS for each tracer
%----------------------------------------------------------------------
ddt.o2   =  (-bio.OCrem .* RemOx - 1.5.*Ammox - 0.5 .* Nitrox);
% O₂ sinks:
%     - bio.OCrem .* RemOx: O₂ consumption associated with carbon remineralization.
%     bio.OCrem = O:C stoichiometric coefficient (mol O₂ consumed per mol C remin).
%     - 1.5 * Ammox: O₂ cost of oxidizing NH₄ → NO₂ (standard stoich uses ~1.5 O₂ per NH₄).
%     - 0.5 * Nitrox: O₂ cost of oxidizing NO₂ → NO₃ (~0.5 O₂ per NO₂).


ddt.no3  =  (Nitrox - bio.NCden1 .* RemDen1);
ddt.doc  =  - RemOx - RemDen1 - RemDen2 - RemDen3;
ddt.po4  =  bio.PCrem .* (RemOx + RemDen1 + RemDen2 + RemDen3);
ddt.nh4  =  bio.NCrem .* (RemOx + RemDen1 + RemDen2 + RemDen3) - (Jnn2o_hx+Jno2_hx) - Anammox;
ddt.no2  =  (Jno2_hx + Jno2_nden + bio.NCden1 .* RemDen1 - bio.NCden2 .* RemDen2 - Anammox - Nitrox);
ddt.n2   =  (bio.NCden3 .* RemDen3 + Anammox);


% N2O individual SMSs
sms_n2o_ammox = 0.5 .* Jnn2o_hx;
% Factor 0.5 is because N₂O has 2 N atoms but the flux Jnn2o_hx is in N units (per N atom). 
% So to convert per-N flux into per-molecule N₂O, you divide by 2 (here they multiply by 0.5).
sms_n2o_nden  = 0.5 .* Jnn2o_nden;
sms_n2o_den2  = 0.5 .* bio.NCden2 .* RemDen2;
sms_n2o_den3  = - bio.NCden3 .* RemDen3;
% N2O total SMS
ddt.n2o = (sms_n2o_ammox + sms_n2o_nden + sms_n2o_den2 + sms_n2o_den3);


%%
% Wraps diagnostics
% NOTE: this are all converted to N units
diags.NRemOx = bio.NCrem .* RemOx;
% NRemOx = N remin rate associated with oxic C remin:
% multiply C-units RemOx by NCrem to get N-units.


% diags.NRemDen1 = bio.NCrem .* RemDen1;
%diags.NRemDen2 = bio.NCrem .* RemDen2;
%diags.NRemDen3 = bio.NCrem .* RemDen3;
diags.NRemAnox = bio.NCrem .* (RemDen1+RemDen2+RemDen3);
% NRemAnox = N remin rate associated with anoxic (denitrifying) C remin.

diags.Ammox = Ammox;
diags.Nitrox = Nitrox;
diags.RemDen1 = bio.NCden1 .* RemDen1;
diags.RemDen2 = bio.NCden2 .* RemDen2;
diags.RemDen3 = 2*bio.NCden3 .* RemDen3;
%diags.Jnn2o_hx = Jnn2o_hx;
%diags.Jnn2o_nden = Jnn2o_nden;
%diags.Jno2_hx = Jno2_hx;
%diags.Jno2_nden = Jno2_nden;
diags.Jnn2o_Ax = Jnn2o_hx + Jnn2o_nden;
diags.Jno2_Ax = Jno2_hx + Jno2_nden;
diags.Anammox = 2*Anammox;
%diags.kdoc = -(kRemOx + kRemDen1 + kRemDen2 + kRemDen3);

%------------------------------------------------
% Final source and sink terms
% Lumps variables and diagnostic into a single array

% Note the following approach with anonimous function is *CLEAN* but 2-3 times *SLOWER*
%SMS = cellfun(@(x)(ddt.(x)),nit.BioPar.varnames)';
%DIAGS = cellfun(@(x)(diags.(x)),nit.BioPar.diagnames)';

% For intensive run, use straigth unfolding of structures (careful with order!)
SMS = [ddt.doc;ddt.o2;ddt.po4;ddt.no3;ddt.no2;ddt.nh4;ddt.n2o;ddt.n2];
DIAGS = [diags.NRemOx;diags.NRemAnox;diags.Ammox;diags.Nitrox; ...
    diags.RemDen1;diags.RemDen2;RemDen3; ...
    diags.Jnn2o_Ax;diags.Jno2_Ax;diags.Anammox];

%if any(isnan(SMS)|isinf(SMS))
%   disp(['Problem in SMS calculations']);
%   keyboard
%end

%--------------------------------------------------------------------
% VARIOUS NOTES:
% Note: DB 09/05/20: corrected an apparent mistake in the SMS for NH4/NO2/N2O due to Ammox
% (besides wrong yield calculation!). Simon had :
% sms.nh4 = ... - (Jnn2o_hx+Jno2_hx+Jnn2o_nden)
% sms.no2  =  (Jno2_hx + ...
% sms.n2o = (sms.n2o_ammox + sms.n2o_nden + ...
% While this conserves mass, it's unclear because NH4 has the term Jnn2o_nden which is in fact a sink od NO2-, not NH4...
%--------------------------------------------------------------------
% Cut-outs
% DIAGS = [diags.NRemOx;diags.NRemDen1;diags.NRemDen2;diags.NRemDen3;diags.Ammox; ...
%         diags.Nitrox;diags.RemDen1;diags.RemDen2;RemDen3;diags.Jnn2o_hx; ...
%         diags.Jnn2o_nden;diags.Jno2_hx;diags.Jno2_nden;diags.Anammox];

