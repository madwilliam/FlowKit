function panel = start_live_panel(hSI)
    function raw_data = get_live_data_feed(~)
        lastStripe=hSI.hDisplay.stripeDataBuffer{hSI.hDisplay.stripeDataBufferPointer};
        raw_data = lastStripe.rawData(:,2);
    end
    panel =  LineScanPanel(@get_live_data_feed);
end


