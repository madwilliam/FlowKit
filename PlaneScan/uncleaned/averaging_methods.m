O2Pbaseline_avg = (image(lines+3,:)+image(lines+4,:)+image(lines+5,:))/3;
O2Pbaseline_avg = [O2Pbaseline_avg fliplr(O2Pbaseline_avg) O2Pbaseline_avg fliplr(O2Pbaseline_avg)];

O2Ponline=[image(lines,:) fliplr(image(lines+1,:)) image(lines+2,:) fliplr(image(lines+3,:))];
O2Pintensity=O2Ponline-O2Pbaseline;
O2Pintensity=O2Ponline-O2Pbaseline_avg;

figure
subplot(211)
plot(O2Pbaseline(2,:))
ylim([-200,400])
title('original signal baseline')
subplot(212)
plot(O2Pbaseline_avg(2,:))
title('new signal baseline')
ylim([-200,400])

figure
subplot(311)
plot(O2Ponline(2,:))
ylim([-200,200])
title('original signal ylim -500,500')
subplot(312)
plot(O2Ponline(2,:)-O2Pbaseline(2,:))
ylim([-200,200])
title('signal original method to subtract baseline')
subplot(313)
plot(O2Ponline(2,:)-O2Pbaseline_avg(2,:))
ylim([-200,200])
title('signal new method to subtract baseline')