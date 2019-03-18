function forwpar=eeg_ini(para_vc,sensors,para_algo);

[n,m]=size(para_vc)

if nargin<3
   para_algo.order_1=5;
   para_algo.order_2=25;
   para_algo.disproj=.2;
   para_algo.sizeproj=.5;
end


para_sensors=mk_para_sens(para_vc,sensors);
para_sensors_out=calc_leadcoeffs_major_b(para_sensors,para_vc,para_algo);
whos
para_global_out=calc_leadcoeffs_major_global_b(para_sensors_out,para_vc,para_algo);


forwpar.para_global_out=para_global_out;
forwpar.para_sensors_out=para_sensors_out;
forwpar.method='eeg_forward';


return;

