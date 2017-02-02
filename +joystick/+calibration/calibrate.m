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

figure(1);
clf;
lab = {'center','left','right','up','down','move it all around'};
for i=1:6
    subplot(2,6,i);
    plot(p.data{i}.datapixx.adc.data(1,:),p.data{i}.datapixx.adc.data(2,:));
    axis([-0.5 5.5 -0.5 5.5]);
    grid on;
    axis square;
    xlabel('ADC0 (V)');
    ylabel('ADC1 (V)');
    title(lab{i});
end

%  You have 10 seconds of data so pick a 5 second interval towards the end
ix = 4001:9000;

%  Extract center (0,0)
horizontalOffset = mean(p.data{1}.datapixx.adc.data(1,ix));
verticalOffset = mean(p.data{1}.datapixx.adc.data(2,ix));

%  Bounds
left = mean(p.data{2}.datapixx.adc.data(1,ix));
right = mean(p.data{3}.datapixx.adc.data(1,ix));
up = mean(p.data{4}.datapixx.adc.data(2,ix));
down = mean(p.data{5}.datapixx.adc.data(2,ix));

horizontalGain = 1/min(abs(left-horizontalOffset),abs(right-horizontalOffset));
verticalGain = 1/min(abs(up-verticalOffset),abs(down-verticalOffset));

analogStickCalibration.horizontalOffset = horizontalOffset;
analogStickCalibration.horizontalGain = horizontalGain;
analogStickCalibration.verticalOffset = verticalOffset;
analogStickCalibration.verticalGain = verticalGain;

filename = sprintf('~/Documents/MATLAB/settings/analogStickCalibration_%s.mat',p.trial.session.subject);
save(filename,'-struct','analogStickCalibration');


subplot(2,2,3);
plot(min(1,max(-1,horizontalGain*(p.data{i}.datapixx.adc.data(1,:)-horizontalOffset))),min(1,max(-1,verticalGain*(p.data{i}.datapixx.adc.data(2,:)-verticalOffset))));
axis([-1.25 1.25 -1.25 1.25]);
grid on;
axis square;
xlabel('ADC0 (normalized)');
ylabel('ADC1 (normalized)');
title(lab{i});

subplot(2,2,4);

plot(0.5*1920*min(1,max(-1,horizontalGain*(p.data{i}.datapixx.adc.data(1,:)-horizontalOffset)))+959.5,0.5*1080*min(1,max(-1,verticalGain*(p.data{i}.datapixx.adc.data(2,:)-verticalOffset)))+539.5);
axis([0 1920 0 1080]);
grid on;
axis equal;
axis tight;
set(gca,'YDir','reverse')
xlabel('pixels');
ylabel('pixels');
title(lab{i});

