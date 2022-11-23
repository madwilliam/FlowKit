classdef LiveFeedManager

   methods (Static)
       function update_line_plot(line,data)
            line.XData = data.display_time;
            line.YData = data.slope_data;
       end

       function panel = start_live_panel(hSI)
            function raw_data = get_live_data_feed(~)
                lastStripe=hSI.hDisplay.stripeDataBuffer{hSI.hDisplay.stripeDataBufferPointer};
                raw_data = lastStripe.rawData(:,1);
            end
            panel =  LineScanPanel(@get_live_data_feed, hSI.hScan2D.lineScanSamplesPerFrame, 100);
       end

       function f = start_panel_in_background(data_function,npixel)
            fig = figure;
            line = plot(1,1);
            q = parallel.pool.DataQueue;
            afterEach(q,@(data) LiveFeedManager.update_line_plot(line,data));
            function annalyzer = start_live_data_feed(q)
                annalyzer = LiveRadonAnnalyzer(data_function,npixel,q);
                annalyzer.initiate_data_fields()
                annalyzer.start_analysis_loop()
            end
            pool = gcp('nocreate');
            if isempty(pool)
                pool = parpool;
            end
            f = parfeval(pool,@start_live_data_feed,1,q);
       end

   end
end