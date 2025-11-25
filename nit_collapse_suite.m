 function Suite = nit_collapse_suite(Suite,varargin)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAB_0D postprocessing
% Versions: 0.1 : D. Bianchi, Sept 2020
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% Postprocesses a Suite of output, by averaging and packaging the output
% into individual matrices with the same size as the Suite parameters
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 Param.time_start = nan;	% Starting time for averaging (nan uses dt=end)
 Param.time_end   = nan;	% Ending time for averaging (nan uses dt=end) 
 Param.rmOut   = 0;		% 0: leaves Out; 1: removes Out to reduce size)
 Param.names = {'Sol','Diag','Diag2','All'};
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse required variables, substituting defaults where necessary
 Param = parse_pv_pairs(Param,varargin);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Size of suite output:
 sdims = size(Suite.Out);

 % Collapses Suite output by taking a single value
 % Here default start and end time are NaNs => last value is taken
 for inds=1:Suite.nruns;
    Out{inds} = nit_collapse(Suite.Out{inds},'time_start',Param.time_start,'time_end',Param.time_end);
 end

 fnames = Param.names; 
 nnames = length(fnames);

 for indn=1:nnames
    if isfield(Suite.Out{1},fnames{indn})

       % Variables to process (removes "time")
       allvar = setdiff(fieldnames(Suite.Out{1}.(fnames{indn})),'time','stable'); 
       nvar = length(allvar);
      
       % Packages individual variables
       for indv=1:nvar
       
          % Sets variable name
          thisvar = allvar{indv};
      
          % Initialize variable for output
          tmpvar = nan(sdims);
      
          % Repackages variable avoiding loops
          tmp1 = cell2mat(Out);
          tmp2 = [tmp1.(fnames{indn})];
          tmpvar = reshape([tmp2.(thisvar)],sdims);
          
          % Substitutes variable into output structure
          Suite.OutAll.(fnames{indn}).(thisvar) = tmpvar;
       end 
    end
 end
 if Param.rmOut==1
    Suite = rmfield(Suite,'Out');
 end
