%%
panel = LineScanPanel(@get_simulated_data_feed,64,10);
%%
panel =  LineScanPanel(@DataSimulator.get_one_radon_test);

%%
global hSI
lastStripe=hSI.hDisplay.stripeDataBuffer{hSI.hDisplay.stripeDataBufferPointer};
data_chunk = reshape(lastStripe.rawData,nline,[]);