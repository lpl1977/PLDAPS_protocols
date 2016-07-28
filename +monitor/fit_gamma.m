function gamma_settings = fit_gamma(p)
%gamma_settings = fit_gamma(p)
%
%  Take a PLDAPS object produced by the monitor calibration and get the
%  gamma fit exponent
%
%  After this, run createRigPrefs(gamma_settings)

N = length(p.data);

x = zeros(N,1);
L = zeros(N,1);
for i=1:N
    L(i) = p.data{i}.calib_data.Lxy(1);
    x(i) = p.data{i}.calib_data.stimulus(1);
end

[x,indx] = sort(x);
L = L(indx);
L = L/max(L);

%  Plot data
figure(1);
hold on;
plot(x,L,'+');

%  Fit extended gamma power function
output = linspace(0,1,256)';
[extendedFit,extendedX] = FitGamma(x,L,output,2);
plot(output,extendedFit,'r');
fprintf(1,'Found exponent %g, offset %g\n',extendedX(1),extendedX(2));

max_x = max(x);
inverted_x = InvertGammaExtP(extendedX,max_x,L);
figure(2);
hold on;
plot(x,inverted_x,'r+');
plot([0 max_x],[0 max_x],'r');

%  Invert table
iGT = InvertGammaTable(output,extendedFit,256);
figure(3);
plot(output,iGT)

%  Export
gamma_settings.display.gamma.table = [iGT iGT iGT];
