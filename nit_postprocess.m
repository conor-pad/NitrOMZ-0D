 function nit = nit_postprocess(nit,varargin)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Postprocessing
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 Param.dt_new = nan;		% New timestep (days) for post-processing (ignored if NaN)
 Param.names = {'Sol','Diag','Diag2'}; 	% Output structures to process
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse required variables, substituting defaults where necessary
 Param = parse_pv_pairs(Param,varargin);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Adds important variables, including chlorophyll, etc.
 switch nit.BioModule
 case 'omz'
    eps = 1e-30;
    diags = nit.Diag;
    bio = nit.BioPar;
    nit.Diag2.time = nit.Diag.time;
    %---------------------------------------------
    % Adds diagnostics
    %---------------------------------------------
    % Additional tracers diagnostics
    nit.Sol.nstar = (nit.Sol.no3+nit.Sol.no2 + nit.Sol.nh4) - nit.BioPar.NCrem./nit.BioPar.PCrem * nit.Sol.po4;
   %nit.Sol.nstar0 = nit.Sol.no3 - 16 * nit.Sol.po4;
    nit.Sol.ntot = nit.Sol.doc .* nit.BioPar.NCrem + ... 
                   nit.Sol.no3 + nit.Sol.no2 + nit.Sol.nh4 + ...
                   2 * (nit.Sol.n2o + nit.Sol.n2);
    %---------------------------------------------
    % Other time-dependent diagnostics
    %---------------------------------------------
    % Fraction of OM consumed from heterotrophic reactions
    % HEre needs to re-convert terms back to C units
    tmp = diags.NRemOx + diags.NRemAnox + 4*eps; 
    nit.Diag2.fRemOx   = (diags.NRemOx  + eps) ./ tmp;
    nit.Diag2.fRemAnox = (diags.NRemAnox + 3*eps) ./ tmp;
    nit.Diag2.fRemDen1 = bio.NCrem * (diags.RemDen1/bio.NCden1 + eps) ./ tmp;
    nit.Diag2.fRemDen2 = bio.NCrem * (diags.RemDen2/bio.NCden2 + eps) ./ tmp;
    nit.Diag2.fRemDen3 = bio.NCrem * (diags.RemDen3/bio.NCden3/2 + eps) ./ tmp;
    % Fraction of N2 production from anammox
    nit.Diag2.fN2Anmx = (diags.Anammox + eps) ./ (diags.Anammox + diags.RemDen3 + 2*eps);
    % Fraction of N2O production from ammox
    tmp = diags.Jnn2o_Ax + diags.RemDen2 - diags.RemDen3 + 3*eps; 
    nit.Diag2.fN2OAmmx = ( diags.Jnn2o_Ax + eps) ./ tmp;
    nit.Diag2.fN2ODen2 = ( diags.RemDen2  + eps) ./ tmp;
    nit.Diag2.fN2ODen3 = (-diags.RemDen3  + eps) ./ tmp;
    % NO2 recycling terms
    tmp = diags.Jno2_Ax + diags.RemDen1 - diags.RemDen2 - diags.Anammox - diags.Nitrox + 5*eps;
    nit.Diag2.fNO2Ammx = ( diags.Jno2_Ax + eps) ./ tmp; 
    nit.Diag2.fNO2Den1 = ( diags.RemDen1 + eps) ./ tmp; 
    nit.Diag2.fNO2Den2 = (-diags.RemDen2 + eps) ./ tmp; 
    nit.Diag2.fNO2Anmx = (-diags.Anammox + eps) ./ tmp; 
    nit.Diag2.fNO2Nitx = (-diags.Nitrox  + eps) ./ tmp; 
    %---------------------------------------------
    % Other scalar diagnostics
    % NOTE: manuy of these are *INTEGRALS* through time!
    %---------------------------------------------
    % Fraction of OM consumed from heterotrophic reactions
    tmp = sum(diags.NRemOx + diags.NRemAnox) + 4*eps; 
    nit.All.fRemOx   = (sum(diags.NRemOx)  + eps) ./ tmp;
    nit.All.fRemAnox = (sum(diags.NRemAnox) + 3*eps) ./ tmp;
    nit.All.fRemDen1 = bio.NCrem * (sum(diags.RemDen1/bio.NCden1) + eps) ./ tmp;
    nit.All.fRemDen2 = bio.NCrem * (sum(diags.RemDen2/bio.NCden2) + eps) ./ tmp;
    nit.All.fRemDen3 = bio.NCrem * (sum(diags.RemDen3/bio.NCden3/2) + eps) ./ tmp;
    % Fraction of N2 production from anammox
    nit.All.fN2Anmx = (sum(diags.Anammox) + eps) ./ (sum(diags.Anammox + diags.RemDen3) + 2*eps);
    % Fraction of N2O production from ammox
    tmp = sum(diags.Jnn2o_Ax + diags.RemDen2 - diags.RemDen3) + 3*eps; 
    nit.All.fN2OAmmx = ( sum(diags.Jnn2o_Ax) + eps) ./ tmp;
    nit.All.fN2ODen2 = ( sum(diags.RemDen2)  + eps) ./ tmp;
    nit.All.fN2ODen3 = (-sum(diags.RemDen3)  + eps) ./ tmp;
    % NO2 recycling terms
    tmp = sum(diags.Jno2_Ax + diags.RemDen1 - diags.RemDen2 - diags.Anammox - diags.Nitrox) + 5*eps;
    nit.All.fNO2Ammx = ( sum(diags.Jno2_Ax) + eps) ./ tmp; 
    nit.All.fNO2Den1 = ( sum(diags.RemDen1) + eps) ./ tmp; 
    nit.All.fNO2Den2 = (-sum(diags.RemDen2) + eps) ./ tmp; 
    nit.All.fNO2Anmx = (-sum(diags.Anammox) + eps) ./ tmp; 
    nit.All.fNO2Nitx = (-sum(diags.Nitrox)  + eps) ./ tmp; 
    %---------------------------------------------
 otherwise
    error(['Error (Processing biomodule not found)']);
 end

 nproc = length(Param.names);
 if ~isnan(Param.dt_new)
    % Loops through Solution and any other output structure to process
    for indp=1:nproc 
       pname = Param.names{indp};
       % Reduces the frequency of output, by inteprolating on a different timestep
       % New model timestep (days)
       dt_new = Param.dt_new;
       if dt_new<nit.SetUp.dt
          disp(['WARNING: new timestep in postprocessing SMALLER than original timestep']);
       end
       % Creates a new time vector
       new_time = [nit.SetUp.StartTime:dt_new:nit.SetUp.EndTime]; 
       % Loops through all solution variables to regrid them on time axis
       allvar = setdiff(fieldnames(nit.(pname)),'time');
       nvar = length(allvar);
       for indv=1:nvar
          % Gets and interpolates variable on new time axis
          oldvar = nit.(pname).(allvar{indv});
          newvar = interp1(nit.(pname).time,oldvar,new_time);
          % Substitutes back into Solution structure
          nit.(pname).(allvar{indv}) = newvar;
       end
       % Substitutes time vector in Solution strucutre
       nit.(pname).time = new_time;
       % Adds new timestep to solution 
       nit.SetUp.dt_out = dt_new;
    end  
 end

