% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template NIT runscript 
% Versions: 0.1 : D. Bianchi, Spet 2020
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Documentation:
% This script allows to perform "sensitivity experiments", where an arbitrary number
% of model parameters is varied, and the model run for each possible combinations of
% parameters.
% Output for each parameter combination will be stored in the cell array Suite.Out
% Access individual experiments by using the appropriate indices, e.g. Suite.Out{1,1}, ... 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Adds path for local functions
 addpath ./functions

 %-------------------------------------------------------
 % Initialize the model - baseline
 % Based on the code and options in nit_main.m
 %-------------------------------------------------------
 clear nit;

 % Biological module
  nit.BioModule = 'omz';

 % Experimental setup
 %nit.ExpModule = 'batch';
  nit.ExpModule = 'chemostat';

 % Here, if needed, overrides default parameters for BioModules and SetUp
 % All Suite experiments will adopt these parameters
 % (use ['property',value] format)
 % NOTE: these should be variables not used as Suite Parameters
 new_BioPar = {};
%new_SetUp = {};
 new_SetUp = {'EndTime',3.0*365};

 %-------------------------------------------------------
 % Define the suite of model runs
 %-------------------------------------------------------

 clear Suite;
 Suite.name = 'flow_mido2';
 Suite.long_name = 'Variable flow at mid-o2 and mid doc';
 NameAdd = 1;  % 1 to add the parameter names to the Suite name
 Suite.base = nit;
 Suite.collapse = 1; 	% Collapses the suite Output by taking average output
			% and packaging the output into arrays with the size 
			% of the Suite parameters (useful to save space, removes time-dependent output)
 Suite.rmOut = 1;		% 0: keeps Out; 1: removes Out
 %---------------------
 % Suite parameters
 % Specify the following:
 % params : names of parameters to be varied
 % module : module where parameters are initialized (BioPar or SetUp)
 % values : one vector of values for each parameter
 %---------------------
 Suite.params	= {'Flow'};
 Suite.module	= {'SetUp'};
%Suite.params	= {'Flow','o2_in'};
%Suite.module	= {'SetUp','BioPar'};
%Suite.params	= {'doc_in','o2_in'};
%Suite.module	= {'BioPar','BioPar'};

%Suite.doc_in	= exp(linspace(log(0.01),log(100),20));
%Suite.o2_in	= exp(linspace(log(0.001),log(10),50));
 Suite.Flow	= exp(linspace(log(0.005),log(1),500));
 %-------------------------------------------------------
 Suite.nparam = length(Suite.params);
 Suite.dims = zeros(1,Suite.nparam);
 Suite.AllParam = cell(1,Suite.nparam);
 for ip = 1:Suite.nparam
    Suite.dims(ip) = length(eval(['Suite.' Suite.params{ip}]));
    Suite.AllParam{ip} = eval(['Suite.' Suite.params{ip}]);
 end
 Suite.nruns = prod(Suite.dims);
 if length(Suite.dims)>1
    Suite.Out = cell(Suite.dims);
 else
    Suite.Out = cell(1,Suite.dims);
 end

 %-------------------------------------------------------
 % Loop through experiments
 %-------------------------------------------------------

 Tsuite = Suite.base;
 runindex = cell(Suite.nparam,1);
 for irun = 1:Suite.nruns
    disp(['Run number # ' num2str(irun) '/' num2str(Suite.nruns)]);
    [runindex{:}] = ind2sub(Suite.dims,irun);
    %---------------------
    % Here, creates the input arguments for bio module and experiment setup
    % (includes any overridden parameters in new_BioPar and new_SetUp)
    arg_BioPar = new_BioPar;
    arg_SetUp = new_SetUp;
    for ipar = 1:Suite.nparam
       disp([ Suite.params{ipar} ' - Start ........  ' num2str(Suite.AllParam{ipar}(runindex{ipar}))]);
       switch Suite.module{ipar} 
       case 'BioPar'
          arg_BioPar = [arg_BioPar Suite.params{ipar} Suite.AllParam{ipar}(runindex{ipar})]; 
       case 'SetUp'
          arg_SetUp = [arg_SetUp Suite.params{ipar} Suite.AllParam{ipar}(runindex{ipar})]; 
       otherwise
          error(['module ' Suite.module{ipar}  ' is not valid']);
       end
    end
    %---------------------
    % Initialized Biomodule with user-defined inputs
    switch Tsuite.BioModule
    case 'omz'
       Tsuite = nit_biopar_omz(Tsuite,arg_BioPar{:});
    otherwise
       error(['Error (experiment case not found)']);
    end

    % Initialized SetUp with user-defined inputs
    switch Tsuite.ExpModule
    case 'batch'
       Tsuite = nit_setup_batch(Tsuite,arg_SetUp{:});
    case 'chemostat'
       Tsuite = nit_setup_chemo(Tsuite,arg_SetUp{:});
    otherwise
       error(['Error (experiment case not found)']);
    end
    %---------------------
    Suite.Out{irun} = Tsuite;
    tic;
    % Run the model
    Suite.Out{irun} = nit_integrate(Suite.Out{irun});
    % Postprocess the results
    Suite.Out{irun} = nit_postprocess(Suite.Out{irun},'dt_new',1);
    % Keeps track of runtime
    Suite.Out{irun}.runtime = toc;
 end
 %---------------------
 % Keeps track of total time, summing up individual times
 Suite.runtime = 0;
 for irun = 1:Suite.nruns
     Suite.runtime = Suite.runtime + Suite.Out{irun}.runtime;
 end;

 %-------------------------------------------------------
 % Postprocess, rename and save the suite
 %-------------------------------------------------------
 % If required, collapses Suite output
 if Suite.collapse==1
    % WARNING: this removes the "Out" field
    Suite = nit_collapse_suite(Suite,'rmOut',Suite.rmOut)
 end

 % Rename the suite
 snewname = ['Suite_' Suite.name];
 if NameAdd ==1
    % Create a newname that includes all the parameters
    for indn=1:Suite.nparam
       snewname = [snewname '_' Suite.params{indn}];
    end
 end
 eval([snewname ' = Suite;']);
 % Save the suite
 eval(['save ' snewname ' ' snewname ';']);

