function raw_data = get_live_data_feed(~)
    global hSI
    lastStripe=hSI.hDisplay.stripeDataBuffer{hSI.hDisplay.stripeDataBufferPointer};
    raw_data = lastStripe.rawData;
end
