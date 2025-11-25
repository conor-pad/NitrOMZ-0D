 function nit = nit_postprocess(nit,varargin)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAB_0D postprocessing
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% "Collapses" nit Solution output, by averaging between two time steps
% by default it just takes the last timestep, reducing the solution to single numbers
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 Param.time_start = nan;	% Starting time for averaging (nan uses dt=end)
 Param.time_end   = nan;	% Ending time for averaging (nan uses dt=end) 
 Param.names = {'Sol','Diag','Diag2'};  % Output structures to process
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse required variables, substituting defaults where necessary
 Param = parse_pv_pairs(Param,varargin);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Loops through all time-dependent final fields (solution + diagnostics)
 fnames = Param.names;
 nnames = length(fnames);
 for indn=1:nnames
    if isfield(nit,fnames{indn})

       time_vect = nit.(fnames{indn}).time;
      
       if ~isnan(Param.time_start)
          dt_start = findin(Param.time_start,time_vect);
       else
          dt_start = length(time_vect);
       end
      
       if ~isnan(Param.time_end)
          dt_end = findin(Param.time_end,time_vect);
       else
          dt_end = length(time_vect);
       end
      
       % Averages solution between dt1 and dt2
       % Loops through all solution variables to regrid them on time axis
       allvar = setdiff(fieldnames(nit.(fnames{indn})),'time');
       nvar = length(allvar);
       for indv=1:nvar
          % Gets and interpolates variable on new time axis
          oldvar = nit.(fnames{indn}).(allvar{indv});
          newvar = mean(oldvar(:,dt_start:dt_end),2);
          % Substitutes back into Solution structure
          nit.(fnames{indn}).(allvar{indv}) = newvar;
       end
       % Substitutes time vector in Solution structure
       nit.(fnames{indn}).time = mean(time_vect(:,dt_start:dt_end),2);
       nit.SetUp.time = nit.(fnames{indn}).time;
       % Adds new timestep to solution 
       nit.SetUp.dt_out = nan;
    end
 end
 % Averages Environmental variables too
 % Loops through all solution variables to regrid them on time axis
 allvar = fieldnames(nit.SetUp.Env);
 nvar = length(allvar);
 for indv=1:nvar
    % Gets and interpolates variable on new time axis
    oldvar = nit.SetUp.Env.(allvar{indv});
    newvar = mean(oldvar(:,dt_start:dt_end),2);
    % Substitutes back into Solution structure
    nit.SetUp.Env.(allvar{indv}) = newvar;
 end

