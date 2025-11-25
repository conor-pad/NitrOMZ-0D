 function nit = nit_integrate(nit)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Integration
% Versions: 0.1 : D. Bianchi, August
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Calculate the sources and sinks
 
 nvar = nit.BioPar.nvar;        % number of model state variables
 ndiag = nit.BioPar.ndiag;       % number of biological diagnostics
 nevar = nit.SetUp.nevar;       % number of model state variables
 ntime = nit.SetUp.ntime;       % number of model time steps
 dt = nit.SetUp.dt;             % timestep (hours)

 % Creates a matrix of size [nvar,ntime] to do time integration
 AllVar = nan(nvar,ntime);
 % Set inital conditions 
 for indv=1:nvar
    AllVar(indv,1) = nit.BioPar.([nit.BioPar.varnames{indv} '_0']);
 end

 % Creates a matrix of size [ndiag,ntime] to store diagnostcs
 AllDiag = nan(ndiag,ntime);

 % Creates a matrix of size [nvar,ntime] to do time integration
 EnvVar = nan(nevar,ntime);
 % Fills in the entire matrix with prescribed environmental forcings
 for indv=1:nevar
    EnvVar(indv,:) = nit.SetUp.Env.([nit.SetUp.evarnames{indv}]);
 end

 % For chemostat/ML case, set vector of inflow concentrations 
 % (one input concentration per variable, set as constant over time)
 for indv=1:nvar
    InVar(indv,1) = nit.BioPar.([nit.BioPar.varnames{indv} '_in']);
 end

 for indt=2:ntime
    % Uncomment this for run-time display of current time-step
    %fprintf(['Integration time step #' num2str(indt) '/' num2str(ntime) '\n']);
 
    % Calculates the sources minus sink terms, using the state variables
    % at the previous time step, and all model parameters

    % (1) Gets Biological Sources and Sinks
    switch nit.BioModule
    case 'omz'
       [sms_bio diags] = nit_sms_omz(nit,AllVar(:,indt-1),EnvVar(:,indt-1));
    otherwise
       error(['Error (biological case not found)']);
    end
   
    % (2) Gets the physical sources and sinks
    switch nit.ExpModule
    case 'batch'
       sms_phys = zeros(nvar,1);
    case 'chemostat'
       % For the chemostat case, calculates the SMS due to dilution simply as 
       % the difference of tracer coming in minus tracer going out
       sms_phys = nit.SetUp.Flow/nit.SetUp.Vol * (InVar - AllVar(:,indt-1));
    otherwise
       error(['Error (physical SMS case not found)']);
    end

   % Actual integration step, using a forward time scheme
   AllVar(:,indt) = AllVar(:,indt-1) + dt * (sms_bio + sms_phys);

   % Stores the diagnostics
   % Note on time-step: diagnostics are stored at the timestep for which they were calculated
   AllDiag(:,indt-1) = diags;
 end

 % Transfer variables from integration array to solution structure
 nit.Sol.time = nit.SetUp.time;
 for indv=1:nvar
    nit.Sol.(nit.BioPar.varnames{indv}) = AllVar(indv,:);
 end 

 % Transfer diagnostics from integration array to diagnostics structure
 % First gets the SMS for the last timestep (not calculated in the main loop above)
 switch nit.BioModule
 case 'omz'
    [sms_bio diags] = nit_sms_omz(nit,AllVar(:,end),EnvVar(:,end));
 otherwise
    error(['Error (biological case not found)']);
 end
 AllDiag(:,end) = diags;
 % Fills in final array
 nit.Diag.time = nit.SetUp.time;
 for indv=1:ndiag
    nit.Diag.(nit.BioPar.diagnames{indv}) = AllDiag(indv,:);
 end 
 
 

