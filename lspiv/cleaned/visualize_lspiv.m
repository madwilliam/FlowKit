
function visualize_lspiv(data,velocity,LSPIVresult,index,badsamples)
    goodsamples = find(badsamples == 0);
    meanvel  = mean(velocity(goodsamples)); 
    stdvel   = std(velocity(goodsamples)); 
    figure
    subplot(3,1,1)
    [npixels,nsample] = size(data);
    image = zeros([nsample npixels 3]); % to enable BW and color simultaneously
    image(:,:,1) = data(:,1:end)'; image(:,:,2) = data(:,1:end)'; image(:,:,3) = data(:,1:end)';
    imagesc(image/max(max(max(image))))
    title('Raw Data');
    ylabel('[pixels]');    
    subplot(3,1,2)
    imagesc(index,-npixels/2:npixels/2,fftshift(LSPIVresult(:,:),2)');
    title('LSPIV xcorr');
    ylabel({'displacement'; '[pixels/scan]'});
    subplot(3,1,3)
    plot(index, velocity,'.');
    hold all
    plot(index(badsamples), velocity(badsamples), 'ro');
    hold off
    xlim([index(1) index(end)]);
    ylim([meanvel-stdvel*4 meanvel+stdvel*4]);
    title('Fitted Pixel Displacement');
    ylabel({'displacement'; '[pixels/scan]'});
    xlabel('index [pixel]');
    h = line([index(1) index(end)], [meanvel meanvel]);
    set(h, 'LineStyle','--','Color','k');
    h = line([index(1) index(end)], [meanvel+stdvel meanvel+stdvel]);
    set(h, 'LineStyle','--','Color',[.5 .5 .5]);
    h = line([index(1) index(end)], [meanvel-stdvel meanvel-stdvel]);
    set(h, 'LineStyle','--','Color',[.5 .5 .5]);
    fprintf('\nMean  Velocity %0.2f [pixels/scan]\n', meanvel);
    fprintf('Stdev Velocity %0.2f [pixels/scan]\n', stdvel);
end
