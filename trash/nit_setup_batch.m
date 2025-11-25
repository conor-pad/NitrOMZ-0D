 function nit = nit_setup_batch(nit,varargin)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAB_0D initialization of experiment setup
% Versions: 0.1 : D. Bianchi, August 2020
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% Simulates a batch culture with initial nutrients concentrations and constant conditions
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %--------------------------------------------------------------------------------
 % First define all CONSTANT parameters
 %--------------------------------------------------------------------------------

 %--------------------------------------------------------------------------------
 % General setup
 SetUp.StartTime = 0*24;	% Duration of batch culture (hours)
 SetUp.EndTime = 2*25*24;	% Duration of batch culture (hours)
 SetUp.dt = 0.1;            % timestep (hours)

 %-------------------------------
 % Define the type and properties of light forcing
 SetUp.iTemp = 1;      % Case (1) : constant light
                       % Case (2) : variable temp (to be implemented if needed)
 SetUp.TempRef = 10;   % Temperature of the batch culture

 %--------------------------------------------------------------------------------
 % Here performs any substitution of default parameters based on user input (varargin)
 SetUp = parse_pv_pairs(SetUp,varargin);
 %--------------------------------------------------------------------------------

 %--------------------------------------------------------------------------------
 % Second, define/process derived variables
 %--------------------------------------------------------------------------------

 % Environmental conditions
 % add here any environmental conditions, use the time vector for time dependent
 % variables (e.g. light, or temperature)
 SetUp.evarnames = {'Temp'};
 SetUp.nevar = length(SetUp.evarnames);

 % Time vector
 SetUp.time = [SetUp.StartTime:SetUp.dt:SetUp.EndTime];
 SetUp.ntime = length(SetUp.time);

 %--------------------------------------------------------------------------------
 % Set temperature conditions
 switch SetUp.iTemp
 case 1
    % Case (1) : constant temperature
    % Vector of light values (defined in each time step):
    SetUp.Env.Temp = SetUp.TempRef * ones(1,SetUp.ntime);
 otherwise
    error(['Error: Case not found!']);
 end
    
 nit.SetUp = SetUp;

