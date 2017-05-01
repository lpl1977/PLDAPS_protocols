function analogStickCalibration = calibrate(p)
%CALIBRATE Extract data from results of 2-axis joystick calibration
%
%  analogStickCalibration = joystick.calibration.calibrate(p)
%
%  This function takes the outcome of the joystick calibration protocol and
%  extracts parameters required for transforming the recorded voltage into
%  a scaled value suitable for calculating cursor position.
%
%  Lee Lovejoy
%  ll2833@columbia.edu
%  January 2017

daq = p.trial.analogStick.dataSource;
horizontalChannel = p.trial.analogStick.horizontalChannel;
verticalChannel = p.trial.analogStick.verticalChannel;
fields = textscan(daq,'%s','delimiter','.');
daq = fields{1}{1};

figure(1);
clf;
lab = {'center','left','right','up','down','move it all around'};
minval = 0;
maxval = 0;
for i=1:6
    minval = min(minval,min(p.data{i}.(daq).adc.data(:)));
    maxval = max(maxval,max(p.data{i}.(daq).adc.data(:)));
end
for i=1:6
    subplot(2,6,i);
    plot(p.data{i}.(daq).adc.data(horizontalChannel,:),p.data{i}.(daq).adc.data(verticalChannel,:));
    axis([minval maxval minval maxval]);
    grid on;
    axis square;
    xlabel('ADC0');
    ylabel('ADC1');
    title(lab{i});
end

%  You have 10 seconds of data so pick a 5 second interval towards the end
ix = 4001:9000;

%  Extract center (0,0)
horizontalOffset = mean(p.data{1}.(daq).adc.data(horizontalChannel,ix));
verticalOffset = mean(p.data{1}.(daq).adc.data(verticalChannel,ix));

%  Bounds
left = mean(p.data{2}.(daq).adc.data(horizontalChannel,ix));
right = mean(p.data{3}.(daq).adc.data(horizontalChannel,ix));
up = mean(p.data{4}.(daq).adc.data(verticalChannel,ix));
down = mean(p.data{5}.(daq).adc.data(verticalChannel,ix));

horizontalGain = 1/min(abs(left-horizontalOffset),abs(right-horizontalOffset));
verticalGain = 1/min(abs(up-verticalOffset),abs(down-verticalOffset));

analogStickCalibration.horizontalOffset = horizontalOffset;
analogStickCalibration.horizontalGain = horizontalGain;
analogStickCalibration.verticalOffset = verticalOffset;
analogStickCalibration.verticalGain = verticalGain;

filename = sprintf('~/Documents/MATLAB/settings/analogStickCalibration_%s.mat',p.trial.session.subject);
save(filename,'-struct','analogStickCalibration');


subplot(2,2,3);
plot(min(1,max(-1,horizontalGain*(p.data{i}.(daq).adc.data(horizontalChannel,:)-horizontalOffset))),min(1,max(-1,verticalGain*(p.data{i}.(daq).adc.data(verticalChannel,:)-verticalOffset))));
axis([-1.25 1.25 -1.25 1.25]);
grid on;
axis square;
xlabel('ADC0 (normalized)');
ylabel('ADC1 (normalized)');
title(lab{i});

subplot(2,2,4);

plot(0.5*p.trial.display.pWidth*min(1,max(-1,horizontalGain*(p.data{i}.(daq).adc.data(horizontalChannel,:)-horizontalOffset)))+959.5,0.5*p.trial.display.pHeight*min(1,max(-1,verticalGain*(p.data{i}.(daq).adc.data(verticalChannel,:)-verticalOffset)))+539.5);
axis([0 p.trial.display.pWidth 0 p.trial.display.pHeight]);
grid on;
axis equal;
axis tight;
set(gca,'YDir','reverse')
xlabel('pixels');
ylabel('pixels');
title(lab{i});

