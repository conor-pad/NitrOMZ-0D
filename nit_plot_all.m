 function nit_plot_all(nit,varargin);
% Add documentation here:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 Param.names = {'Sol'};  % Output structures to process
             % {'Sol','Diag','Diag2'};  % Output structures to process
 Param.iAll = 1; % show scalar diagnistics in "nit.All"
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse required variables, substituting defaults where necessary
 Param = parse_pv_pairs(Param,varargin);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 nplots = length(Param.names);
 for indp=1:nplots

    tname = Param.names{indp};

    Tstart = 0;
    Tend = nit.(tname).time(end);
    eps = 1e-10;
    
    % Sets the variables to plot based on the solution nit.Sol
    % (this includes any derived variables added to nit.Sol in postporcessing) 
    varnames = setdiff(fieldnames(nit.(tname)),'time','stable');
    % Decides the optimal number of subplot given the # of state variables
    nvar = length(varnames); 
    [nsp, npp] = numSubplots(nvar);
   
    figure
    for indv=1:nvar; 
       vname = varnames{indv};
       tvar = nit.(tname).(vname);
       
       subplot(nsp(1),nsp(2),indv)
       plot(nit.(tname).time,tvar,'-k','linewidth',2)
       hold on
       title([vname],'fontsize',15);
       mmin = min(tvar);
       mmax = max(tvar);
       axis([Tstart Tend (1-sign(mmin)*0.1)*mmin-eps (1+sign(mmax)*0.1)*mmax+eps])
    end
 end

 if isfield(nit,'All')&Param.iAll==1
    allnames = fieldnames(nit.All);
    nall = length(allnames);
    disp('-----------------------------------------');
    for indi=1:nall
       disp([allnames{indi} ' : ' num2str(nit.All.(allnames{indi}))]); 
    end 
    disp('-----------------------------------------');
 end
